class Department < ActiveRecord::Base
  has_many :positions, dependent: :destroy
  has_many :application_templates, through: :positions
  has_many :application_records, through: :positions
  validates :name, presence: true, uniqueness: true

  default_scope { order :name }

  def to_key
    name.underscore.gsub(' ','_').to_sym
  end
end
