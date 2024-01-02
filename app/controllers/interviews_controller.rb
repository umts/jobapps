# frozen_string_literal: true

class InterviewsController < ApplicationController
  before_action :find

  def complete
    params.permit(:hired, :interview_note)
    if @interview.update completed: true
      show_message :interview_complete,
                   default: 'Interview marked as completed.'
      if params[:hired].present?
        @interview.update hired: true
      else
        @interview.update hired: false,
                          interview_note: params[:interview_note]
      end
      redirect_to staff_dashboard_path
    else
      show_errors @interview
    end
  end

  def reschedule
    params.require :scheduled
    params.require :location
    if @interview.update scheduled: params[:scheduled],
                         location: params[:location]
      show_message :interview_reschedule,
                   default: 'Interview has been rescheduled.'
      redirect_to staff_dashboard_path
    else
      show_errors @interview
    end
  end

  def show
    respond_to do |format|
      format.ics do
        render plain: @interview.ical.to_ical, content_type: 'text/calendar'
      end
    end
  end

  private

  def find
    params.require :id
    @interview = Interview.find params[:id]
  end
end
