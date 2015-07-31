class ApplicationTemplateDraft < ActiveRecord::Base
  has_many :questions, dependent: :destroy
  accepts_nested_attributes_for :questions
  belongs_to :application_template
  belongs_to :user
  delegate :position, to: :application_template
  
  validates :application_template, uniqueness: { scope: :user_id }
  validates :application_template, :user, presence: true

  def move_question(question_number, direction)
    transaction do
      question = questions.find_by number: question_number
      other_number = case direction
                     when :up   then question_number - 1
                     when :down then question_number + 1
                     end
      other_question = questions.find_by number: other_number
      return unless other_question
      # Move the specified field without validation, since before we move
      # the other field out of its place, it will be invalid.
      question.number = other_number
      question.save validate: false
      other_question.update number: question_number
      # Validate it afterwards, and do nothing if there is an error.
      raise ActiveRecord::Rollback unless question.valid?
    end
  end

  def new_question
    Question.new application_template_draft: self, number: new_question_number
  end

  def remove_question(question_number)
    question_to_remove = questions.find_by number: question_number
    question_to_remove.delete
    questions.where('number > ?', question_number).find_each do |question|
      question.number -=1
      question.save
    end
    save
    question_to_remove
  end

  def update_questions(question_data)
    return if question_data.blank?
    question_data.each do |_index, question_attributes|
      question = questions.find_by number: question_attributes.fetch(:number)
      if question.present?
        question.update question_attributes
      else
        question_attributes.merge! application_template_draft_id: id
        Question.create question_attributes
      end
    end
  end
  
  private

  def new_question_number
    questions.last.number + 1
  end
end
