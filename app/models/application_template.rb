# frozen_string_literal: true

class ApplicationTemplate < ApplicationRecord
  extend FriendlyId
  friendly_id :department_and_position, use: :slugged

  has_many :questions, dependent: :destroy
  has_one :draft, class_name: 'ApplicationDraft', dependent: :destroy,
                  inverse_of: :application_template
  accepts_nested_attributes_for :questions

  belongs_to :position
  delegate :department, to: :position

  validates :position, presence: true, uniqueness: true
  validates :active, inclusion: { in: [true, false] }
  validate :just_one_draft

  def create_draft(locked_by)
    return false if draft_belonging_to? locked_by

    draft = ApplicationDraft.create application_template: self, locked_by: locked_by
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

  def draft_belonging_to?(user)
    draft.present? && draft.unlocked_for?(user)
  end

  def department_and_position
    [department.name.parameterize,
     position.name.parameterize].join('-')
  end

  def just_one_draft
    if ApplicationDraft.where(application_template: self).count > 1
      errors.add(:draft, 'Applications cannot have more than one draft')
    end
  end
end
