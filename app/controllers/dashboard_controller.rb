class DashboardController < ApplicationController
  before_action :application_templates

  def staff
  end

  def student
  end

  private

  def application_templates
    @application_templates = ApplicationTemplate.order :department
  end

end
