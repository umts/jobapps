# frozen_string_literal: true

class DashboardController < ApplicationController
  skip_before_action :access_control, only: %i[main student]
  before_action :positions, except: :main

  def main
    if Current.user.presence&.staff?
      redirect_to staff_dashboard_path
    else
      redirect_to student_dashboard_path
    end
  end

  def staff
    @departments = Department.includes :positions
    @pending_interviews = Interview.pending.group_by(&:position)
    @pending_records = ApplicationSubmission.where(saved_for_later: false)
                                            .pending.newest_first
                                            .group_by(&:position)
    @saved_records = ApplicationSubmission.where(saved_for_later: true)
                                          .group_by(&:position)
    @staff = User.staff
    @templates = ApplicationTemplate.all.group_by(&:position)
  end

  def student
    return if Current.user.blank?

    @application_submissions = Current.user.application_submissions.group_by(&:position)
    @interviews = Current.user.interviews
  end

  private

  def positions
    @positions = Position.all.group_by(&:department)
  end
end
