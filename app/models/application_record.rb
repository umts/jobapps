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

  scope :between,
        -> (start_date, end_date) { where created_at: start_date..end_date }
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
  
  def self.combined_eeo_data(records)
    combined_records = records.with_gender.with_ethnicity
    sub_hash = {}
    all_ethnicities = ETHNICITY_OPTIONS | combined_records.pluck(:ethnicity)
    all_genders = GENDER_OPTIONS | combined_records.pluck(:gender)
    all_genders.map do |gender|
      sub_array = []
      all_ethnicities.map do |ethnicity|
        specific_records = combined_records.where(ethnicity: ethnicity,
                                                  gender: gender)
        sub_array << [ethnicity, specific_records.count, specific_records.interview_count]
        sub_hash.store(:"#{gender}", sub_array)
      end
    end
    sub_hash
  end

  def self.gender_eeo_data(records)
    gender_records = records.with_gender
    all_genders = GENDER_OPTIONS | gender_records.pluck(:gender)
    all_genders.map do |option|
      specific_records = gender_records.where(gender: option)
      [option, specific_records.count, specific_records.interview_count]
    end
  end

  def self.eeo_data(start_date, end_date, dept_ids)
    records = {}
    records[:all] = between(start_date, end_date).in_department(dept_ids)
    records[:ethnicities] = ethnicity_eeo_data(records[:all])
    records[:genders] = gender_eeo_data(records[:all])
    records[:combo_ethnicities] = combined_eeo_data(records[:all])
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
end
