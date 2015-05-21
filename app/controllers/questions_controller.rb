class QuestionsController < ApplicationController

  def create
    params.require(:question).permit!
    Question.create!(params[:question])
    redirect_to :back
  end

  def move
    #require the ID parameter
    #require the direction parameter
    #find the question by its ID
    #use the model method on that question to move it in the direction specified
    #redirect to the previous page
  end

  def update
    params.require(:id)
    params.require(:question).permit!
    question = Question.find(params[:id])
    question.update_attributes!(params[:question])
    redirect_to :back
  end

end
