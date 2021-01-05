# frozen_string_literal: true

class MarkdownsController < ApplicationController	
  def explanation; end

  def edit
    params.permit :preview_input
    @preview_input = params[:preview_input]
  end
  
end