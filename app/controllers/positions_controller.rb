class PositionsController < ApplicationController
  before_action :find_position, only: [:destroy, :edit, :update]

  def create
    @position = Position.new position_parameters
    if @position.save
      flash[:message] = "Position #{@position.name_and_department} created."
      redirect_to staff_dashboard_path
    else show_errors @position
    end
  end

  def destroy
    @position.destroy
    flash[:message] = "Position #{@position.name_and_department} deleted."
    redirect_to staff_dashboard_path
  end

  def edit
  end

  def new
  end

  def update
    if @position.update position_parameters
      flash[:message] = "#{@position.name_and_department} has been updated."
      redirect_to staff_dashboard_path
    else show_errors @position
    end
  end

  private

  def find_position
    params.require :id
    @position = Position.find params[:id]
  end

  def position_parameters
    params.require(:position).permit :department_id,
                                     :name
  end
end
