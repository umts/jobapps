# frozen_string_literal: true

class Interview < ApplicationRecord
  belongs_to :user
  belongs_to :application_submission
  delegate :department,
           :position,
           to: :application_submission

  validates :completed, :hired, inclusion: { in: [true, false], message: :true_false }
  validates :location, :scheduled, presence: true
  validates :application_submission_id, uniqueness: true

  after_create :send_confirmation
  after_update :resend_confirmation

  default_scope { order :scheduled }
  scope :pending, lambda {
                    joins(:application_submission).where(interviews: { completed: false },
                                                         application_submission: { saved_for_later: false })
                  }

  def calendar_title
    "Interview with #{user.full_name}"
  end

  # Looks bad to rubocop because of all the method calls, but it's
  # really just a builder pattern
  # rubocop:disable Metrics/AbcSize
  def ical
    Icalendar::Calendar.new.tap do |cal|
      cal.prodid = '-//UMASS_TRANSIT_JOBAPPS//INTERVIEW_EXPORT//EN'
      cal.publish

      event = Icalendar::Event.new.tap do |e|
        e.dtstart = scheduled.to_fs :ical
        e.description = application_submission.url
        e.summary = calendar_title
        e.uid = "INTERVIEW#{id}@UMASS_TRANSIT//JOBAPPS"
        e.dtstamp = created_at.to_fs :ical
        e.status = 'CONFIRMED'
      end
      cal.add_event event
    end
  end
  # rubocop:enable Metrics/AbcSize

  def information(options = {})
    info = "#{scheduled.to_fs :long_with_time} at #{location}"
    info += ": #{user.proper_name}" if options.key? :include_name
    info
  end

  def pending?
    !completed
  end

  private

  def resend_confirmation
    return unless saved_change_to_location? || saved_change_to_scheduled?

    JobappsMailer.interview_reschedule(self).deliver_now
  end

  def send_confirmation
    JobappsMailer.interview_confirmation(self).deliver_now
  end
end
