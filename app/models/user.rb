class User < ActiveRecord::Base
  has_many :interviews
  has_many :application_records

  validates :email,
            :first_name,
            :last_name,
            :spire,
            presence: true
  validates :staff, inclusion: { in: [true, false],
                                 message: 'must be true or false' }
  validates :spire, uniqueness: true

  default_scope { order :last_name, :first_name }
  scope :staff,    -> { where staff: true }
  scope :students, -> { where staff: false }

  def full_name
    "#{first_name} #{last_name}"
  end

  def proper_name
    "#{last_name}, #{first_name}"
  end

  def student?
    !staff?
  end
end
