# frozen_string_literal: true

class MarkdownController < ApplicationController
  def explanation
    params.permit :preview_input
    @preview_input = params[:preview_input]
  end
end
