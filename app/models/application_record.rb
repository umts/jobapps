include ApplicationConfiguration

class ApplicationRecord < ActiveRecord::Base
  belongs_to :user
  belongs_to :position
  delegate :department, to: :position
  has_one :interview, dependent: :destroy

  serialize :data, Array

  # validate ethnicity and gender in constants but allow blank
  validates :position,
            :data,
            :user,
            presence: true
  validates :reviewed, inclusion: { in: [true, false] }

  scope :pending, -> { where reviewed: false }
  scope :newest_first, -> { order 'created_at desc' }
  scope :between,
        -> (start_date, end_date) { where created_at: start_date..end_date }
  scope :in_department,
        lambda { |department_ids|
          joins(:position)
            .where(positions: { department_id: department_ids })
        }
  scope :with_gender, -> { where.not gender: [nil, ''] }
  scope :with_ethnicity, -> { where.not ethnicity: [nil, ''] }

  ETHNICITY_OPTIONS = ['White (Not of Hispanic origin)',
                       'Black (Not of Hispanic origin)',
                       'Hispanic',
                       'Asian or Pacific Islander',
                       'American Indian or Alaskan Native',
                       'Mixed ethnicity']

  GENDER_OPTIONS = %w(Male
                      Female)

  def add_data_types
    data.each do |array|
      question = Question.find_by(prompt: array.first)
      data_type = question.try(:data_type) || 'text'
      array << data_type
    end
    save
  end

  def add_response_data(prompt, response)
    update(data: data << [prompt, response])
    self
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

  def self.gender_eeo_data(start_date, end_date, department_ids)
    gender_records = between(start_date, end_date).with_gender
                     .in_department(department_ids)
    all_genders = GENDER_OPTIONS | gender_records.pluck(:gender)
    all_genders.map do |option|
      [option, gender_records.where(gender: option).count]
    end
  end

  def self.eeo_data(start_date, end_date, department_ids)
    records = {}
    records[:all] = between(start_date, end_date).in_department(department_ids)
    ethnicity_records = records[:all].with_ethnicity
    all_ethnicities = ETHNICITY_OPTIONS | ethnicity_records.pluck(:ethnicity)
    records[:ethnicities] = all_ethnicities.map do |option|
      [option, ethnicity_records.where(ethnicity: option).count]
    end
    records[:genders] = gender_eeo_data(start_date, end_date, department_ids)
    records[:male_ethnicities] = all_ethnicities.map do |ethnicity|
      [ethnicity, ethnicity_records.where(ethnicity: ethnicity,
                                          gender: 'Male').count]
    end
    records[:female_ethnicities] = all_ethnicities.map do |ethnicity|
      [ethnicity, ethnicity_records.where(ethnicity: ethnicity,
                                          gender: 'Female').count]
    end
    records
  end
end
