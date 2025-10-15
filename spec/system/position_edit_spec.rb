# frozen_string_literal: true

require 'rails_helper'

describe 'editing positions' do
  subject(:save) { click_on 'Save changes' }

  let(:position) { create(:position, name: 'A position') }

  before do
    when_current_user_is :staff
    visit edit_position_path(position)
  end

  context 'with required fields filled in' do
    before do
      within 'form.edit_position' do
        fill_in_fields_for Position, attributes: { name: 'The name changed!' }
      end
    end

    it 'changes the desired field' do
      expect { save }.to(change { position.reload.name })
    end

    it 'redirects to the dashboard' do
      save
      expect(page).to have_current_path(staff_dashboard_path)
    end

    it 'renders a positive flash message' do
      save
      expect(page).to have_text('Position successfully updated.')
    end
  end

  context 'with required fields not filled in' do
    before do
      within 'form.edit_position' do
        fill_in_fields_for Position, attributes: { name: '' }
      end
    end

    it 'changes nothing' do
      expect { save }.not_to(change { position.reload.name })
    end

    it 'redirects to the same page' do
      save
      expect(page).to have_current_path(edit_position_path(position))
    end

    it 'renders a negative flash message' do
      save
      expect(page).to have_css('#errors', text: "Name can't be blank")
    end
  end
end
