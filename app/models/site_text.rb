class SiteText < ActiveRecord::Base
  validates :name, :text, presence: true
end
