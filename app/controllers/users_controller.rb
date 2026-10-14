# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :find_user, only: %i[destroy edit update]

  def new
    authorize!
  end

  def edit
    authorize! @user
  end

  def create
    authorize!
    @user = User.new user_parameters
    if @user.save
      flash[:message] = t('.success')
      redirect_to staff_dashboard_path
    else
      show_errors @user
    end
  end

  def update
    authorize! @user
    if @user.update user_parameters
      flash[:message] = t('.success')
      redirect_to staff_dashboard_path
    else
      show_errors @user
    end
  end

  def destroy
    authorize! @user
    @user.destroy
    flash[:message] = t('.success')
    redirect_to staff_dashboard_path
  end

  private

  def find_user
    @user = User.find params.expect(:id)
  end

  def user_parameters
    params.expect user: %i[email first_name last_name entra_uid]
  end
end
