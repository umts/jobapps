# frozen_string_literal: true

require 'rails_helper'

describe 'edit site text or request new' do
  let!(:site_text) { create :site_text }
  let!(:user) { create :user, staff: true }
  before :each do
    when_current_user_is user, system: true
  end
  context 'link to edit or request new from dashboard' do
    before :each do
      visit staff_dashboard_path
    end
    it 'contains a link to edit the site text' do
      click_link("Change #{site_text.name} text")
      expect(page.current_path).to eql edit_site_text_path(site_text)
    end
    it 'contains a link to request a new site text' do
      click_link('Request new site text')
      expect(page.current_path).to eql request_new_site_texts_path
    end
  end
  context 'editing site text' do
    before :each do
      visit edit_site_text_path(site_text)
    end
    it 'allows user to change the site text' do
      fill_in 'site_text[text]', with: 'Bananas'
      expect_flash_message :site_text_update
      click_button 'Update text'
      expect(site_text.reload.text).to eql 'Bananas'
      expect(page.current_path).to eql staff_dashboard_path
    end
  end
  context 'requesting new site text' do
    before :each do
      visit request_new_site_texts_path
    end
    it 'sends IT an email with the requested path and description' do
      mail = ActionMailer::MessageDelivery.new(JobappsMailer,
                                               :site_text_request)
      fill_in 'location', with: 'A path'
      fill_in 'description', with: 'A description'
      expect(JobappsMailer)
        .to receive(:site_text_request)
        .with(user, 'A path', 'A description')
        .and_return mail
      expect(mail).to receive(:deliver_now).and_return true
      expect_flash_message :site_text_request
      click_button 'Submit request'
      expect(page.current_path).to eql staff_dashboard_path
    end
  end
end
