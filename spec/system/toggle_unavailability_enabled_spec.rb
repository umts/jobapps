# frozen_string_literal: true

require 'rails_helper'

describe 'toggle the unavailability_enabled attribute of templates' do
  let(:application) { create(:application_template) }
  let(:draft) { create(:application_draft, application_template: application) }

  before do
    when_current_user_is :staff
  end

  context 'on editing application drafts page' do
    before do
      visit edit_draft_path(draft)
    end

    context 'unavailability is disabled' do
      let :application do
        create(:application_template, unavailability_enabled: false)
      end

      it 'has a button to enable unavailability' do
        click_button 'Activate Unavailability'
        expect(page).to have_button 'Deactivate Unavailability'
      end

      it 'puts a message in the flash' do
        click_on 'Activate Unavailability'
        expect(page).to have_text('Unavailability requests enabled on this application.')
      end
    end

    context 'unavailability is enabled' do
      let :application do
        create(:application_template, unavailability_enabled: true)
      end

      it 'has a button to disable unavailability' do
        click_button 'Deactivate Unavailability'
        expect(page).to have_button 'Activate Unavailability'
      end

      it 'puts a message in the flash' do
        click_on 'Deactivate Unavailability'
        expect(page).to have_text('Unavailability requests disabled on this application.')
      end
    end
  end
end
