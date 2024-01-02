# frozen_string_literal: true

class ApplicationTemplate < ApplicationRecord
  extend FriendlyId
  friendly_id :department_and_position, use: :slugged

  has_many :questions, dependent: :destroy
  has_many :drafts, class_name: 'ApplicationDraft',
                    dependent: :destroy,
                    inverse_of: :application_template
  accepts_nested_attributes_for :questions

  belongs_to :position
  delegate :department, to: :position

  validates :position, presence: true, uniqueness: true
  validates :active, inclusion: { in: [true, false] }

  def create_draft(user)
    return false if draft_belonging_to?(user)

    draft = ApplicationDraft.create user:, application_template: self
    draft_attributes = draft.attributes.keys
    template_attributes = attributes.keys
    excluded = %w[id created_at updated_at]
    common_attributes = (template_attributes & draft_attributes) - excluded
    common_attributes = attributes.slice(*common_attributes)
    draft.update common_attributes
    questions.each do |question|
      new_question = question.dup
      new_question.assign_attributes application_template: nil,
                                     application_draft: draft
      new_question.save
    end
    draft
  end

  def draft_belonging_to(user)
    drafts.find_by user_id: user.id
  end

  def draft_belonging_to?(user)
    draft_belonging_to(user).present?
  end

  def department_and_position
    [department.name.parameterize,
     position.name.parameterize].join('-')
  end
end
