class ApplicationTemplate < ActiveRecord::Base
  has_many :questions, dependent: :destroy
  belongs_to :position
  delegate :department, to: :position

  validates :position, presence: true, uniqueness: true
end
