class ApplicationTemplate < ActiveRecord::Base
  has_many :questions

  DEPARTMENTS = %w(Bus
                   Special\ Transportation)

  validates :department, presence: true,
                         inclusion: {in: DEPARTMENTS, message: "must be one of #{DEPARTMENTS.join ', '}"}
end
