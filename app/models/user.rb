# frozen_string_literal: true

class User < ApplicationRecord
  has_many :interviews, dependent: :destroy
  has_many :application_submissions, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :positions, through: :subscriptions

  validates :email,
            :first_name,
            :last_name,
            :spire,
            presence: true
  validates :email,
            format: { with: /\A([^@\s]+)@((?:[-a-zA-Z0-9]+\.)+[a-zA-Z]{2,})\Z/ }
  validates :staff, inclusion: { in: [true, false],
                                 message: 'must be true or false' }
  validates :spire,
            uniqueness: { case_sensitive: false },
            format: { with: /\A\d{8}@umass\.edu\z/ }

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

  def old_applications(position)
    application_submissions.where(position_id: position.id)
  end
end
