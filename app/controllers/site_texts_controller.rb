class SiteTextsController < ApplicationController
  def request_new
    if request.post? #if get, renders default view
      params.require :location
      params.require :description
      #TODO: email IT
      flash[:message] = 'Your request has been sent. Thank you!'
    end
  end
end
