class ApplicationRecord < ActiveRecord::Base
  belongs_to :user
  belongs_to :department

  serialize :responses, Hash

  validates :department,
            :responses,
            :user,
            presence: true
  validates :reviewed, inclusion: {in: [true, false]}

  scope :pending,      ->{where reviewed: false}
  scope :by_user_name, ->{joins(:user).order('users.last_name, users.first_name')}
end
