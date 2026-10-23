# frozen_string_literal: true

class Position < ApplicationRecord
  has_one :application_template, dependent: :destroy
  has_many :application_submissions, dependent: :restrict_with_error
  has_many :interviews, through: :application_submissions
  has_many :subscriptions, dependent: :destroy
  has_many :users, through: :subscriptions
  has_many :position_managers, dependent: :destroy
  has_many :managers, through: :position_managers, source: :user

  validates :name, presence: true

  default_scope { order :name }

  def not_hiring
    not_hiring_text.presence ||
      "We are not currently hiring for #{name}."
  end
end
