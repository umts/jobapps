class Department < ApplicationRecord
  has_many :positions, dependent: :destroy
  has_many :application_templates, through: :positions
  has_many :application_submissions, through: :positions
  validates :name, presence: true, uniqueness: true

  default_scope { order :name }
end
