class ApplicationTemplatesController < ApplicationController

  before_action :find_template
  
  def edit
  end

  def show
  end

  private

  def find_template
    @template = ApplicationTemplate.find(params.fetch(:id))
  end

end
