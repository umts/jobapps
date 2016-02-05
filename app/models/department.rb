class Department < ActiveRecord::Base
  has_many :positions, dependent: :destroy
  has_many :application_templates, through: :positions
  has_many :application_records, through: :positions
  validates :name, presence: true, uniqueness: true

  scope :by_name, ->(name) { find_by 'lower(name) = ?', name.downcase }
  default_scope { order :name }
end
