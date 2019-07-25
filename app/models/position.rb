# frozen_string_literal: true

class Position < ApplicationRecord
  include ApplicationConfiguration

  belongs_to :department
  has_one :application_template, dependent: :destroy
  has_many :application_submissions, dependent: :destroy
  has_many :interviews, through: :application_submissions
  has_many :subscriptions, dependent: :destroy
  has_many :users, through: :subscriptions

  validates :department,
            :name,
            presence: true

  default_scope { order :name }

  def name_and_department
    "#{name} (#{department.name})"
  end

  def not_hiring
    not_hiring_text ||
      "We are not currently hiring for #{name}."
  end
end
