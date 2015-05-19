class EmailTemplate < ActiveRecord::Base
  validates :text, presence: true
end
