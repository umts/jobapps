class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :position

  validates :position_id, uniqueness: { scope: :email }

  validates :email,
            :user_id,
            :position_id, presence: true

  
end
