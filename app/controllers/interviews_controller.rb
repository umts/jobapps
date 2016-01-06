class InterviewsController < ApplicationController
  before_action :find

  def complete
    if @interview.update completed: true
      show_message :interview_complete,
                   default: 'Interview marked as completed.'
      if params[:hired]
        @interview.update hired: true
      else
        @interview.update hired: false,
                          interview_note: params[:interview_note]
      end
      # TODO: some kind of API call to create users.
      redirect_to staff_dashboard_path
    else show_errors @interview
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
    else show_errors @interview
    end
  end

  def show
    respond_to do |format|
      format.ics do
        render 'interview.ics', layout: false
      end
    end
  end

  private

  def find
    params.require :id
    @interview = Interview.find params[:id]
  end
end
