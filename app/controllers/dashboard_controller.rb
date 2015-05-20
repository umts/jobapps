class DashboardController < ApplicationController
  before_action :find_user

  def staff
  end

  def student
  end

  private

  def find_user
    @user = User.find(session[:user_id])
  end
end
