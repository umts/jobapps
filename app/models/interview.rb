class Interview < ActiveRecord::Base
  belongs_to :user

  validates :hired, inclusion: {in: [true, false], message: 'must be true or false'}
  validates :scheduled,
            :user,
             presence: true
end
