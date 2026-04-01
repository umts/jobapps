# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :find_user, only: %i[destroy edit update]
  before_action :allow_only_admin

  def new; end
  def edit; end

  def create
    @user = User.new user_parameters
    if @user.save
      flash[:message] = t('.success')
      redirect_to staff_dashboard_path
    else
      show_errors @user
    end
  end

  def update
    if @user.update user_parameters
      flash[:message] = t('.success')
      redirect_to staff_dashboard_path
    else
      show_errors @user
    end
  end

  def destroy
    @user.destroy
    flash[:message] = t('.success')
    redirect_to staff_dashboard_path
  end

  def promote
    @users = User.where.not(staff: true)
                 .pluck(:first_name, :last_name, :spire)
                 .map { |attrs| attrs.join(' ') }
  end

  def promote_save
    user = User.find_by(spire: params[:user].split.last)
    if user.nil?
      redirect_to promote_users_path
    elsif user.update(staff: true)
      flash[:message] = t('.success')
      redirect_to promote_users_path
    end
  end

  private

  def find_user
    params.require :id
    @user = User.find params[:id]
  end

  def user_parameters
    params.expect user: %i[email first_name last_name spire staff]
  end

  def allow_only_admin
    deny_access and return unless Current.user&.admin?
  end
end
