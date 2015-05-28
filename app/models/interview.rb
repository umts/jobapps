class Interview < ActiveRecord::Base
  include DateAndTimeMethods

  belongs_to :user
  belongs_to :application_record
  delegate :department,
           :position,
           to: :application_record

  validates :completed,
            :hired,
            inclusion: {in: [true, false], message: 'must be true or false'}
  validates :application_record,
            :location,
            :scheduled,
            :user,
            presence: true

  after_create :send_confirmation

  default_scope {order :scheduled}
  scope :pending, ->{where completed: false}

  def information
    "#{format_date_time scheduled} at #{location}: #{user.proper_name}"
  end

  def pending?
    !completed
  end

  private

  def send_confirmation
    JobappsMailer.interview_confirmation self
  end
end
