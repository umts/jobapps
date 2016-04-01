class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :position

  validates :position_id, uniqueness: { scope: :email }

  validates :email,
            :user,
            :position, presence: true
end
