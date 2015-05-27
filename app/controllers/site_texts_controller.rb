class SiteTextsController < ApplicationController
  def edit
    params.require :id
    params.permit  :preview_input
    params.permit  :preview_text
    @site_text = SiteText.find params[:id]
    @preview_input = params[:preview_input]
  end
  
  def update
    params.require(:site_text).permit!
    params.require :id
    site_text = SiteText.find params[:id] 
    if site_text.update site_text_parameters
      flash[:message] = 'Text was successfully updated.'
    else
      flash[:errors] = site_text.errors.full_messages
    end
    redirect_to :back
  end

  def request_new
    if request.post? #if get, renders default view
      params.require :location
      params.require :description
      #TODO: email IT
      flash[:message] = 'Your request has been sent. Thank you!'
    end
  end

  private

  def site_text_parameters
    params.require(:site_text).permit :text
  end
end
