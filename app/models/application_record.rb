include ApplicationConfiguration

class ApplicationRecord < ActiveRecord::Base
  belongs_to :user
  belongs_to :position
  delegate :department, to: :position
  has_one :interview, dependent: :destroy
  has_one :unavailability

  serialize :data, Array

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
  scope :interview_count, lambda {
    joins(:interview)
      .where(interviews: { application_record_id: ids }).count
  }
  scope :newest_first, -> { order 'created_at desc' }
  scope :pending, -> { where reviewed: false }
  scope :with_gender, -> { where.not gender: [nil, ''] }
  scope :with_ethnicity, -> { where.not ethnicity: [nil, ''] }

  ETHNICITY_OPTIONS = ['White (Not of Hispanic origin)',
                       'Black (Not of Hispanic origin)',
                       'Hispanic',
                       'Asian or Pacific Islander',
                       'American Indian or Alaskan Native',
                       'Mixed ethnicity'].freeze

  GENDER_OPTIONS = %w(Male
                      Female).freeze

  def data_rows
    header = [%w(Question Response)]
    # deletes rows of type header/explanation
    questions = data.delete_if do |_prompt, _response, data_type, _id|
      %w(heading explanation).include? data_type
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
    update staff_note: staff_note
    if configured_value [:on_application_denial, :notify_applicant],
                        default: true
      JobappsMailer.application_denial(self).deliver_now
    end
  end

  def pending?
    !reviewed
  end

  def save_for_later(date: nil, note: nil, mail: false, email: nil)
    update_attributes(saved_for_later: true,
                      date_for_later: date,
                      note_for_later: note,
                      email_to_notify: email)
    JobappsMailer.send_note_for_later(self).deliver_now if mail
  end

  def move_to_dashboard
    update_attributes(saved_for_later: false,
                      date_for_later: nil)
  end

  def self.move_to_dashboard
    records = where('date_for_later <= ?', Time.zone.today)
    email_records = where('date_for_later <= ?', Time.zone.today)
                    .where("email_to_notify is NOT NULL and
                            email_to_notify != ''")
    if email_records.count == 1
      record = records.first
      JobappsMailer.saved_application_notification(record)
    elsif email_records.many?
      notification_emails(email_records)
    end
    records.each(&:move_to_dashboard)
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
        ethnicity_specs << [ethnicity, records.count, records.interview_count]
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
      [gender, specific_records.count, specific_records.interview_count]
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
      [ethnicity, specific_records.count, specific_records.interview_count]
    end
  end

  def self.notification_emails(records)
    emails = Hash.new { |h, k| h[k] = {} }
    records.each do |record|
      emails = build_email_hash(emails, record)
    end
    send_emails(emails)
  end

  def self.send_emails(emails)
    if emails.present?
      emails.each_key do |email|
        JobappsMailer.saved_applications_notification(emails[email], email)
      end
    end
  end

  def self.build_email_hash(emails, record)
    if emails[record.email_to_notify][record.position.name].present?
      emails[record.email_to_notify][record.position.name].push(record)
    else
      emails[record.email_to_notify][record.position.name] = [record]
    end
    emails
  end
end
