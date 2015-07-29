class ApplicationTemplateDraft < ActiveRecord::Base
  has_many :questions, dependent: :destroy
  accepts_nested_attributes_for :questions
  belongs_to :application_template
  belongs_to :user
  delegate :position, to: :application_template
  
  validates :application_template, uniqueness: { scope: :user_id }
  validates :application_template, :user, presence: true

  def new_question
    Question.new application_template_draft: self, number: new_question_number
  end
end
