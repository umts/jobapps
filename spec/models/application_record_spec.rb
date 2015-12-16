require 'rails_helper'
require 'csv'

describe ApplicationRecord do
  describe 'add_response_data' do
    context 'application record with no existing response data' do
      before :each do
        # The header content doesn't matter, it only matters that they're there.
        headers = %w(x y z)
        @question = 'a question'
        @answer = 'an answer'
        fields = ['1', @question, @answer]
        CSV::Row.new(headers, fields)
        # Need to have an existing (saved) but invalid record,
        # so we save with blank response data without validating
        @record = build :application_record, data: nil
        @record.save validate: false
      end
      let :call do
        @record.add_response_data(@question, @answer)
      end
      it 'makes the changes to the correct application record' do
        expect(call.data).to eql [[@question, @answer]]
      end
    end
    context 'application record with existing response data' do
      before :each do
        @existing_question = 'existing question'
        @existing_answer = 'existing answer'
        # The header content doesn't matter, it only matters that they're there.
        headers = %w(x y z)
        @new_question = 'new question'
        @new_answer = 'new answer'
        fields = ['1', @new_question, @new_answer]
        CSV::Row.new(headers, fields)
        @record = create :application_record, data: [[@existing_question,
                                                      @existing_answer]]
      end
      let :call do
        @record.add_response_data(@new_question, @new_answer)
      end
      it 'appends the changes to the existing response data' do
        expect(call.data).to eql [[@existing_question, @existing_answer],
                                  [@new_question, @new_answer]]
      end
    end
  end

  describe 'between' do
    before :each do
      Timecop.freeze 1.week.ago do
        @too_past_record = create :application_record
      end
      Timecop.freeze 1.month.since do
        @too_future_record = create :application_record
      end
      @just_right_record = create :application_record
      @start_date = Time.zone.today
      @end_date = 1.week.since
    end
    let :call do
      ApplicationRecord.between @start_date, @end_date
    end
    it 'gives the application records between the given dates' do
      expect(call).to include @just_right_record
      expect(call).not_to include @too_future_record, @too_past_record
    end
  end

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

  describe 'self.gender_eeo_data' do
    before :each do
      @start_date = 1.week.ago
      @end_date = 1.week.since
      stub_const 'ApplicationRecord::GENDER_OPTIONS', ['Female']
    end
    let :call do
      ApplicationRecord.gender_eeo_data @start_date, @end_date
    end
    it 'calls AR#between to gather application records' do
      relation = ApplicationRecord.all
      expect(ApplicationRecord).to receive(:between)
        .with(@start_date, @end_date)
        .and_return(relation)
      call
    end
    it 'counts records within the correct date range' do
      create :application_record,
             gender: 'Female'
      Timecop.freeze 2.weeks.ago do
        create :application_record,
               gender: 'Female'
      end
      expect(call).to contain_exactly ['Female', 1]
    end
    it 'counts only records with a gender attribute' do
      create :application_record,
             gender: nil
      create :application_record,
             gender: ''
      expect(call).to contain_exactly ['Female', 0]
    end
    it 'counts records whose gender is not one of the gender_options' do
      create :application_record,
             gender: 'Male'
      expect(call).to contain_exactly ['Female', 0], ['Male', 1]
    end
  end

  describe 'self.eeo_data' do
    before :each do
      @start_date = 1.week.ago
      @end_date = 1.week.since
      stub_const 'ApplicationRecord::ETHNICITY_OPTIONS', ['Klingon']
    end
    let :call do
      ApplicationRecord.eeo_data @start_date, @end_date
    end
    it 'calls AR#between to gather application records' do
      relation = ApplicationRecord.all
      expect(ApplicationRecord).to receive(:between)
        .with(@start_date, @end_date)
        .and_return(relation).at_least(:once)
      # needs to return an activerecord relation. Also
      # the method :between is called twice in the test,
      # technically. gender_eeo_data uses it.
      call
    end
    it 'returns a hash' do
      expect(call).to be_a Hash
    end
    it 'assigns records to the hash within the correct date range' do
      create :application_record,
             ethnicity: 'Klingon',
             gender: 'Female'
      Timecop.freeze 2.weeks.ago do
        create :application_record,
               ethnicity: 'Klingon',
               gender: 'Female'
      end
      expect(call[:all].count).to eql 1
    end
    it 'counts records containing ethnicities not from ethnicity_options' do
      create :application_record,
             ethnicity: 'Betazoid',
             gender: 'Male'
      expect(call[:ethnicities]).to contain_exactly ['Betazoid', 1],
                                                    ['Klingon', 0]
    end
    it 'calls AR#gender_eeo_data to assign values to genders key in hash' do
      expect(ApplicationRecord).to receive(:gender_eeo_data)
        .with(@start_date, @end_date)
        .and_return('something')
      call
      expect(call[:genders]).to eql 'something'
    end
    it 'puts all genders and the counts thereof in the hash' do
      create :application_record,
             gender: 'Female'
      expect(call[:genders]).to contain_exactly ['Male', 0], ['Female', 1]
    end
    it 'puts counts of all male members of every ethnicity in the hash' do
      create :application_record,
             ethnicity: 'Klingon',
             gender: 'Male'
      create :application_record,
             ethnicity: 'Betazoid',
             gender: 'Female'
      expect(call[:male_ethnicities]).to contain_exactly ['Betazoid', 0],
                                                         ['Klingon', 1]
    end
    it 'puts counts of all female members of every ethnicity in the hash' do
      create :application_record,
             ethnicity: 'Klingon',
             gender: 'Male'
      create :application_record,
             ethnicity: 'Betazoid',
             gender: 'Female'
      expect(call[:female_ethnicities]).to contain_exactly ['Betazoid', 1],
                                                           ['Klingon', 0]
    end
  end
end
