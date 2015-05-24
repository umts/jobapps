class DashboardController < ApplicationController
  before_action :application_templates

  def staff
    @pending_records = ApplicationRecord.pending.by_user_name.group_by(&:department)
    @pending_interviews = Interview.pending
  end

  def student
  end

  private

  def application_templates
    @application_templates = ApplicationTemplate.by_department
  end

end
