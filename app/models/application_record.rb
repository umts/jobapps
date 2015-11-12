include ApplicationConfiguration

class ApplicationRecord < ActiveRecord::Base
  belongs_to :user
  belongs_to :position
  delegate :department, to: :position
  has_one :interview, dependent: :destroy

  serialize :responses, Array

  validates :position,
            # :responses, put back in once import is complete
            # attr accessor suspend validation
            # imports that bypass validation
            :user,
            presence: true
  validates :reviewed, inclusion: { in: [true, false] }

  scope :pending, -> { where reviewed: false }
  scope :newest_first, -> { order 'created_at desc' }
  scope :between,
        -> (start_date, end_date) { where created_at: start_date..end_date }

  def deny_with(staff_note)
    update staff_note: staff_note
    if configured_value [:on_application_denial, :notify_applicant],
                        default: true
      JobappsMailer.application_denial(self).deliver_now
    end
  end

  def add_response_data(prompt, response)
    update(responses: responses << [prompt, response])
    self
  end

  def pending?
    !reviewed
  end
end
