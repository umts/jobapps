# frozen_string_literal: true

require 'rails_helper'

describe ApplicationSubmission do
  describe '#email_subscribers' do
    subject(:call) do
      record.email_subscribers applicant: record.user
    end

    let(:record) { create(:application_submission) }
    let(:mail) do
      ActionMailer::MessageDelivery.new JobappsMailer,
                                        :application_notification,
                                        build(:subscription),
                                        record.position,
                                        record.user
    end

    before do
      create_list(:subscription, 3, position: record.position)
      allow(JobappsMailer).to receive(:application_notification).and_return(mail)
      allow(mail).to receive(:deliver_now).and_return true
    end

    it 'makes a notification email for all subscribers' do
      call
      record.position.subscriptions.each do |subscription|
        expect(JobappsMailer).to have_received(:application_notification)
          .with(subscription, record.position, record.user)
      end
    end

    it 'sends the notification email to all subscribers' do
      call
      expect(mail).to have_received(:deliver_now).exactly(3).times
    end
  end

  describe '#questions_hash' do
    let :record do
      create(:application_submission, data: [['What is your name?', 'Luke Starkiller', 'text', 316]])
    end

    it 'maps question IDs to responses' do
      expect(record.questions_hash).to eq(316 => 'Luke Starkiller')
    end
  end

  describe '.between' do
    subject(:call) { described_class.between(Time.zone.today, 1.week.from_now) }

    let(:too_past_record) { create(:application_submission, created_at: 1.week.ago) }
    let(:too_future_record) { create(:application_submission, created_at: 1.month.from_now) }
    let(:almost_too_future_record) { create(:application_submission, created_at: 1.week.from_now.beginning_of_day) }
    let(:just_right_record) { create(:application_submission) }

    it 'gives the application records between the given dates' do
      expect(call).to include(just_right_record, almost_too_future_record)
    end

    it 'excludes application records outside the given dates' do
      expect(call).not_to include(too_future_record, too_past_record)
    end
  end

  describe '.in_department' do
    subject(:call) { described_class.in_department department.id }

    let(:department) { create(:department) }
    let :good_record do
      create(:application_submission, position: create(:position, department:))
    end
    let(:bad_record) { create(:application_submission) }

    it 'returns records for the specified department(s)' do
      expect(call).to include(good_record)
    end

    it 'excludes records not for the specified department(s)' do
      expect(call).not_to include(bad_record)
    end
  end

  describe '.hire_count' do
    subject(:call) { described_class.hire_count }

    before do
      record1 = create(:application_submission)
      record2 = create(:application_submission)
      create(:interview, application_submission: record2, hired: false)
      create(:interview, application_submission: record1, hired: true)
    end

    it 'counts the number of interviews where the applicant was hired' do
      expect(call).to be(1)
    end
  end

  describe '.interview_count' do
    subject(:call) { described_class.interview_count }

    before do
      record1 = create(:application_submission)
      create(:application_submission)
      create(:interview, application_submission: record1)
    end

    it 'counts the interviews associated with the collection' do
      expect(call).to be(1)
    end
  end

  describe '#deny' do
    subject(:call) { record.deny }

    let(:record) { create(:application_submission) }
    let(:note) { 'a staff note' }
    let(:mail) do
      ActionMailer::MessageDelivery.new(JobappsMailer, :application_denial, record)
    end

    before do
      allow(JobappsMailer).to receive(:application_denial).and_return(mail)
      allow(mail).to receive(:deliver_now).and_return true
    end

    context 'with notify_of_denial set to true' do
      before { record.notify_of_denial = true }

      it 'creates an application denial email' do
        call
        expect(JobappsMailer).to have_received(:application_denial).with(record)
      end

      it 'sends the application denial email' do
        call
        expect(mail).to have_received(:deliver_now)
      end
    end

    context 'with notify_applicant set to false' do
      before { record.notify_of_denial = false }

      it 'does not send application denial email' do
        call
        expect(JobappsMailer).not_to have_received(:application_denial)
      end
    end
  end

  describe '#pending?' do
    it 'returns true if record has not been reviewed' do
      record = build(:application_submission, reviewed: false)
      expect(record).to be_pending
    end

    it 'returns false if record has been reviewed' do
      record = build(:application_submission, reviewed: true)
      expect(record).not_to be_pending
    end
  end

  describe 'saving for later' do
    let(:record) { create(:application_submission, saved_for_later: false) }

    let :mail do
      ActionMailer::MessageDelivery.new(JobappsMailer, :send_note_for_later, record)
    end

    before do
      allow(JobappsMailer).to receive(:send_note_for_later).and_return(mail)
      allow(mail).to receive(:deliver_now).and_return true
    end

    context 'when mail to the applicant is desired' do
      it 'calls the mailer method' do
        record.update(saved_for_later: true, mail_note_for_later: true, note_for_later: 'avacadooo')
        expect(JobappsMailer).to have_received(:send_note_for_later).with(record)
      end

      it 'sends the email' do
        record.update(saved_for_later: true, mail_note_for_later: true, note_for_later: 'avacadooo')
        expect(mail).to have_received(:deliver_now)
      end
    end

    context 'when mail to the applicant is not desired' do
      it 'does not call the mailer method' do
        record.update(saved_for_later: true, mail_note_for_later: false, note_for_later: 'avacadooo')
        expect(JobappsMailer).not_to have_received(:send_note_for_later)
      end
    end
  end

  describe '#move_to_dashboard' do
    subject(:call) { record.move_to_dashboard }

    let :record do
      create(:application_submission,
             saved_for_later: true,
             date_for_later: Time.zone.today,
             note_for_later: 'super required')
    end

    it 'updates saved_for_later attribute to false' do
      call
      expect(record.saved_for_later).to be(false)
    end

    it 'udpates the date_for_later attribute to be nil' do
      call
      expect(record.date_for_later).to be_nil
    end
  end

  describe '.move_to_dashboard' do
    subject(:call) { described_class.move_to_dashboard }

    context 'when there is one expired record' do
      let! :record do
        create(:application_submission,
               saved_for_later: true,
               date_for_later: Date.yesterday,
               note_for_later: 'this is required',
               email_to_notify: 'foo@example.com')
      end

      it 'calls move_to_dashboard on the expired record' do
        call
        expect(record.reload.saved_for_later).to be(false)
      end

      it 'notifies staff of the moved record' do
        allow(JobappsMailer).to receive(:saved_application_notification)
        call
        expect(JobappsMailer).to have_received(:saved_application_notification).with(record)
      end
    end

    context 'when there are many expired records' do
      let! :records do
        2.times.map do
          create(:application_submission,
                 saved_for_later: true,
                 date_for_later: Date.yesterday,
                 note_for_later: 'this is required',
                 email_to_notify: 'foo@example.com')
        end
      end

      it 'calls move_to_dashboard on expired records' do
        call
        expect(records.map(&:reload)).to all have_attributes(saved_for_later: false)
      end

      it 'sends one combined email' do
        allow(JobappsMailer).to receive(:saved_applications_notification)
        call
        expect(JobappsMailer).to have_received(:saved_applications_notification).once
      end
    end

    context 'when there are no expired records' do
      let!(:future_saved_record) do
        create(:application_submission,
               saved_for_later: true,
               date_for_later: Date.tomorrow,
               note_for_later: 'SO required',
               email_to_notify: 'foo@example.com')
      end

      it 'does not call move_to_dashboard on any records' do
        call
        expect(future_saved_record.reload.saved_for_later).to be(true)
      end

      it 'does not send any emails' do
        allow(JobappsMailer).to receive(:saved_application_notification)
        call
        expect(JobappsMailer).not_to have_received(:saved_application_notification)
      end
    end
  end

  describe '.combined_eeo_data' do
    subject(:call) { described_class.combined_eeo_data records }

    let(:records) { described_class.all }

    before do
      stub_const 'ApplicationSubmission::ETHNICITY_OPTIONS', ['Klingon']
      stub_const 'ApplicationSubmission::GENDER_OPTIONS', ['Other']
    end

    it 'calls AR#interview_count to count interviews' do
      allow(described_class).to receive(:interview_count)
      call
      expect(described_class).to have_received(:interview_count).at_least(:once)
    end

    it 'calls AR#hire_count to count hirees' do
      allow(described_class).to receive(:hire_count)
      call
      expect(described_class).to have_received(:hire_count).at_least(:once)
    end

    it 'counts only records and interviews with both ethnicity and gender' do
      create(:application_submission, ethnicity: nil, gender: nil)
      create(:application_submission, ethnicity: '', gender: '')
      expect(call).to eq('Other' => [['Klingon', 0, 0, 0]])
    end

    it 'counts records/interviews whose ethnicity is not one of the options' do
      create(:application_submission, ethnicity: 'Romulan', gender: 'Other')
      expect(call).to eq('Other' => [['Klingon', 0, 0, 0], ['Romulan', 1, 0, 0]])
    end

    it 'counts records/interviews whose gender is not one of the options' do
      create(:application_submission, ethnicity: 'Klingon', gender: 'Male')
      expect(call).to eq('Other' => [['Klingon', 0, 0, 0]], 'Male' => [['Klingon', 1, 0, 0]])
    end

    it 'counts records/interviews where gender and ethnicity not in options' do
      create(:application_submission, ethnicity: 'Romulan', gender: 'Male')
      expect(call).to eq('Other' => [['Klingon', 0, 0, 0], ['Romulan', 0, 0, 0]],
                         'Male' => [['Klingon', 0, 0, 0], ['Romulan', 1, 0, 0]])
    end

    it { is_expected.to be_a(Hash) }
  end

  describe '.ethnicity_eeo_data' do
    subject(:call) { described_class.ethnicity_eeo_data records }

    let(:records) { described_class.all }

    before do
      stub_const 'ApplicationSubmission::ETHNICITY_OPTIONS', ['Klingon']
    end

    it 'calls AR#interview_count to count interviews' do
      allow(described_class).to receive(:interview_count)
      call
      expect(described_class).to have_received(:interview_count).at_least(:once)
    end

    it 'calls AR#hire_count to count hirees' do
      allow(described_class).to receive(:hire_count)
      call
      expect(described_class).to have_received(:hire_count).at_least(:once)
    end

    it 'counts only records and their interviews with an ethnicity attribute' do
      create(:application_submission, ethnicity: nil)
      create(:application_submission, ethnicity: '')
      expect(call).to contain_exactly(['Klingon', 0, 0, 0])
    end

    it 'counts records/interviews whose ethnicity is not of the options' do
      create(:application_submission, ethnicity: 'Romulan', gender: 'Male')
      expect(call).to contain_exactly(['Klingon', 0, 0, 0], ['Romulan', 1, 0, 0])
    end
  end

  describe '.gender_eeo_data' do
    subject(:call) { described_class.gender_eeo_data records }

    let(:records) { described_class.all }

    before do
      stub_const 'ApplicationSubmission::GENDER_OPTIONS', ['Female']
    end

    it 'calls AR#interview_count to count interviews' do
      allow(described_class).to receive(:interview_count)
      call
      expect(described_class).to have_received(:interview_count).at_least(:once)
    end

    it 'calls AR#hire_count to count hirees' do
      allow(described_class).to receive(:hire_count)
      call
      expect(described_class).to have_received(:hire_count).at_least(:once)
    end

    it 'counts only records and their interviews with a gender attribute' do
      create(:application_submission, gender: nil)
      create(:application_submission, gender: '')
      expect(call).to contain_exactly(['Female', 0, 0, 0])
    end

    it 'counts records/interviews whose gender is not of the gender_options' do
      create(:application_submission, gender: 'Male')
      expect(call).to contain_exactly(['Female', 0, 0, 0], ['Male', 1, 0, 0])
    end
  end

  describe '.eeo_data' do
    subject :call do
      described_class.eeo_data start_date, end_date, department.id
    end

    let(:department) { create(:department) }
    let(:start_date) { 1.week.ago }
    let(:end_date) { 1.week.from_now }
    let(:relation) { described_class.between(start_date, end_date).in_department(department.id) }

    it 'calls AR#between to gather application records' do
      allow(described_class).to receive(:between).and_return(relation)
      call
      expect(described_class).to have_received(:between).with(start_date, end_date)
    end

    it 'calls AR#in_department to filter application records' do
      allow(described_class).to receive(:in_department).and_return(relation)
      call
      expect(described_class).to have_received(:in_department).with(department.id)
    end

    it 'calls AR#ethnicity_eeo_data to populate hash with ethnicity numbers' do
      allow(described_class).to receive(:ethnicity_eeo_data).and_return('some values')
      expect(call[:ethnicities]).to eq('some values')
    end

    it 'calls AR#gender_eeo_data to assign values to genders key in hash' do
      allow(described_class).to receive(:gender_eeo_data).and_return('something')
      expect(call[:genders]).to eq('something')
    end

    it 'calls AR#combined_eeo_data to populate hash with combo numbers' do
      allow(described_class).to receive(:combined_eeo_data).and_return('combo values')
      expect(call[:combined_data]).to eq('combo values')
    end

    it { is_expected.to be_a Hash }
  end

  describe '#rejected?' do
    subject(:call) { application_submission.rejected? }

    context 'when reviewed and an interview is not scheduled' do
      let(:application_submission) do
        create(:application_submission, reviewed: true, interview: nil)
      end

      it { is_expected.to be(true) }
    end

    context 'when reviewed and an interview is scheduled' do
      let(:interview) { create(:interview, scheduled: Time.zone.today) }
      let(:application_submission) do
        create(:application_submission, reviewed: true, interview:)
      end

      it { is_expected.to be(false) }
    end
  end
end
