# frozen_string_literal: true

class ApplicationDraft < ApplicationRecord
  has_many :questions, dependent: :destroy
  accepts_nested_attributes_for :questions
  belongs_to :application_template
  belongs_to :user
  delegate :position, to: :application_template

  validates :application_template, uniqueness: { scope: :user_id }

  def new_question
    Question.new application_draft: self, number: new_question_number
  end

  def update_application_template!
    application_template.update attributes.except('application_template_id', 'user_id', 'id')
    application_template.questions.delete_all
    # We know it does.
    # rubocop:disable-next Rails/SkipsModelValidations
    questions.update_all application_template_id: application_template.id,
                         application_draft_id: nil
    delete
  end

  def update_questions(question_data)
    return if question_data.blank?

    transaction do
      questions.destroy_all
      question_data.each do |question_attributes|
        questions.create question_attributes.merge(number: questions.count + 1)
      end
    end
  end

  private

  def new_question_number
    (questions.last&.number || 0) + 1
  end
end
