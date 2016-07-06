include ApplicationConfiguration

class Position < ActiveRecord::Base
  belongs_to :department
  has_one :application_template, dependent: :destroy
  has_many :application_records, dependent: :destroy
  has_many :interviews, through: :application_records
  has_many :subscriptions, dependent: :destroy
  has_many :users, through: :subscriptions

  validates :department,
            :name,
            presence: true

  default_scope { order :name }

  NOT_HIRING = "We are not currently hiring for #{name}. Please check back."
               .freeze

  def name_and_department
    "#{name} (#{department.name})"
  end
end
