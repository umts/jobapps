include ApplicationConfiguration

class Position < ActiveRecord::Base
  belongs_to :department
  has_one :application_template, dependent: :destroy
  has_many :filed_applications, dependent: :destroy
  has_many :interviews, through: :filed_applications
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
