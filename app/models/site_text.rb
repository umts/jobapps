class SiteText < ApplicationRecord
  extend FriendlyId
  friendly_id :site_text_name, use: :slugged

  validates :name, :text, presence: true
  validates :name, uniqueness: true

  def site_text_name
    name.parameterize
  end
end
