class UsersController < ApplicationController

  before_action :find_user, only: [:destroy, :edit, :update]

  def create
    @user = User.create user_parameters
    if @user
      flash[:message] = "#{user.full_name} has been added as a staff member."
      redirect_to root_path
    else show_errors
    end
  end

  def destroy
    @user.destroy
    flash[:message] = "#{@user.full_name} has been deleted as a staff member."
    redirect_to root_path
  end
   
  def edit
  end

  def new
  end

  def update
    if @user.update user_parameters
      flash[:message] = "#{@user.full_name} has been updated."
      redirect_to root_path
    else show_errors
    end
  end

  private

  def find_user
    params.require :id
    @user = User.find params[:id]
  end

  def show_errors
    flash[:errors] = @user.errors.full_messages
    redirect_to :back
  end

  def user_parameters
    params.require(:user).permit :email,
                                 :first_name,
                                 :last_name,
                                 :spire,
                                 :staff
  end

end
