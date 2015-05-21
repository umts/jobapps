class ApplicationTemplatesController < ApplicationController

  before_action :find_template
  
  def edit
  end

  def show
  end

  private

  def find_template
    params.require :id
    @template = ApplicationTemplate.find params[:id]
  end

end
