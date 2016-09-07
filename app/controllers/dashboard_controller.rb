class DashboardController < ApplicationController
  skip_before_action :access_control, only: [:main, :student]
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
    @pending_records = ApplicationRecord.where(saved_for_later: false).pending.newest_first
                                        .group_by(&:position)
    @site_texts = SiteText.order :name
    @staff = User.staff
    @templates = ApplicationTemplate.all.group_by(&:position)
  end

  def student
    if @current_user.present?
      @application_records = @current_user.application_records
                                          .group_by(&:position)
      @interviews = @current_user.interviews
    end
  end

  private

  def positions
    @positions = Position.all.group_by(&:department)
  end
end
