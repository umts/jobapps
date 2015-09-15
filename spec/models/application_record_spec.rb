require 'rails_helper'

describe ApplicationRecord do
  describe 'deny_with' do
    before :each do
      @record = create :application_record
      @note = 'a staff note'
    end
    let :call do
      @record.deny_with @note
    end
    it 'updates with the given note' do
      call
      expect(@record.reload.staff_note).to eql @note
    end
    context 'notify_applicant set to true' do
      before :each do
        allow_any_instance_of(ApplicationConfiguration)
          .to receive :configured_value
        allow_any_instance_of(ApplicationConfiguration)
          .to receive(:configured_value)
          .with([:on_application_denial, :notify_applicant], anything)
          .and_return true
      end
      it 'sends application denial email' do
        mail = ActionMailer::MessageDelivery.new(JobappsMailer,
                                                 :application_denial)
        expect(JobappsMailer)
          .to receive(:application_denial)
          .with(@record)
          .and_return mail
        expect(mail).to receive(:deliver_now).and_return true
        call
      end
    end
    context 'notify_applicant set to false' do
      before :each do
        allow_any_instance_of(ApplicationConfiguration)
          .to receive :configured_value
        allow_any_instance_of(ApplicationConfiguration)
          .to receive(:configured_value)
          .with([:on_application_denial, :notify_applicant], anything)
          .and_return false
      end
      it 'does not send application denial email' do
        expect(JobappsMailer)
          .not_to receive(:application_denial)
        call
      end
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
