# frozen_string_literal: true

class JobappsMailerPreview < ActionMailer::Preview
  include FactoryBot::Syntax::Methods

  def application_denial
    submission = build(:application_submission, rejection_message: "We don't want to hire you")
    JobappsMailer.application_denial(submission)
  end

  def application_notification
    subscription = build(:subscription)
    applicant = build(:user)
    JobappsMailer.application_notification(subscription, subscription.position, applicant)
  end

  def interview_confirmation
    interview = build(:interview)
    JobappsMailer.interview_confirmation(interview)
  end

  def interview_reschedule
    interview = build(:interview)
    JobappsMailer.interview_reschedule(interview)
  end

  def saved_application_notification
    submission = build(:application_submission, created_at: 10.days.ago, note_for_later: "We're not ready.")
    JobappsMailer.saved_application_notification(submission)
  end

  def saved_applications_notification
    user = build(:user, :staff)
    submissions =
      build_list(:application_submission, 3, created_at: 10.days.ago, note_for_later: "We're not at all ready.")
    JobappsMailer.saved_applications_notification(submissions.group_by(&:position), user.email)
  end

  def send_note_for_later
    submission = build(:application_submission, note_for_later: 'You just have to wait.')
    JobappsMailer.send_note_for_later(submission)
  end
end
