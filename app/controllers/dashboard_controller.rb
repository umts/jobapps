class DashboardController < ApplicationController
  skip_before_action :access_control, only: [:main, :student]
  before_action :positions, except: :main

  def main
    if @current_user.staff?
      redirect_to staff_dashboard_path
    else
      redirect_to student_dashboard_path
    end
  end

  def staff
    @departments = Department.includes :positions
    @pending_records = ApplicationRecord.pending.by_user_name.group_by &:position
    @pending_interviews = Interview.pending.group_by &:position
    @site_texts = SiteText.order :name
    @staff = User.staff
  end

  def student
    @interviews = @current_user.interviews
    @application_records = @current_user.application_records.pending.group_by &:position
  end

  private

  def positions
    @positions = Position.all.group_by &:department
  end

end
