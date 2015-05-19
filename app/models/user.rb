class User < ActiveRecord::Base
  has_many :interviews
  has_many :application_records

  validates :first_name,
            :last_name,
            :spire,
            presence: true
  validates :staff, inclusion: {in: [true, false], message: 'must be true or false'}
end
