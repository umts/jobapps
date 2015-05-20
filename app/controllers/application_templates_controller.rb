class ApplicationTemplatesController < ApplicationController
  
  def edit
    @template = ApplicationTemplate.find(params.fetch(:id))
  end

end
