class ApplicationTemplate < ActiveRecord::Base
  has_many :questions, dependent: :destroy
  has_many :drafts, class_name: ApplicationDraft,
                    foreign_key: :application_template_id,
                    dependent: :destroy
  accepts_nested_attributes_for :questions

  belongs_to :position
  delegate :department, to: :position

  validates :position, presence: true

  def create_draft(user)
    return false if draft_belonging_to?(user)
    draft_attributes = attributes.except('id', 'position_id')
                       .merge user: user,
                              application_template: self
    draft = ApplicationDraft.create draft_attributes
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
end
