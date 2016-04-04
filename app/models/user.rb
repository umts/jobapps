class User < ActiveRecord::Base
  has_many :interviews, dependent: :destroy
  has_many :application_records, dependent: :destroy

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

  def name_and_email
    "#{full_name}, #{email}"
  end

  def proper_name
    "#{last_name}, #{first_name}"
  end

  def student?
    !staff?
  end

  def old_applications(position_id)
    application_records.where(position_id: position_id)
  end
end
