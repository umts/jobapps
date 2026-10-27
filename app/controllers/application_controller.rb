# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include UMTS::Auth::Controller

  layout 'umts/brand/public'

  def show_errors(object)
    flash[:errors] = object.errors.full_messages
    redirect_back_or_to root_path
  end

  protected

  def flash_success_for(subject, action = nil) = flash_success(flash, subject, action)

  def flash_errors_for(subject) = flash_errors(flash, subject)

  def flash_errors_now_for(subject) = flash_errors(flash.now, subject)

  private

  def flash_success(flash, subject, action)
    flash[:notice] = success_message_for(subject, action)
  end

  def flash_errors(flash, subject)
    flash[:alert] = subject.errors.full_messages.to_sentence
  end

  def success_message_for(subject, action)
    subject = subject.model_name.human.downcase if subject.respond_to?(:model_name)
    action ||= action_name
    t('success.message', action: t("success.actions.#{action}"), subject:)
  end
end
