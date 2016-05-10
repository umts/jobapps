require 'rails_helper'

describe ApplicationRecordsController do
  describe 'POST #create' do
    before :each do
      @position = create :position
      @data = { 'response_1' => 'No',
                'prompt_1' => 'Do you like cats',
                'response_2' => '10/07/2015',
                'prompt_2' => 'Another question',
                'response_3' => '',
                'prompt_3' => 'This thing' }

      @user = Hash.new
    end
    let :submit do
      post :create, position_id: @position.id,
                    data: @data,
                    user: @user
    end
    context 'current user is nil' do
      it 'creates a user' do
        when_current_user_is nil
        @user = {
          first_name: 'FirstName',
          last_name:  'LastName',
          email:      'flastnam@umass.edu'
        }
        expect { submit }
          .to change { User.count }
          .by 1
      end
    end
    context 'student' do
      let!(:user) { create :user, :student }
      before(:each) { when_current_user_is user }
      it 'creates an application record as specified' do
        expect { submit }
          .to change { ApplicationRecord.count }
          .by 1
      end
      it 'emails the subscribers to the position of the application record' do
        expect_any_instance_of(ApplicationRecord)
          .to receive(:email_subscribers)
          .with(applicant: user)
        submit
      end
    end
    context 'staff' do
      let!(:user) { create :user, :staff }
      before(:each) { when_current_user_is user }
      it 'creates an application record as specified' do
        expect { submit }
          .to change { ApplicationRecord.count }
          .by 1
      end
      it 'emails the subscribers to the position of the application record' do
        expect_any_instance_of(ApplicationRecord)
          .to receive(:email_subscribers)
          .with(applicant: user)
        submit
      end
      it 'shows the application_receipt message' do
        expect_flash_message :application_receipt
        submit
      end
      it 'redirects to the student dashboard' do
        submit
        expect(response).to redirect_to student_dashboard_path
      end
    end
  end

  describe 'GET #csv_export' do
    before :each do
      when_current_user_is :staff
      @start_date = 1.week.ago.to_date
      @end_date = Time.zone.today
      @department = create :department
    end
    context 'submitting with the department ID param' do
      let :submit do
        get :csv_export,
            start_date: @start_date.strftime('%m/%d/%Y'),
            end_date: @end_date.strftime('%m/%d/%Y'),
            department_ids: @department.id
      end
      it 'calls AR#in_department with the correct parameters' do
        expect(ApplicationRecord).to receive(:in_department)
          .with(@department.id.to_s)
          .and_return ApplicationRecord.none
        # Needs to return something, because we must call
        # other methods on what it returns later.
        submit
      end
      it 'calls AR#between with the correct parameters' do
        expect(ApplicationRecord).to receive(:between)
          .with @start_date, @end_date
        submit
      end
      it 'assigns the correct records to the instance variable' do
        expect(ApplicationRecord).to receive(:between).and_return 'whatever'
        submit
        expect(assigns.fetch :records).to eql 'whatever'
      end
    end
    context 'submitting without the department ID param' do
      let :submit do
        get :csv_export,
            start_date: @start_date.strftime('%m/%d/%Y'),
            end_date: @end_date.strftime('%m/%d/%Y')
      end
      it 'calls AR#in_department with all department IDs' do
        expect(ApplicationRecord).to receive(:in_department)
          .with(Department.all.pluck(:id)).and_return ApplicationRecord.none
        # must return something - another method is called on the results
        submit
      end
      it 'calls AR#between with the correct parameters' do
        expect(ApplicationRecord).to receive(:between)
          .with @start_date, @end_date
        submit
      end
      it 'assigns the correct records to the instance variable' do
        expect(ApplicationRecord).to receive(:between).and_return 'whatever'
        submit
        expect(assigns.fetch :records).to eql 'whatever'
      end
    end
  end

  describe 'GET #eeo_data' do
    before :each do
      when_current_user_is :staff
      @start_date = 1.week.ago.to_date
      @end_date = 1.week.since.to_date
      @department = create :department
    end
    context 'submitting with the department ID param' do
      let :submit do
        get :eeo_data,
            eeo_start_date: @start_date.strftime('%m/%d/%Y'),
            eeo_end_date: @end_date.strftime('%m/%d/%Y'),
            department_ids: @department.id
      end
      it 'calls AR#eeo_data with the correct parameters' do
        expect(ApplicationRecord).to receive(:eeo_data)
          .with(@start_date, @end_date, @department.id.to_s)
        # to_s because params are a string
        submit
      end
      it 'assigns the correct records to the instance variable' do
        record = ApplicationRecord.none
        expect(ApplicationRecord).to receive(:eeo_data).and_return record
        submit
        expect(assigns.fetch :records).to eql record
      end
    end
    context 'submitting without the department ID param' do
      let :submit do
        get :eeo_data,
            eeo_start_date: @start_date.strftime('%m/%d/%Y'),
            eeo_end_date: @end_date.strftime('%m/%d/%Y')
      end
      # the third argument in this case is not from the params,
      # it is a given array
      it 'calls AR#eeo_data with the correct parameters' do
        expect(ApplicationRecord).to receive(:eeo_data)
          .with(@start_date, @end_date, Department.all.pluck(:id))
          .and_return ApplicationRecord.none
        submit
      end
      it 'assigns the correct records to the instance variable' do
        record = ApplicationRecord.none
        expect(ApplicationRecord).to receive(:eeo_data).and_return record
        submit
        expect(assigns.fetch :records).to eql record
      end
    end
  end

  describe 'GET #past_applications' do
    before :each do
      when_current_user_is :staff
      @start_date = 1.week.ago.to_date
      @end_date = Time.zone.today
      @department = create :department
    end
    context 'submitting with the department ID param' do
      let :submit do
        get :past_applications,
            records_start_date: @start_date.strftime('%m/%d/%Y'),
            records_end_date: @end_date.strftime('%m/%d/%Y'),
            department_ids: @department.id
      end
      it 'calls AR#between with the correct parameters' do
        expect(ApplicationRecord).to receive(:between)
          .with @start_date, @end_date
        submit
      end
      it 'calls AR#in_department with the correct parameters' do
        expect(ApplicationRecord).to receive(:in_department)
          .with(@department.id.to_s)
          .and_return ApplicationRecord.none
        #  needs to return something - other methods are called on the results
        submit
      end
      it 'assigns the correct records to the instance variable' do
        expect(ApplicationRecord).to receive(:between).and_return 'whatever'
        submit
        expect(assigns.fetch :records).to eql 'whatever'
      end
    end
    context 'submitting without the department ID param' do
      let :submit do
        get :past_applications,
            records_start_date: @start_date.strftime('%m/%d/%Y'),
            records_end_date: @end_date.strftime('%m/%d/%Y')
      end
      it 'calls AR#between with the correct parameters' do
        expect(ApplicationRecord).to receive(:between)
          .with @start_date, @end_date
        submit
      end
      it 'calls AR#in_department with all department IDs' do
        # must return something, as a method is called on the results
        expect(ApplicationRecord).to receive(:in_department)
          .with(Department.all.pluck(:id)).and_return ApplicationRecord.none
        submit
      end
      it 'assigns the correct records to the instance variable' do
        expect(ApplicationRecord).to receive(:between).and_return 'whatever'
        submit
        expect(assigns.fetch :records).to eql 'whatever'
      end
    end
  end

  describe 'POST #review' do
    before :each do
      @record = create :application_record
      @interview = { location: 'somewhere',
                     scheduled: 1.day.since.strftime('%Y/%m/%d %H:%M') }
    end
    # Didn't define a let block since the action takes different
    # parameters under different circumstances
    context 'student' do
      it 'does not allow access' do
        when_current_user_is :student
        post :review, id: @record.id
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'staff' do
      before :each do
        when_current_user_is :staff
      end
      context 'record accepted' do
        let :submit do
          post :review,
               id: @record.id,
               accepted: 'true',
               interview: @interview
        end
        it 'creates an interview as given' do
          expect { submit }
            .to change { Interview.count }
            .by 1
        end
        it 'marks record as reviewed' do
          submit
          expect(@record.reload.reviewed).to be true
        end
        it 'redirects to staff dashboard' do
          submit
          expect(response).to redirect_to staff_dashboard_path
        end
      end
      context 'record not accepted' do
        before :each do
          @staff_note = 'because I said so'
        end
        let :submit do
          post :review,
               id: @record.id,
               accepted: 'false',
               staff_note: @staff_note
        end
        it 'updates record with staff note given' do
          expect_any_instance_of(ApplicationRecord)
            .to receive(:deny_with)
            .with @staff_note
          submit
        end
        it 'marks record as reviewed' do
          submit
          expect(@record.reload.reviewed).to be true
        end
        it 'displays application_review message' do
          expect_flash_message :application_review
          submit
        end
        it 'redirects to staff dashboard' do
          submit
          expect(response).to redirect_to staff_dashboard_path
        end
      end
    end
  end

  describe 'GET #show' do
    before :each do
      @record = create :application_record, user: (create :user, :student)
    end
    let :submit do
      get :show, id: @record.id
    end
    context 'applicant student' do
      before :each do
        when_current_user_is @record.user
      end
      it 'renders the correct template' do
        submit
        expect(response).to render_template 'show'
      end
      it 'assigns the correct variables' do
        submit
        expect(assigns.keys).to include 'record', 'interview'
        # why interview?
      end
    end
    context 'record belongs to another student' do
      before :each do
        student_1 = create :user, :student
        student_2 = create :user, :student
        @record = create :application_record, user: student_1
        when_current_user_is student_2
      end
      it 'does not allow access' do
        submit
        expect(response).to have_http_status :unauthorized
        expect(response).not_to render_template 'show'
      end
    end
    context 'staff' do
      before :each do
        when_current_user_is :staff
      end
      it 'renders the correct template' do
        submit
        expect(response).to render_template 'show'
      end
      it 'assigns the correct variables' do
        submit
        expect(assigns.keys).to include 'record', 'interview'
      end
    end
  end
end
