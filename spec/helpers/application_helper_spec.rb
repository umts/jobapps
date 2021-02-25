# frozen_string_literal: true

require 'rails_helper'

describe ApplicationHelper do
  describe 'parse_unavailability' do
    let :input do
      { 'sunday_7AM' => '0', 'sunday_8AM' => '0', 'tuesday_11AM' => '1',
        'tuesday_12AM' => '1', 'friday_4PM' => '1', 'friday_5PM' => '0' }
    end
    let(:output) { parse_unavailability input }
    it 'does not select days that have no unavailabilities' do
      expect(output.keys).not_to include :sunday
    end
    it 'does select days that have unavailabilities' do
      expect(output.keys).to include :friday
    end
    it 'does not select available times on days with other unavailabilities' do
      expect(output[:friday]).not_to include '5PM'
    end
    it 'does select times on days with unavailabilities properly' do
      expect(output[:friday]).to include '4PM'
    end
  end

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
