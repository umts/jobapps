class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :position

  validates :position, uniqueness: { scope: :email }

  validates :email,
            :user,
            :position, presence: true

  scope :notification, -> { where(notification: true) }
end
