# frozen_string_literal: true

# :nocov: — no meaningful test without mocking; cover this once jobs are tested for real.
class MoveToDashboardJob < ApplicationJob
  def perform
    ApplicationSubmission.move_to_dashboard
  end
end
# :nocov:
