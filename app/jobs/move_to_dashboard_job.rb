# frozen_string_literal: true

class MoveToDashboardJob < ApplicationJob
  def perform
    ApplicationSubmission.move_to_dashboard
  end
end
