# frozen_string_literal: true

class PositionsController < ApplicationController
  before_action :find_position, only: %i[show edit update destroy saved_applications]
  before_action :initialize_position, only: %i[new create]

  def index
    authorize!
    @positions = authorized_scope(Position.all).page(params[:page])
  end

  def show
    authorize! @position
  end

  def new
    authorize! @position
  end

  def edit
    authorize! @position
  end

  def create
    @position.assign_attributes position_params
    authorize! @position
    if @position.save
      flash_success_for(@position)
      redirect_to edit_position_path(@position)
    else
      flash_errors_now_for(@position)
      render :new, status: :unprocessable_content
    end
  end

  def update
    @position.assign_attributes position_params
    authorize! @position
    if @position.save
      flash_success_for(@position)
      redirect_to edit_position_path(@position)
    else
      flash_errors_now_for(@position)
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize! @position
    if @position.destroy
      flash_success_for(@position)
      redirect_to positions_path
    else
      flash_errors_for(@position)
      redirect_to position_path(@position)
    end
  end

  def saved_applications
    authorize! @position
    @saved = @position.application_submissions.where(saved_for_later: true).order(:created_at)
  end

  private

  def find_position
    @position = Position.find params.expect(:id)
  end

  def initialize_position
    @position = Position.new
  end

  def position_params
    params.expect position: %i[name default_interview_location not_hiring_text]
  end
end
