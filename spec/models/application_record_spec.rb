require 'rails_helper'

describe ApplicationRecord do
  describe 'by_user_name' do
    before :each do
      # in order
      @user_1 = create :user, first_name: 'Rick', last_name: 'Klang'
      @user_2 = create :user, first_name: 'Jill', last_name: 'Smith'
      @user_3 = create :user, first_name: 'John', last_name: 'Smith'
      create :application_record, user: @user_1
      create :application_record, user: @user_2
      create :application_record, user: @user_3
    end
    it 'orders by last name and then first name' do
      expect(ApplicationRecord.by_user_name.count)
        .to eql 3
      expect(ApplicationRecord.by_user_name.first.user)
        .to eql @user_1
      expect(ApplicationRecord.by_user_name.last.user)
        .to eql @user_3
    end
  end

  describe 'pending?' do
    it 'returns true if record has not been reviewed' do
      record = create :application_record, reviewed: false
      expect(record.pending?).to eql true
    end
    it 'returns false if record has been reviewed' do
      record = create :application_record, reviewed: true
      expect(record.pending?).to eql false
    end
  end
end
