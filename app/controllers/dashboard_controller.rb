class DashboardController < ApplicationController
  before_action :positions

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
    @pending_interviews = Interview.pending.group_by &:department
  end

  def student
    @interviews = @current_user.interviews
  end

  private

  def positions
    @positions = Position.all.group_by &:department
  end

end
