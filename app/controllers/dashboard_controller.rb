# frozen_string_literal: true

class DashboardController < ApplicationController
  def main
    authorize!
    if allowed_to?(:staff?, :dashboard)
      redirect_to staff_dashboard_path
    else
      redirect_to student_dashboard_path
    end
  end

  def staff
    authorize!
    @positions = authorized_scope(Position.all)
    @pending_interviews = Interview.pending.where(application_submission: { position: @positions })
                                   .group_by(&:position)
    @pending_records = ApplicationSubmission.in_positions(@positions).where(saved_for_later: false)
                                            .pending.newest_first
                                            .group_by(&:position)
    @saved_records = ApplicationSubmission.in_positions(@positions).where(saved_for_later: true)
                                          .group_by(&:position)
    @templates = ApplicationTemplate.where(position: @positions).group_by(&:position)
  end

  def student
    authorize!
    @positions = Position.all
    return if Current.user.blank?

    @application_submissions = Current.user.application_submissions.group_by(&:position)
    @interviews = Current.user.interviews
  end
end
