# frozen_string_literal: true

require 'rails_helper'

describe 'layouts/application' do
  it 'displays a link to logout' do
    render
    expect(rendered).to have_tag('a', with: { href: '/sessions/destroy' })
  end

  it 'has a link to the main dashboard' do
    render
    expect(rendered).to have_tag('a', with: { href: main_dashboard_path })
  end

  context 'with message present in flash' do
    before do
      flash[:message] = 'this is totally a message' # rubocop:disable Rails/I18nLocaleTexts
      render
    end

    it 'displays the message' do
      expect(rendered).to have_tag '#message' do
        with_text(/this is totally a message/)
      end
    end
  end

  context 'with errors present in flash' do
    before do
      flash[:errors] = %w[these are errors]
      render
    end

    it 'displays a list of errors' do
      expect(rendered).to include('these', 'are', 'errors')
    end
  end
end
