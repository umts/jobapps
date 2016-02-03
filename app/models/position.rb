class Position < ActiveRecord::Base
  belongs_to :department
  has_one :application_template, dependent: :destroy
  has_many :application_records, dependent: :destroy
  has_many :interviews, through: :application_records

  validates :department,
            :name,
            presence: true

  scope :by_name_and_department, lambda { |name, dept|
    dept.positions.find_by 'lower(name) = ?', name.downcase
  }

  default_scope { order :name }

  def name_and_department
    "#{name} (#{department.name})"
  end
end
