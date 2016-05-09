require 'rails_helper'

describe ApplicationRecord do
  describe 'add_data_types' do
    before :each do
      @record = create :application_record,
                       data: [['a question', 'an answer']]
    end
    context 'there exists a question that matches the given prompt' do
      it 'gives the data_type the value of the question data_type' do
        create :question,
               data_type: 'yes/no',
               prompt: 'a question',
               application_template: (create :application_template)
        @record.add_data_types
        expect(@record.data).to eql [['a question', 'an answer', 'yes/no']]
      end
    end
    context 'there is no question that matches the given prompt' do
      it 'gives the data_type a text value' do
        @record.add_data_types
        expect(@record.data).to eql [['a question', 'an answer', 'text']]
      end
    end
  end
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

  describe 'question_hash' do
    include ApplicationHelper
    before :each do
      @data = {}
      (0..4).each do |num|
        %w(prompt response data_type).each do |type|
          @data["#{type}_#{num}"] = "#{num}-#{type}"
        end
        @data[num.to_s] = "#{num}-#{num}"
      end
      @data_arr = parse_application_data(@data)
                  .select { |sub| !sub.nil? && sub.all? }
      @record = create :application_record, data: @data_arr
      @hash = @record.questions_hash
    end

    it 'does not return nothing when given data' do
      expect(@hash.length).not_to be_zero
    end

    it 'generates the correct amount of data' do
      expect(@hash.length).to be(5)
    end

    it 'contains the correct keys and values' do
      @record.data.each do |_, value, _, index|
        expect(@hash.keys).to include(index)
        expect(@hash.values).to include(value)
      end
    end

    it 'maps to the correct values' do
      @record.data.each do |_, value, _, index|
        expect(@hash[index]).to be(value)
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

  describe 'in_department' do
    before :each do
      @department = create :department
      position = create :position, department: @department
      @good_record = create :application_record,  position: position
      @bad_record = create :application_record, position: create(:position)
    end
    let :call do
      ApplicationRecord.in_department @department.id
    end
    it 'only returns records for the specified department(s)' do
      expect(call).to include @good_record
      expect(call).not_to include @bad_record
    end
  end

  describe 'interview_count' do
    before :each do
      record_1 = create :application_record
      create :application_record
      create :interview, application_record: record_1
      @collection = ApplicationRecord.all
    end
    let :call do
      @collection.interview_count
    end
    it 'counts the interviews associated with the collection' do
      expect(call).to be 1
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
      expect(record).to be_pending
    end
    it 'returns false if record has been reviewed' do
      record = create :application_record, reviewed: true
      expect(record).not_to be_pending
    end
  end

  describe 'self.combined_eeo_data' do
    before :each do
      @records = ApplicationRecord.all
      stub_const 'ApplicationRecord::ETHNICITY_OPTIONS', ['Klingon']
      stub_const 'ApplicationRecord::GENDER_OPTIONS', ['Other']
    end
    let :call do
      ApplicationRecord.combined_eeo_data @records
    end
    it 'calls AR#interview_count to count interviews' do
      expect(ApplicationRecord).to receive(:interview_count)
        .at_least(:once)
      call
    end
    it 'counts only records and interviews with both ethnicity and gender' do
      create :application_record, ethnicity: nil, gender: nil
      create :application_record, ethnicity: '', gender: ''
      expect(call).to eql('Other' => [['Klingon', 0, 0]])
    end
    it 'counts records/interviews whose ethnicity is not one of the options' do
      create :application_record, ethnicity: 'Romulan', gender: 'Other'
      expect(call).to eql('Other' => [['Klingon', 0, 0],
                                      ['Romulan', 1, 0]])
    end
    it 'counts records/interviews whose gender is not one of the options' do
      create :application_record, ethnicity: 'Klingon', gender: 'Male'
      expect(call).to eql('Other' => [['Klingon', 0, 0]],
                          'Male' => [['Klingon', 1, 0]])
    end
    it 'counts records/interviews where gender and ethnicity not in options' do
      create :application_record, ethnicity: 'Romulan', gender: 'Male'
      expect(call).to eql('Other' => [['Klingon', 0, 0], ['Romulan', 0, 0]],
                          'Male' => [['Klingon', 0, 0], ['Romulan', 1, 0]])
    end
    it 'returns a hash' do
      expect(call).to be_a Hash
    end
  end

  describe 'self.ethnicity_eeo_data' do
    # There are no interviews, all interview counts are 0
    before :each do
      @records = ApplicationRecord.all
      stub_const 'ApplicationRecord::ETHNICITY_OPTIONS', ['Klingon']
    end
    let :call do
      ApplicationRecord.ethnicity_eeo_data @records
    end
    it 'calls AR#interview_count to count interviews' do
      expect(ApplicationRecord).to receive(:interview_count)
        .at_least(:once)
      call
    end
    it 'counts only records and their interviews with an ethnicity attribute' do
      create :application_record, ethnicity: nil
      create :application_record, ethnicity: ''
      expect(call).to contain_exactly ['Klingon', 0, 0]
    end
    it 'counts records/interviews whose ethnicity is not of the options' do
      create :application_record, ethnicity: 'Romulan', gender: 'Male'
      expect(call).to contain_exactly ['Klingon', 0, 0], ['Romulan', 1, 0]
    end
  end

  describe 'self.gender_eeo_data' do
    # There are no interviews, all interview counts are 0
    before :each do
      @records = ApplicationRecord.all
      stub_const 'ApplicationRecord::GENDER_OPTIONS', ['Female']
    end
    let :call do
      ApplicationRecord.gender_eeo_data @records
    end
    it 'calls AR#interview_count to count interviews' do
      expect(ApplicationRecord).to receive(:interview_count)
        .at_least(:once)
      call
    end
    it 'counts only records and their interviews with a gender attribute' do
      create :application_record, gender: nil
      create :application_record, gender: ''
      expect(call).to contain_exactly ['Female', 0, 0]
    end
    it 'counts records/interviews whose gender is not of the gender_options' do
      create :application_record, gender: 'Male'
      expect(call).to contain_exactly ['Female', 0, 0], ['Male', 1, 0]
    end
  end

  describe 'self.eeo_data' do
    # all this method does is call other methods and put the values returned
    # in a hash.
    before :each do
      @department = create :department
      @start_date = 1.week.ago
      @end_date = 1.week.since
      @relation = ApplicationRecord.between(@start_date, @end_date)
                                   .in_department(@department.id)
    end
    let :call do
      ApplicationRecord.eeo_data @start_date, @end_date, @department.id
    end
    it 'calls AR#between to gather application records' do
      expect(ApplicationRecord).to receive(:between)
        .with(@start_date, @end_date)
        .and_return(@relation)
      # returns an ActiveRecord relation
      call
    end
    it 'calls AR#in_department to filter application records' do
      expect(ApplicationRecord).to receive(:in_department)
        .with(@department.id)
        .and_return(@relation)
      # returns an ActiveRecord relation
      call
    end
    it 'calls AR#ethnicity_eeo_data to populate hash with ethnicity numbers' do
      expect(ApplicationRecord).to receive(:ethnicity_eeo_data)
        .with(@relation)
        .and_return('some values')
      call
      expect(call[:ethnicities]).to eql 'some values'
    end
    it 'calls AR#gender_eeo_data to assign values to genders key in hash' do
      expect(ApplicationRecord).to receive(:gender_eeo_data)
        .with(@relation)
        .and_return('something')
      call
      expect(call[:genders]).to eql 'something'
    end
    it 'calls AR#combined_eeo_data to populate hash with combo numbers' do
      expect(ApplicationRecord).to receive(:combined_eeo_data)
        .with(@relation)
        .and_return('combo values')
      call
      expect(call[:combined_data]).to eql 'combo values'
    end
    it 'returns a hash' do
      expect(call).to be_a Hash
    end
  end
end
