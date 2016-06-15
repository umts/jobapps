class UsersController < ApplicationController
  before_action :find_user, only: [:destroy, :edit, :update]
  before_action :allow_only_admin

  def create
    @user = User.new user_parameters
    if @user.save
      show_message :user_create,
                   default: 'User has been created.'
      redirect_to staff_dashboard_path
    else show_errors @user
    end
  end

  def destroy
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

  # rubocop:disable Style/AndOr
  def allow_only_admin
    deny_access and return unless @current_user.admin?
  end
  # rubocop:enable Style/AndOr
end
