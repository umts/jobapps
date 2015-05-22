class QuestionsController < ApplicationController

  def create
    params.require(:question).permit!
    question = Question.create params[:question]
    if question.errors
      flash[:errors] = question.errors.full_messages
    end
    redirect_to :back
  end

  def move
    params.require :id
    params.require :direction
    question = Question.find params[:id]
    question.move params[:direction].to_sym
    redirect_to :back
  end

  def update
    params.require :id
    params.require(:question).permit!
    question = Question.find params[:id]
    if question.update params[:question]
      flash[:message] = 'Question was successfully updated.'
    else
      flash[:errors] = question.errors.full_messages
    end
    redirect_to :back
  end

end
