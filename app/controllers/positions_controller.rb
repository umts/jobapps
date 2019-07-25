# frozen_string_literal: true

class PositionsController < ApplicationController
  before_action :find_position, only: %i[destroy
                                         edit
                                         update
                                         saved_applications]

  def create
    @position = Position.new position_parameters
    if @position.save
      show_message :position_create, default: 'Position has been created.'
      redirect_to staff_dashboard_path
    else show_errors @position
    end
  end

  def destroy
    @position.destroy
    show_message :position_destroy, default: 'Position has been deleted.'
    redirect_to staff_dashboard_path
  end

  def saved_applications
    @saved = @position.application_submissions.where(saved_for_later: true)
  end

  def edit
    @subscriptions = Subscription.where user: @current_user,
                                        position: @position
  end

  def new; end

  def update
    if @position.update position_parameters
      show_message :position_update, default: 'Position has been updated.'
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
    params.require(:position).permit :default_interview_location,
                                     :department_id,
                                     :name,
                                     :not_hiring_text
  end
end
