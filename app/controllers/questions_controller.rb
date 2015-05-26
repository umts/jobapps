class QuestionsController < ApplicationController

  def create
    params.require(:question).permit!
    question = Question.create question_parameters
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
    if question.update question_parameters
      flash[:message] = 'Question was successfully updated.'
    else
      flash[:errors] = question.errors.full_messages
    end
    redirect_to :back
  end

  private

  def question_parameters
    params.require(:question).permit :application_template_id,
                                     :data_type,
                                     :name,
                                     :number,
                                     :prompt,
                                     :required
  end

end
