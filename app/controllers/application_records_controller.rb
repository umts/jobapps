class ApplicationRecordsController < ApplicationController

  def create
    params.require :responses
    record = ApplicationRecord.create(responses: params[:responses],
                                      user: current_user)
    redirect_to record #if staff, if not go to the thank you page or something
  end

  def show
    params.require :id
    @record = ApplicationRecord.find params[:id]
  end

end
