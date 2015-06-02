class SiteTextsController < ApplicationController
  before_action :find_site_text, except: :request_new

  #Accepts GET and POST - the latter shows a preview
  def edit
    params.permit  :preview_input
    @preview_input = params[:preview_input]
  end
  
  def update
    if @site_text.update site_text_parameters
      flash[:message] = 'Text was successfully updated.'
      redirect_to staff_dashboard_path
    else show_errors @site_text
    end
  end

  def request_new
    if request.post? #if get, renders default view
      params.require :location
      params.require :description
      #TODO: email IT
      flash[:message] = 'Your request has been sent. Thank you!'
      redirect_to staff_dashboard_path
    end
  end

  private

  def find_site_text
    params.require :id
    @site_text = SiteText.find params[:id]
  end

  def site_text_parameters
    params.require(:site_text).permit :text
  end
end
