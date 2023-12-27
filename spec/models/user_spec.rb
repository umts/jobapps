# frozen_string_literal: true

require 'rails_helper'

describe User do
  describe 'full_name' do
    before :each do
      @user = create(:user)
    end
    it 'gives first name followed by last name' do
      expect(@user.full_name).to eql "#{@user.first_name} #{@user.last_name}"
    end
  end

  describe 'proper_name' do
    before :each do
      @user = create(:user)
    end
    it 'gives last name, first name' do
      expect(@user.proper_name).to eql "#{@user.last_name}, #{@user.first_name}"
    end
  end

  describe 'student?' do
    it 'returns true if user is not staff' do
      user = create(:user, staff: false)
      expect(user).to be_student
    end
    it 'returns false if user is staff' do
      user = create(:user, staff: true)
      expect(user).not_to be_student
    end
  end
end
