class Position < ActiveRecord::Base
  belongs_to :department 
  has_one :application_template
  has_many :application_records
  has_many :interviews, through: :application_records

  validates :department,
            :name,
            presence: true
  
  default_scope { order :name }

end
