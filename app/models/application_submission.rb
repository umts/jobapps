# frozen_string_literal: true

class ApplicationSubmission < ApplicationRecord
  include ApplicationConfiguration

  belongs_to :user
  belongs_to :position
  delegate :department, to: :position
  has_one :interview, dependent: :destroy
  has_one :unavailability, dependent: :destroy

  serialize :data, Array
  attr_accessor :mail_to_applicant

  # validate ethnicity and gender in constants but allow blank
  validates :position, :data, :user, presence: true
  validates :reviewed, inclusion: { in: [true, false] }
  validates :note_for_later, presence: true, if: :saved_for_later

  scope :between,
        lambda { |start_date, end_date|
          where created_at: start_date..end_date.end_of_day
        }
  scope :in_department,
        lambda { |department_ids|
          joins(:position)
            .where(positions: { department_id: department_ids })
        }
  scope :hire_count, lambda {
    joins(:interview)
      .where(interviews: { application_submission_id: ids, hired: true }).count
  }
  scope :interview_count, lambda {
    joins(:interview)
      .where(interviews: { application_submission_id: ids }).count
  }
  scope :newest_first, -> { order 'created_at desc' }
  scope :pending, -> { where reviewed: false }
  scope :with_gender, -> { where.not gender: [nil, ''] }
  scope :with_ethnicity, -> { where.not ethnicity: [nil, ''] }

  before_save do
    if saved_for_later_changed?
      if saved_for_later?
        JobappsMailer.send_note_for_later(self).deliver_now if mail_to_applicant
      else
        assign_attributes(
          date_for_later: nil,
          reviewed: false
        )
      end
    end
  end

  ETHNICITY_OPTIONS = ['White (Not of Hispanic origin)',
                       'Black (Not of Hispanic origin)',
                       'Hispanic',
                       'Asian or Pacific Islander',
                       'American Indian or Alaskan Native',
                       'Mixed ethnicity'].freeze

  GENDER_OPTIONS = %w[Male Female].freeze

  def data_rows
    header = [%w[Question Response]]
    # deletes rows of type header/explanation
    questions = data.delete_if do |_prompt, _response, data_type, _id|
      %w[heading explanation].include? data_type
    end.map do |prompt, response, _data_type, _id|
      [prompt, response]
    end
    header + questions
  end

  def email_subscribers(applicant:)
    position.subscriptions.each do |sub|
      JobappsMailer.application_notification(sub, position, applicant)
                   .deliver_now
    end
  end

  def questions_hash
    data.map do |_prompt, response, _data_type, question_id|
      [question_id, response]
    end.select(&:all?).to_h
  end

  def deny_with(staff_note)
    update staff_note: staff_note if staff_note
    if configured_value %i[on_application_denial notify_applicant],
                        default: true
      if self.staff_note.present?
        JobappsMailer.application_denial(self).deliver_now
      end
    end
  end

  def pending?
    !reviewed
  end

  def save_for_later(date: nil, note: nil, mail: false, email: nil)
    if update(
        saved_for_later: true,
        date_for_later: date,
        note_for_later: note,
        email_to_notify: email
    )
    end
  end

  def self.move_to_dashboard
    records = where('date_for_later <= ?', Time.zone.today)
    email_records = where('date_for_later <= ?', Time.zone.today)
                    .where.not(email_to_notify: [nil, ''])
    if email_records.one?
      record = records.first
      JobappsMailer.saved_application_notification(record)
    elsif email_records.many?
      send_notification_emails! email_records
    end
    records.update_all(saved_for_later: false)
  end

  def self.combined_eeo_data(records)
    combined_records = records.with_gender.with_ethnicity
    grouped_by_gender = {}
    all_ethnicities = ETHNICITY_OPTIONS | combined_records.pluck(:ethnicity)
    all_genders = GENDER_OPTIONS | combined_records.pluck(:gender)
    all_genders.map do |gender|
      ethnicity_specs = []
      all_ethnicities.map do |ethnicity|
        records = combined_records.where ethnicity: ethnicity, gender: gender
        count = records.count
        interviewed = records.interview_count
        hired = records.hire_count
        ethnicity_specs << [ethnicity, count, interviewed, hired]
        grouped_by_gender[gender] = ethnicity_specs
      end
    end
    grouped_by_gender
  end

  def self.gender_eeo_data(records)
    gender_records = records.with_gender
    all_genders = GENDER_OPTIONS | gender_records.pluck(:gender)
    all_genders.map do |gender|
      specific_records = gender_records.where gender: gender
      count = specific_records.count
      interviewed = specific_records.interview_count
      hired = specific_records.hire_count
      [gender, count, interviewed, hired]
    end
  end

  def self.eeo_data(start_date, end_date, dept_ids)
    records = {}
    records[:all] = between(start_date, end_date).in_department(dept_ids)
    records[:ethnicities] = ethnicity_eeo_data(records[:all])
    records[:genders] = gender_eeo_data(records[:all])
    records[:combined_data] = combined_eeo_data(records[:all])
    records
  end

  def self.ethnicity_eeo_data(records)
    ethnicity_records = records.with_ethnicity
    all_ethnicities = ETHNICITY_OPTIONS | ethnicity_records.pluck(:ethnicity)
    all_ethnicities.map do |ethnicity|
      specific_records = ethnicity_records.where ethnicity: ethnicity
      count = specific_records.count
      interviewed = specific_records.interview_count
      hired = specific_records.hire_count
      [ethnicity, count, interviewed, hired]
    end
  end

  def self.send_notification_emails!(records)
    records_by_email = records.includes(:position).group_by(&:email_to_notify)
    records_by_email.each_pair do |address, email_records|
      records_by_position = email_records.group_by(&:position)
      JobappsMailer.saved_applications_notification records_by_position, address
    end
  end

  def rejected?
    reviewed? && interview.blank?
  end
end
