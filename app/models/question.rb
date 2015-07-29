class Question < ActiveRecord::Base
  belongs_to :application_template
  belongs_to :application_template_draft

  DATA_TYPES = %w(text
                  number
                  yes/no
                  date
                  heading
                  explanation)

  validate :belongs_to_application_template_or_draft?

  validates :data_type,
            :number,
            :prompt,
            presence: true
  validates :required, inclusion: { in: [true, false],
                                    message: 'must be true or false' }
  # No questions in one application template with the same number
  validates :number, uniqueness: { scope: :application_template,
                                   allow_blank: true }
  validates :number, uniqueness: { scope: :application_template_draft,
                                   if: -> { application_template_draft.present? } } 

  default_scope { order :number }
  scope :not_new, -> { where.not id: nil }

  def date?
    data_type == 'date'
  end

  def explanation?
    data_type == 'explanation'
  end

  def heading?
    data_type == 'heading'
  end

  # Within a particular application template, moves a question up or down.
  # Accepts the symbol :up or the symbol :down as arguments.

  # Using self to be explicit, so disable rubocop warning.
  # rubocop:disable Style/RedundantSelf
  def move(direction)
    case direction
    when :up
      other_number = self.number - 1
    when :down
      other_number = self.number + 1
    end
    questions = application_template.questions
    other_question = questions.find_by number: other_number
    ActiveRecord::Base.transaction do
      raise ActiveRecord::Rollback unless other_question.present?
      other_question.number = self.number
      self.number = other_number
      self.save validate: false
      other_question.save
      # Since we skipped validations in order to save, re-run validations.
      # If the question fails, raise an exception.
      # The exception does not propagate further up the stack.
      # No need to handle it elsewhere or raise any specific exception.
      raise ActiveRecord::Rollback unless self.valid?
    end
  end
  # rubocop:enable Style/RedundantSelf

  private

  # must have app temp or app temp draft, but not both
  def belongs_to_application_template_or_draft?
    return if application_template.present? ^ application_template_draft.present?
    errors.add :base,
               'You must specify either an application template or a draft, but not both'
  end
end
