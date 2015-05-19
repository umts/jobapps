class ApplicationRecord < ActiveRecord::Base
  belongs_to :user

  serialize :responses, Hash

  validates :responses,
            :user,
            presence: true
end
