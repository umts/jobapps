# frozen_string_literal: true

class PositionsController < ApplicationController
  before_action :find_position, only: %i[destroy
                                         edit
                                         update
                                         saved_applications]

  def new
    authorize!
  end

  def edit
    authorize! @position

    @subscriptions = Subscription.where user: Current.user, position: @position
  end

  def create
    authorize!

    @position = Position.new position_parameters
    if @position.save
      flash[:message] = t('.success')
      redirect_to staff_dashboard_path
    else
      show_errors @position
    end
  end

  def update
    authorize! @position

    if @position.update position_parameters
      flash[:message] = t('.success')
      redirect_to staff_dashboard_path
    else
      show_errors @position
    end
  end

  def destroy
    authorize! @position

    @position.destroy
    flash[:message] = t('.success')
    redirect_to staff_dashboard_path
  end

  def saved_applications
    authorize! @position

    @saved = @position.application_submissions.where(saved_for_later: true).order(:created_at)
  end

  private

  def find_position
    @position = Position.find params.expect(:id)
  end

  def position_parameters
    params.expect position: %i[default_interview_location department_id name not_hiring_text]
  end
end
