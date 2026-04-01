# frozen_string_literal: true

require 'rails_helper'

describe ApplicationHelper do
  describe 'render_markdown' do
    let(:input) { '**Bold**' }
    let(:output) { '<strong>' }

    it 'renders markdown for bold text properly' do
      expect(render_markdown(input)).to include(output)
    end
  end
end
