# frozen_string_literal: true

require 'rails_helper'

describe ApplicationSubmission do
  describe 'data_rows' do
    before :each do
      @record = create :application_submission,
                       data: [['a question', 'an answer', 'text', 5]]
    end
    let :call do
      @record.data_rows
    end
    it 'returns array with header, prompts and responses, no data_type or ID' do
      expect(call).to eql [%w[Question Response], ['a question', 'an answer']]
    end
    it 'removes questions of data type heading or explanation' do
      @record.data << ['a heading', nil, 'heading', 6]
      @record.data << ['an explanation', nil, 'explanation', 7]
      expect(call).to eql [%w[Question Response], ['a question', 'an answer']]
    end
  end

  describe 'unavailability_rows' do
    let :unavail do
      create :unavailability, sunday: [],
                              monday: %w[10AM 11AM 12PM],
                              tuesday: %w[11AM 12PM 1PM 2PM 3PM 4PM 5PM],
                              wednesday: %w[10AM 11AM 12PM],
                              thursday: %w[11AM 12PM 1PM 2PM 3PM 4PM 5PM],
                              friday: %w[10AM 11AM 12PM],
                              saturday: []
    end
    let(:record) { create :application_submission, unavailability: unavail }
    let(:call) { record.unavailability.grid }
    it 'gives false for available times' do
      expect(call[0][0]).to be false
    end
    it 'gives true for unavailable times' do
      expect(call[1][3]).to be true
    end
  end

  describe 'email_subscribers' do
    let(:record) { create :application_submission }
    let!(:subscription) { create :subscription, position: record.position }
    let :call do
      record.email_subscribers applicant: record.user
    end
    it 'sends a notification to all subscribers when application is created' do
      mail = ActionMailer::MessageDelivery.new(JobappsMailer,
                                               :application_notification)
      record.position.subscriptions.each do |subscription|
        expect(JobappsMailer)
          .to receive(:application_notification)
          .with(subscription, record.position, record.user)
          .and_return mail
        expect(mail).to receive(:deliver_now).and_return true
        call
      end
    end
  end

  describe 'question_hash' do
    let :record do
      create :application_submission,
             data: [['What is your name?', 'Luke Starkiller', 'text', 316]]
    end
    it 'maps question IDs to responses' do
      expect(record.questions_hash).to eql 316 => 'Luke Starkiller'
    end
  end

  describe 'between' do
    before :each do
      Timecop.freeze 1.week.ago do
        @too_past_record = create :application_submission
      end
      Timecop.freeze 1.month.since do
        @too_future_record = create :application_submission
      end
      Timecop.freeze 1.week.since do
        @almost_too_future_record = create :application_submission
      end
      @just_right_record = create :application_submission
      @start_date = Time.zone.today
      @end_date = 1.week.since
    end
    let :call do
      ApplicationSubmission.between @start_date, @end_date
    end
    it 'gives the application records between the given dates' do
      expect(call).to include @just_right_record, @almost_too_future_record
      expect(call).not_to include @too_future_record, @too_past_record
    end
  end

  describe 'in_department' do
    before :each do
      @department = create :department
      position = create :position, department: @department
      @good_record = create :application_submission, position: position
      @bad_record = create :application_submission, position: create(:position)
    end
    let :call do
      ApplicationSubmission.in_department @department.id
    end
    it 'only returns records for the specified department(s)' do
      expect(call).to include @good_record
      expect(call).not_to include @bad_record
    end
  end

  describe 'hire_count' do
    before :each do
      record1 = create :application_submission
      record2 = create :application_submission
      create :interview, application_submission: record2, hired: false
      create :interview, application_submission: record1, hired: true
    end
    let :call do
      ApplicationSubmission.hire_count
    end
    it 'counts the number of interviews where the applicant was hired' do
      expect(call).to be 1
    end
  end

  describe 'interview_count' do
    before :each do
      record1 = create :application_submission
      create :application_submission
      create :interview, application_submission: record1
    end
    let :call do
      ApplicationSubmission.interview_count
    end
    it 'counts the interviews associated with the collection' do
      expect(call).to be 1
    end
  end

  describe 'deny_with' do
    before :each do
      @record = create :application_submission
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
          .with(%i[on_application_denial notify_applicant], anything)
          .and_return true
        @mail = ActionMailer::MessageDelivery.new(JobappsMailer,
                                                  :application_denial)
      end
      it 'sends application denial email' do
        expect(JobappsMailer)
          .to receive(:application_denial)
          .with(@record)
          .and_return @mail
        expect(@mail).to receive(:deliver_now).and_return true
        call
      end
      it 'it does not send application denial email without staff note' do
        @note = nil
        expect(JobappsMailer).not_to receive(:application_denial)
        expect(@mail).not_to receive(:deliver_now)
        call
      end
    end
    context 'notify_applicant set to false' do
      before :each do
        allow_any_instance_of(ApplicationConfiguration)
          .to receive :configured_value
        allow_any_instance_of(ApplicationConfiguration)
          .to receive(:configured_value)
          .with(%i[on_application_denial notify_applicant], anything)
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
      record = create :application_submission, reviewed: false
      expect(record).to be_pending
    end
    it 'returns false if record has been reviewed' do
      record = create :application_submission, reviewed: true
      expect(record).not_to be_pending
    end
  end

  describe 'saving for later' do
    before :each do
      @record = create :application_submission, saved_for_later: false
    end
    context 'mail to applicant desired' do
      let :mail do
        ActionMailer::MessageDelivery.new(JobappsMailer, :send_note_for_later)
      end
      it 'calls the mailer method' do
        expect(JobappsMailer)
          .to receive(:send_note_for_later)
          .with(@record)
          .and_return mail
        expect(mail).to receive(:deliver_now).and_return true
        @record.assign_attributes(
          saved_for_later: true,
          mail_note_for_later: true,
          note_for_later: 'avacadooo'
        )
        @record.save
      end
    end
    context 'mail to applicant not desired' do
      it 'does not call the mailer method' do
        expect(JobappsMailer).not_to receive(:send_note_for_later)
        @record.assign_attributes(
          saved_for_later: true,
          mail_note_for_later: false,
          note_for_later: 'avacadooo'
        )
        @record.save
      end
    end
  end

  describe 'move_to_dashboard' do
    let :record do
      create :application_submission,
             saved_for_later: true,
             date_for_later: Time.zone.today,
             note_for_later: 'super required'
    end
    let :call do
      record.move_to_dashboard
    end
    it 'updates saved_for_later attribute to false' do
      call
      expect(record.saved_for_later).to be_falsey
    end
    it 'udpates the date_for_later attribute to be nil' do
      call
      expect(record.date_for_later).to be_nil
    end
  end

  describe 'move_to_dashboard' do
    let(:call) { ApplicationSubmission.move_to_dashboard }
    context 'there is an expired record' do
      let!(:expired_saved_record) do
        create :application_submission,
               saved_for_later: true,
               date_for_later: Date.yesterday,
               note_for_later: 'this is required',
               email_to_notify: 'foo@example.com'
      end
      it 'calls move_to_dashboard on expired record' do
        expect_any_instance_of(ApplicationSubmission)
          .to receive(:move_to_dashboard)
        expect(JobappsMailer).to receive(:saved_application_notification)
        call
      end
    end
    context 'there are many expired records' do
      let!(:expired_saved_record_1) do
        create :application_submission,
               saved_for_later: true,
               date_for_later: Date.yesterday,
               note_for_later: 'this is required',
               email_to_notify: 'foo@example.com'
      end
      let!(:expired_saved_record_2) do
        create :application_submission,
               saved_for_later: true,
               date_for_later: Date.yesterday,
               note_for_later: 'this is required',
               email_to_notify: 'foo@example.com'
      end
      it 'calls move_to_dashboard on expired records' do
        expect(JobappsMailer).to receive(:saved_applications_notification)
        call
      end
    end
    context 'there are no expired records' do
      let!(:future_saved_record) do
        create :application_submission,
               saved_for_later: true,
               date_for_later: Date.tomorrow,
               note_for_later: 'SO required',
               email_to_notify: 'foo@example.com'
      end
      it 'does not call move_to_dashboard on any records' do
        expect_any_instance_of(ApplicationSubmission)
          .not_to receive(:move_to_dashboard)
        expect(JobappsMailer).not_to receive(:saved_application_notification)
        call
      end
    end
  end

  describe 'self.combined_eeo_data' do
    before :each do
      @records = ApplicationSubmission.all
      stub_const 'ApplicationSubmission::ETHNICITY_OPTIONS', ['Klingon']
      stub_const 'ApplicationSubmission::GENDER_OPTIONS', ['Other']
    end
    let :call do
      ApplicationSubmission.combined_eeo_data @records
    end
    it 'calls AR#interview_count to count interviews' do
      expect(ApplicationSubmission).to receive(:interview_count)
        .at_least(:once)
      call
    end
    it 'calls AR#hire_count to count hirees' do
      expect(ApplicationSubmission).to receive(:hire_count)
        .at_least(:once)
      call
    end
    it 'counts only records and interviews with both ethnicity and gender' do
      create :application_submission, ethnicity: nil, gender: nil
      create :application_submission, ethnicity: '', gender: ''
      expect(call).to eql('Other' => [['Klingon', 0, 0, 0]])
    end
    it 'counts records/interviews whose ethnicity is not one of the options' do
      create :application_submission, ethnicity: 'Romulan', gender: 'Other'
      expect(call).to eql('Other' => [['Klingon', 0, 0, 0],
                                      ['Romulan', 1, 0, 0]])
    end
    it 'counts records/interviews whose gender is not one of the options' do
      create :application_submission, ethnicity: 'Klingon', gender: 'Male'
      expect(call).to eql('Other' => [['Klingon', 0, 0, 0]],
                          'Male' => [['Klingon', 1, 0, 0]])
    end
    it 'counts records/interviews where gender and ethnicity not in options' do
      create :application_submission, ethnicity: 'Romulan', gender: 'Male'
      expect(call).to eql('Other' => [['Klingon', 0, 0, 0],
                                      ['Romulan', 0, 0, 0]],
                          'Male' => [['Klingon', 0, 0, 0],
                                     ['Romulan', 1, 0, 0]])
    end
    it 'returns a hash' do
      expect(call).to be_a Hash
    end
  end

  describe 'self.ethnicity_eeo_data' do
    # There are no interviews, all interview counts are 0
    before :each do
      @records = ApplicationSubmission.all
      stub_const 'ApplicationSubmission::ETHNICITY_OPTIONS', ['Klingon']
    end
    let :call do
      ApplicationSubmission.ethnicity_eeo_data @records
    end
    it 'calls AR#interview_count to count interviews' do
      expect(ApplicationSubmission).to receive(:interview_count)
        .at_least(:once)
      call
    end
    it 'calls AR#hire_count to count hirees' do
      expect(ApplicationSubmission).to receive(:hire_count)
        .at_least(:once)
      call
    end
    it 'counts only records and their interviews with an ethnicity attribute' do
      create :application_submission, ethnicity: nil
      create :application_submission, ethnicity: ''
      expect(call).to contain_exactly ['Klingon', 0, 0, 0]
    end
    it 'counts records/interviews whose ethnicity is not of the options' do
      create :application_submission, ethnicity: 'Romulan', gender: 'Male'
      expect(call).to contain_exactly ['Klingon', 0, 0, 0], ['Romulan', 1, 0, 0]
    end
  end

  describe 'self.gender_eeo_data' do
    # There are no interviews, all interview counts are 0
    before :each do
      @records = ApplicationSubmission.all
      stub_const 'ApplicationSubmission::GENDER_OPTIONS', ['Female']
    end
    let :call do
      ApplicationSubmission.gender_eeo_data @records
    end
    it 'calls AR#interview_count to count interviews' do
      expect(ApplicationSubmission).to receive(:interview_count)
        .at_least(:once)
      call
    end
    it 'calls AR#hire_count to count hirees' do
      expect(ApplicationSubmission).to receive(:hire_count)
        .at_least(:once)
      call
    end
    it 'counts only records and their interviews with a gender attribute' do
      create :application_submission, gender: nil
      create :application_submission, gender: ''
      expect(call).to contain_exactly ['Female', 0, 0, 0]
    end
    it 'counts records/interviews whose gender is not of the gender_options' do
      create :application_submission, gender: 'Male'
      expect(call).to contain_exactly ['Female', 0, 0, 0], ['Male', 1, 0, 0]
    end
  end

  describe 'self.eeo_data' do
    # all this method does is call other methods and put the values returned
    # in a hash.
    before :each do
      @department = create :department
      @start_date = 1.week.ago
      @end_date = 1.week.since
      @relation = ApplicationSubmission.between(@start_date, @end_date)
                                       .in_department(@department.id)
    end
    let :call do
      ApplicationSubmission.eeo_data @start_date, @end_date, @department.id
    end
    it 'calls AR#between to gather application records' do
      expect(ApplicationSubmission).to receive(:between)
        .with(@start_date, @end_date)
        .and_return(@relation)
      # returns an ActiveRecord relation
      call
    end
    it 'calls AR#in_department to filter application records' do
      expect(ApplicationSubmission).to receive(:in_department)
        .with(@department.id)
        .and_return(@relation)
      # returns an ActiveRecord relation
      call
    end
    it 'calls AR#ethnicity_eeo_data to populate hash with ethnicity numbers' do
      expect(ApplicationSubmission).to receive(:ethnicity_eeo_data)
        .with(@relation)
        .and_return('some values')
      call
      expect(call[:ethnicities]).to eql 'some values'
    end
    it 'calls AR#gender_eeo_data to assign values to genders key in hash' do
      expect(ApplicationSubmission).to receive(:gender_eeo_data)
        .with(@relation)
        .and_return('something')
      call
      expect(call[:genders]).to eql 'something'
    end
    it 'calls AR#combined_eeo_data to populate hash with combo numbers' do
      expect(ApplicationSubmission).to receive(:combined_eeo_data)
        .with(@relation)
        .and_return('combo values')
      call
      expect(call[:combined_data]).to eql 'combo values'
    end
    it 'returns a hash' do
      expect(call).to be_a Hash
    end
  end

  describe 'rejected?' do
    let!(:application_sub1) do
      create :application_submission, reviewed: true, interview: nil
    end
    let!(:interview) { create :interview, scheduled: Time.zone.today }
    let!(:application_sub2) do
      create :application_submission, reviewed: true, interview: interview
    end
    context 'when reviewed and interview not scheduled' do
      it 'returns true' do
        expect(application_sub1).to be_rejected
        expect(application_sub2).not_to be_rejected
      end
    end
    context 'when reviewed and interview scheduled' do
      it 'returns false' do
        expect(application_sub2).not_to be_rejected
      end
    end
  end
end
