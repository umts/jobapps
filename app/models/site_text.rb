class SiteText < ActiveRecord::Base
  validates :name, :text, presence: true
  validates :name, uniqueness: true
end
