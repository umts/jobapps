include ApplicationConfiguration

class ApplicationRecord < ActiveRecord::Base
  belongs_to :user
  belongs_to :position
  delegate :department, to: :position
  has_one :interview, dependent: :destroy

  serialize :responses, Hash

  validates :position,
            :responses,
            :user,
            presence: true
  validates :reviewed, inclusion: { in: [true, false] }

  scope :pending, -> { where reviewed: false }

  def self.by_user_name
    joins(:user).order 'users.last_name, users.first_name'
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
end
