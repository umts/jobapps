class UsersController < ApplicationController
  before_action :find_user, only: [:destroy, :edit, :update]

  def create
    deny_access and return unless @current_user.admin?
    @user = User.new user_parameters
    if @user.save
      show_message :user_create,
                   default: 'User has been created.'
      redirect_to staff_dashboard_path
    else show_errors @user
    end
  end

  def destroy
    deny_access and return unless @current_user.admin?
    @user.destroy
    show_message :user_destroy,
                 default: 'User has been removed.'
    redirect_to staff_dashboard_path
  end

  def edit
  end

  def new
  end

  def update
    deny_access and return unless @current_user.admin?
    if @user.update user_parameters
      show_message :user_update,
                   default: 'User has been updated.'
      redirect_to staff_dashboard_path
    else show_errors @user
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
end
