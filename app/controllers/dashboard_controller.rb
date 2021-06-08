# frozen_string_literal: true

class DashboardController < ApplicationController
  skip_before_action :access_control, only: %i[main student]
  before_action :positions, except: :main

  def main
    if @current_user.present? && @current_user.staff?
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
    @saved_interviews = Array.new
    Interview.where(saved_for_later: true).each do |interview|
      @saved_interviews.push(ApplicationSubmission.find(interview.application_submission_id)) if interview.saved_for_later
    end
    @saved_interviews = @saved_interviews.group_by(&:position)
    @staff = User.staff
    @templates = ApplicationTemplate.all.group_by(&:position)
  end

  def student
    return if @current_user.blank?

    @application_submissions = @current_user.application_submissions
                                            .group_by(&:position)
    @interviews = @current_user.interviews
  end

  private

  def positions
    @positions = Position.all.group_by(&:department)
  end
end
