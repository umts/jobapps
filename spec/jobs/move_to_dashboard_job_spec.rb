# frozen_string_literal: true

require 'rails_helper'

describe MoveToDashboardJob do
  describe '#perform' do
    subject(:perform) { described_class.perform_now }

    it 'moves saved-for-later submissions to the dashboard' do
      allow(ApplicationSubmission).to receive(:move_to_dashboard)
      perform
      expect(ApplicationSubmission).to have_received(:move_to_dashboard)
    end
  end
end
