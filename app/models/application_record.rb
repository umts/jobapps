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
  # scope :with_gender, -> { where 'gender is not null' }
  # scope :with_ethnicity, -> { where 'ethnicity is not null' }
  scope :with_gender, -> { where.not gender: nil }
  scope :with_ethnicity, -> { where.not ethnicity: nil }

  ETHNICITY_OPTIONS = ['White (Not of Hispanic origin)',
                       'Black (Not of Hispanic origin)',
                       'Hispanic',
                       'Asian or Pacific Islander',
                       'American Indian or Alaskan Native',
                       'Mixed ethnicity']

  GENDER_OPTIONS = ['Male',
                    'Female']

  def deny_with(staff_note)
    update staff_note: staff_note
    if configured_value [:on_application_denial, :notify_applicant],
                        default: true
      JobappsMailer.application_denial(self).deliver_now
    end
  end

  def add_response_data(prompt, response)
    update(data: data << [prompt, response])
    self
  end

  def pending?
    !reviewed
  end
end
