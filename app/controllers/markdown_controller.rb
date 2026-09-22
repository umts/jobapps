# frozen_string_literal: true

class MarkdownController < ApplicationController
  before_action :authorize!

  def explanation
    params.permit :preview_input
    @preview_input = params[:preview_input]
  end
end
