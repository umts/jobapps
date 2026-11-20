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
    replace_questions question_data if question_data.present?
    errors.none? && save
  end

  private

  def replace_questions(question_data)
    transaction do
      questions.destroy_all
      question_data.reject { |question_attributes| blank_question? question_attributes }
                   .each.with_index(1) do |question_attributes, number|
                     questions.create question_attributes.merge(number:)
                   end
      raise ActiveRecord::Rollback if questions.any? { |question| question.errors.any? }
    end
    add_question_errors
  end

  # The empty row the edit page adds for a new question, or the hidden id a removed row leaves behind
  def blank_question?(question_attributes)
    question_attributes.values_at(:prompt, :data_type).all?(&:blank?)
  end

  def add_question_errors
    questions.each do |question|
      question.errors.each { |error| errors.add :base, "Question #{question.number}: #{error.full_message}" }
    end
  end

  def new_question_number
    (questions.last&.number || 0) + 1
  end
end
