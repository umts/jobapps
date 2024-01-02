# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :find_user, only: %i[destroy edit update]
  before_action :allow_only_admin

  def create
    @user = User.new user_parameters
    if @user.save
      show_message :user_create,
                   default: 'User has been created.'
      redirect_to staff_dashboard_path
    else
      show_errors @user
    end
  end

  def destroy
    @user.destroy
    show_message :user_destroy,
                 default: 'User has been removed.'
    redirect_to staff_dashboard_path
  end

  def edit; end

  def new; end

  def update
    if @user.update user_parameters
      show_message :user_update,
                   default: 'User has been updated.'
      redirect_to staff_dashboard_path
    else
      show_errors @user
    end
  end

  def promote
    @users = User.where.not(staff: true)
                 .pluck(:first_name, :last_name, :spire)
                 .map do |first_name, last_name, spire|
      "#{first_name} #{last_name} #{spire}"
    end
  end

  def promote_save
    user = User.find_by(spire: params[:user].split.last)
    if user.nil?
      redirect_to promote_users_path
    elsif user.update(staff: true)
      show_message :user_update,
                   default: 'User has been updated.'
      redirect_to promote_users_path
    end
  end

  private

  def find_user
    params.require :id
    @user = User.find params[:id]
  end

  def user_parameters
    params.require(:user).permit :email,
                                 :first_name,
                                 :last_name,
                                 :spire,
                                 :staff
  end

  def allow_only_admin
    deny_access and return unless @current_user.admin?
  end
end
