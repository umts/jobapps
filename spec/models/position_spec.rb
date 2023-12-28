# frozen_string_literal: true

require 'rails_helper'

describe Position do
  describe 'name_and_department' do
    before do
      @position = create(:position)
    end

    it 'includes the name of the position' do
      expect(@position.name_and_department).to include @position.name
    end

    it 'includes the department of the position' do
      expect(@position.name_and_department).to include @position.department.name
    end
  end
end
