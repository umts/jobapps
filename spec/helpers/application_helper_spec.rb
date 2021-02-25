# frozen_string_literal: true

require 'rails_helper'

describe ApplicationHelper do
  describe 'render_markdown' do
    before :each do
      @before_markdown_input = '**Bold**'
      @bold_tag = '<strong>'
    end
    it 'renders markdown for bold text properly' do
      expect(render_markdown @before_markdown_input).to include @bold_tag
    end
  end
end
