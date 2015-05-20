class DashboardController < ApplicationController

  def staff
    @application_templates = ApplicationTemplate.order :department
    @site_texts = SiteText.order :name
  end

  def student
  end

end
