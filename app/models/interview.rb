class Interview < ActiveRecord::Base
  include DateAndTimeMethods

  belongs_to :user
  belongs_to :application_record

  validates :hired, inclusion: {in: [true, false], message: 'must be true or false'}
  validates :application_record,
            :scheduled,
            :user,
            presence: true

  default_scope {order :scheduled}
  scope :pending, ->{where 'scheduled > ?', DateTime.now}

  def information
    "#{format_date_time scheduled} #{user.proper_name}"
  end
end
