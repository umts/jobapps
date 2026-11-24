# frozen_string_literal: true

require 'rails_helper'

describe 'viewing the positions list' do
  let(:position) { create(:position, name: 'Operator') }

  before { create(:position_manager, position: create(:position, name: 'Dispatcher')) }

  context 'when logged in as a manager' do
    before do
      when_current_user_is create(:position_manager, position:).user
      visit positions_path
    end

    it 'lists the positions they manage' do
      expect(page).to have_link('Operator', href: position_path(position))
    end

    it 'does not list positions managed by someone else' do
      expect(page).to have_no_link('Dispatcher')
    end
  end

  context 'when logged in as a user who manages nothing' do
    before do
      position
      when_current_user_is :anyone
      visit positions_path
    end

    it 'lists no positions' do
      expect(page).to have_text('No positions found')
    end
  end

  context 'when logged in as an admin' do
    before do
      position
      when_current_user_is :admin
      visit positions_path
    end

    it 'lists every position' do
      expect(page).to have_link('Operator').and have_link('Dispatcher')
    end
  end
end
