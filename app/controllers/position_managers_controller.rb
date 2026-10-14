# frozen_string_literal: true

class PositionManagersController < ApplicationController
  def create
    position = Position.find params.expect(:position_id)
    @position_manager = position.position_managers.new params.expect(position_manager: [:user_id])
    authorize! @position_manager
    if @position_manager.save
      flash[:message] = t('.success')
      redirect_back_or_to edit_position_path(position)
    else
      show_errors @position_manager
    end
  end

  def destroy
    @position_manager = PositionManager.find params.expect(:id)
    authorize! @position_manager
    @position_manager.destroy
    flash[:message] = t('.success')
    redirect_back_or_to edit_position_path(@position_manager.position)
  end
end
