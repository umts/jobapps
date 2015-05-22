class ApplicationTemplate < ActiveRecord::Base
  has_many :questions
  belongs_to :department

  validates :department, presence: true

  scope :by_department, ->{joins(:department).order 'departments.name'}
end
