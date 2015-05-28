class ApplicationRecord < ActiveRecord::Base
  belongs_to :user
  belongs_to :position
  delegate :department, to: :position
  has_one    :interview

  serialize :responses, Hash

  validates :position,
            :responses,
            :user,
            presence: true
  validates :reviewed, inclusion: {in: [true, false]}

  scope :pending,      ->{where reviewed: false}
  scope :by_user_name, ->{joins(:user).order('users.last_name, users.first_name')}

  def pending?
    !reviewed
  end

end
