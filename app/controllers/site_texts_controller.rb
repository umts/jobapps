class SiteTextsController < ApplicationController
  before_action :find_site_text, except: :request_new

  # Accepts GET and POST - the latter shows a preview
  def edit
    params.permit :preview_input
    @preview_input = params[:preview_input]
  end

  def update
    if @site_text.update site_text_parameters
      show_message :site_text_update,
                   default: 'Text was successfully updated.'
      redirect_to staff_dashboard_path
    else show_errors @site_text
    end
  end

  def request_new
    if request.post?
      location = params.require :location
      description = params.require :description
      JobappsMailer.site_text_request(@current_user,
                                      location,
                                      description).deliver_now
      show_message :site_text_request,
                   default: 'Your request has been sent. Thank you!'
      redirect_to staff_dashboard_path
    else render 'request_new'
    end
  end

  def show
  end

  private

  def find_site_text
    @site_text = SiteText.friendly.find(params[:id])
    raise ActiveRecord::RecordNotFound if @site_text.nil?
  end

  def site_text_parameters
    params.require(:site_text).permit :text
  end
end
