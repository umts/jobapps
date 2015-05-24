class InterviewsController < ApplicationController
  
  def create
    params.require(:interview).permit!
    interview = Interview.create params[:interview]
    if interview
      interview.application_record.update reviewed: true
      flash[:message] = 'Interview has been scheduled and application marked as reviewed.'
      redirect_to staff_dashboard_path
    else
      flash[:errors] = interview.errors.full_messages
      redirect_to :back
    end
  end

  def show
    params.require :id
    @interview = Interview.find params[:id]
  end

end
