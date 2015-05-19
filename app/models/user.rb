class User < ActiveRecord::Base
  has_many :interviews
  has_many :application_records

  validates :first_name,
            :last_name,
            :spire,
            presence: true
end
