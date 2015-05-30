class QuestionsController < ApplicationController
  before_action :find_question, except: :create

  def create
    question = Question.create question_parameters
    if question
      flash[:message] = 'Question was successfully created.'
      redirect_to :back
    else show_errors question
    end

  end

  def destroy
    @question.destroy
    flash[:message] = 'Question was successfully removed.'
    redirect_to :back
  end

  def move
    params.require :direction
    @question.move params[:direction].to_sym
    redirect_to :back
  end

  def update
    if @question.update question_parameters
      flash[:message] = 'Question was successfully updated.'
      redirect_to :back
    else show_errors @question
    end
  end

  private

  def find_question
    params.require :id
    @question = Question.find params[:id]
  end

  def question_parameters
    params.require(:question).permit :application_template_id,
                                     :data_type,
                                     :name,
                                     :number,
                                     :prompt,
                                     :required
  end

end
