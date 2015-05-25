class Department < ActiveRecord::Base
  has_many :positions
  has_many :application_templates, through: :positions
  has_many :application_records, through: :positions
  validates :name, presence: true

  default_scope { order :name }

end
