class Interview < ActiveRecord::Base
  belongs_to :user

  validates :hired, inclusion: {in: [true, false]}
  validates :scheduled,
            :user,
             presence: true
end
