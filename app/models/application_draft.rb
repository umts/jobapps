# frozen_string_literal: true

class ApplicationDraft < ApplicationRecord
  has_many :questions, dependent: :destroy
  accepts_nested_attributes_for :questions
  belongs_to :application_template
  belongs_to :user
  delegate :position, to: :application_template

  validates :application_template, uniqueness: { scope: :user_id }

  def move_question(question_number, direction)
    transaction do
      question = questions.find_by number: question_number
      other_number = case direction
                     when :up   then question_number - 1
                     when :down then question_number + 1
                     end
      other_question = questions.find_by number: other_number
      return unless other_question

      # Temporarily set number to 0 to avoid unique index conflicts
      question.update(number: 0)
      other_question.update(number: question_number)
      question.update(number: other_number)
    end
  end

  def new_question
    Question.new application_draft: self, number: new_question_number
  end

  def remove_question(question_number)
    question_to_remove = questions.find_by number: question_number
    question_to_remove.delete
    questions.where('number > ?', question_number).find_each do |question|
      question.number -= 1
      question.save
    end
    save
    question_to_remove
  end

  def update_application_template!
    application_template.update(attributes.except 'application_template_id',
                                                  'user_id', 'id')
    application_template.questions.delete_all
    # We know it does.
    # rubocop:disable Rails/SkipsModelValidations
    questions.update_all application_template_id: application_template.id,
                         application_draft_id: nil
    # rubocop:enable Rails/SkipsModelValidations
    delete
  end

  def update_questions(question_data)
    return if question_data.blank?

    transaction do
      questions.destroy_all
      question_data.each do |question_attributes|
        questions.create question_attributes
      end
    end
  end

  private

  def new_question_number
    (questions.last&.number || 0) + 1
  end
end
