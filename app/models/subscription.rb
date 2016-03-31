class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :position

  validates :email,
            :user_id,
            :position_id, presence: true

  
end
