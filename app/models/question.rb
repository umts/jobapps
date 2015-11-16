class Question < ActiveRecord::Base
  belongs_to :application_template
  belongs_to :application_draft

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
                                   if: -> { application_template.present? } }
  validates :number,
            uniqueness: { scope: :application_draft,
                          if: -> { application_draft.present? } }

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

  def takes_placeholder?
    %w(text date).include? data_type
  end

  def unique_prompt_name
    "prompt_#{number - 1}"
  end

  def unique_name
    "response_#{number - 1}"
  end

  private

  # must have app temp or app temp draft, but not both
  def belongs_to_application_template_or_draft?
    template = application_template
    draft = application_draft
    return if template.present? ^ draft.present?
    errors.add :base,
               'You must specify either an application template or a draft,
                 but not both'
  end
end
