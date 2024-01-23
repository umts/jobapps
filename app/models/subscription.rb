# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :position

  validates :position, uniqueness: { scope: :email }

  validates :email, presence: true
end
