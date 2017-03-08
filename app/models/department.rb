class Department < ActiveRecord::Base
  has_many :positions, dependent: :destroy
  has_many :application_templates, through: :positions
  has_many :filed_applications, through: :positions
  validates :name, presence: true, uniqueness: true

  default_scope { order :name }
end
