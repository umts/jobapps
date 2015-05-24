class Department < ActiveRecord::Base
  has_one :application_template
  has_many :application_records
  has_many :interviews, through: :application_records

  validates :name, presence: true
end
