class DashboardController < ApplicationController
  before_action :application_templates

  def main
    if @current_user.staff?
      redirect_to staff_dashboard_path
    else
      redirect_to student_dashboard_path
    end
  end

  def staff
    @pending_records = ApplicationRecord.pending.by_user_name.group_by(&:department)
  end

  def student
  end

  private

  def application_templates
    @application_templates = ApplicationTemplate.by_department
  end

end
