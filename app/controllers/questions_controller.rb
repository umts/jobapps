class QuestionsController < ApplicationController

  def create
    params.require(:question).permit!
    Question.create!(params[:question])
    redirect_to :back
  end

  def move
    params.require(:id)
    params.require(:direction)
    question = Question.find(params[:id])
    question.move(params[:direction].to_sym)
    redirect_to :back
  end

  def update
    params.require(:id)
    params.require(:question).permit!
    question = Question.find(params[:id])
    question.update_attributes!(params[:question])
    redirect_to :back
  end

end
