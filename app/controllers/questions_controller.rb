class QuestionsController < ApplicationController
  before_action :find_question, except: :create

  def create
    question = Question.new question_parameters
    if question.save
      show_message :question_create,
        default: 'Question was successfully updated.'
      redirect_to :back
    else show_errors question
    end

  end

  def destroy
    @question.destroy
    show_message :question_destroy,
      default: 'Question was succesfully removed.'
    redirect_to :back
  end

  def move
    params.require :direction
    @question.move params[:direction].to_sym
    redirect_to :back
  end

  def update
    if @question.update question_parameters
      show_message :question_update,
        default: 'Question was successfully updated.'
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
