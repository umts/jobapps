class DashboardController < ApplicationController

  def staff
    @application_templates = ApplicationTemplate.order :department
  end

  def student
  end

end
