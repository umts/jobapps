# frozen_string_literal: true

require 'rails_helper'

describe ApplicationSubmissionsController do
  it_behaves_like 'an access-controlled resource', routes: [
    %i[get csv_export collection],
    %i[get eeo_data collection],
    %i[get past_applications collection],
    %i[post review member],
    %i[post toggle_saved_for_later member]
  ]

  describe 'POST #create' do
    before do
      @position = create(:position)
      create(:application_template, position: @position, unavailability_enabled: true)
      @data = { 'response_1' => 'No',
                'prompt_1' => 'Do you like cats',
                'response_2' => '10/07/2015',
                'prompt_2' => 'Another question',
                'response_3' => '',
                'prompt_3' => 'This thing' }
      @unavailability = { 'sunday_7AM' => '0',
                          'sunday_8AM' => '0',
                          'tuesday_11AM' => '1',
                          'tuesday_12AM' => '1',
                          'friday_4PM' => '1',
                          'friday_5PM' => '0' }

      @user = {}
    end

    let :submit do
      post :create, params: { position_id: @position.id,
                              data: @data,
                              user: @user,
                              unavailability: @unavailability }
    end

    context 'current user is nil' do
      it 'creates a user' do
        when_current_user_is nil
        @user = {
          first_name: 'FirstName',
          last_name: 'LastName',
          email: 'flastnam@umass.edu'
        }
        expect { submit }
          .to change(User, :count)
          .by 1
      end
    end

    context 'student' do
      let!(:user) { create(:user, :student) }

      before { when_current_user_is user }

      it 'creates an application record as specified' do
        expect { submit }
          .to change(ApplicationSubmission, :count)
          .by 1
      end

      it 'creates an unavailability' do
        expect { submit }
          .to change(Unavailability, :count)
          .by 1
      end

      it 'emails the subscribers to the position of the application record' do
        expect_any_instance_of(ApplicationSubmission)
          .to receive(:email_subscribers)
          .with applicant: user
        submit
      end
    end

    context 'staff' do
      let!(:user) { create(:user, :staff) }

      before { when_current_user_is user }

      it 'creates an application record as specified' do
        expect { submit }
          .to change(ApplicationSubmission, :count)
          .by 1
      end

      it 'emails the subscribers to the position of the application record' do
        expect_any_instance_of(ApplicationSubmission)
          .to receive(:email_subscribers)
          .with applicant: user
        submit
      end

      it 'redirects to the student dashboard' do
        submit
        expect(response).to redirect_to student_dashboard_path
      end
    end
  end

  describe 'GET #csv_export' do
    before do
      when_current_user_is :staff
      @department = create(:department)
    end

    let :params do
      {
        format: :csv,
        start_date: 1.week.ago.to_date.to_fs(:db),
        end_date: Time.zone.today.to_fs(:db)
      }
    end

    let(:extra_params) { {} }
    let :submit do
      get :csv_export, params: params.merge(extra_params)
    end

    context 'submitting with the department ID param' do
      let(:extra_params) { { department_ids: [@department.id] } }

      it 'calls AR#in_department with the correct parameters' do
        create(:department)
        # Needs to return something, because we must call
        # other methods on what it returns later.
        expect(ApplicationSubmission).to receive(:in_department)
          .with([@department.id.to_s])
          .and_return ApplicationSubmission.none
        submit
      end

      it 'calls AR#between with the correct parameters' do
        expect(ApplicationSubmission).to receive(:between)
          .with params[:start_date], params[:end_date]
        submit
      end

      it 'assigns the correct records to the instance variable' do
        expect(ApplicationSubmission).to receive(:between).and_return 'whatever'
        submit
        expect(assigns.fetch :records).to eql 'whatever'
      end
    end

    context 'submitting without the department ID param' do
      it 'calls AR#in_department with all department IDs' do
        expect(ApplicationSubmission).to receive(:in_department)
          .with(Department.pluck(:id)).and_return ApplicationSubmission.none
        # must return something - another method is called on the results
        submit
      end

      it 'calls AR#between with the correct parameters' do
        expect(ApplicationSubmission).to receive(:between)
          .with params[:start_date], params[:end_date]
        submit
      end

      it 'assigns the correct records to the instance variable' do
        expect(ApplicationSubmission).to receive(:between).and_return 'whatever'
        submit
        expect(assigns.fetch :records).to eql 'whatever'
      end
    end
  end

  describe 'GET #eeo_data' do
    let :params do
      {
        eeo_start_date: 1.week.ago.to_date.to_fs(:db),
        eeo_end_date: 1.week.since.to_date.to_fs(:db)
      }
    end

    before do
      when_current_user_is :staff
      @department = create(:department)
    end

    context 'submitting with the department ID param' do
      let :submit do
        get :eeo_data, params: params.merge(department_ids: @department.id)
      end

      it 'calls AR#eeo_data with the correct parameters' do
        expect(ApplicationSubmission).to receive(:eeo_data)
          .with(params[:eeo_start_date], params[:eeo_end_date], @department.id.to_s)
        # to_s because params are a string
        submit
      end

      it 'assigns the correct records to the instance variable' do
        record = ApplicationSubmission.none
        expect(ApplicationSubmission).to receive(:eeo_data).and_return record
        submit
        expect(assigns.fetch :records).to eql record
      end
    end

    context 'submitting without the department ID param' do
      let(:submit) { get :eeo_data, params: }

      # the third argument in this case is not from the params,
      # it is a given array
      it 'calls AR#eeo_data with the correct parameters' do
        expect(ApplicationSubmission).to receive(:eeo_data)
          .with(params[:eeo_start_date], params[:eeo_end_date], Department.pluck(:id))
          .and_return ApplicationSubmission.none
        submit
      end

      it 'assigns the correct records to the instance variable' do
        record = ApplicationSubmission.none
        expect(ApplicationSubmission).to receive(:eeo_data).and_return record
        submit
        expect(assigns.fetch :records).to eql record
      end
    end
  end

  describe 'GET #past_applications' do
    let :params do
      {
        records_start_date: 1.week.ago.to_date.to_fs(:db),
        records_end_date: Time.zone.today.to_fs(:db)
      }
    end

    before do
      when_current_user_is :staff
      @department = create(:department)
    end

    context 'submitting with the department ID param' do
      let(:submit) do
        get :past_applications, params: params.merge(department_ids: @department.id)
      end

      it 'calls AR#between with the correct parameters' do
        expect(ApplicationSubmission).to receive(:between)
          .with params[:records_start_date], params[:records_end_date]
        submit
      end

      it 'calls AR#in_department with the correct parameters' do
        expect(ApplicationSubmission).to receive(:in_department)
          .with(@department.id.to_s)
          .and_return ApplicationSubmission.none
        #  needs to return something - other methods are called on the results
        submit
      end

      it 'assigns the correct records to the instance variable' do
        expect(ApplicationSubmission).to receive(:between).and_return 'whatever'
        submit
        expect(assigns.fetch :records).to eql 'whatever'
      end
    end

    context 'submitting without the department ID param' do
      let(:submit) { get :past_applications, params: }

      it 'calls AR#between with the correct parameters' do
        expect(ApplicationSubmission).to receive(:between)
          .with params[:records_start_date], params[:records_end_date]
        submit
      end

      it 'calls AR#in_department with all department IDs' do
        # must return something, as a method is called on the results
        expect(ApplicationSubmission).to receive(:in_department)
          .with(Department.pluck(:id)).and_return ApplicationSubmission.none
        submit
      end

      it 'assigns the correct records to the instance variable' do
        expect(ApplicationSubmission).to receive(:between).and_return 'whatever'
        submit
        expect(assigns.fetch :records).to eql 'whatever'
      end
    end
  end

  describe 'POST #review' do
    before do
      @record = create(:application_submission)
      @interview = { location: 'somewhere',
                     scheduled: 1.day.since.strftime('%Y/%m/%d %H:%M') }
    end

    # Didn't define a let block since the action takes different
    # parameters under different circumstances
    context 'staff' do
      before do
        when_current_user_is :staff
      end

      context 'record accepted' do
        let :submit do
          post :review, params: {
            id: @record.id,
            application_submission: { accepted: 'true' },
            interview: @interview
          }
        end

        it 'creates an interview as given' do
          expect { submit }
            .to change(Interview, :count)
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
        before do
          @staff_note = 'because I said so'
        end

        let :submit do
          post :review, params: {
            id: @record.id, application_submission: {
              accepted: 'false',
              staff_note: @staff_note
            }
          }
        end

        it 'updates record with staff note given' do
          expect_any_instance_of(ApplicationSubmission).to receive(:deny)
          submit
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
    end
  end

  describe 'POST #toggle_saved_for_later' do
    before do
      when_current_user_is :staff
    end

    context 'something went wrong' do
      let!(:record) { create(:application_submission, saved_for_later: false) }
      let(:submit) do
        post :toggle_saved_for_later,
             params: {
               id: record.id, commit: 'Save for later',
               application_submission: { mail_note_for_later: true }
             }
      end

      it "doesn't save the record" do
        submit
        expect(record.saved_for_later).to be false
      end

      it 'puts the errors in the flash' do
        submit
        expect(flash[:errors]).to include "Note for later can't be blank"
      end
    end
  end

  describe 'GET #show' do
    before do
      @record = create(:application_submission, user: create(:user, :student))
    end

    let :submit do
      get :show, params: { id: @record.id }
    end

    context 'applicant student' do
      before do
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
      before do
        student1 = create(:user, :student)
        student2 = create(:user, :student)
        @record = create(:application_submission, user: student1)
        when_current_user_is student2
      end

      it 'does not allow access' do
        submit
        expect(response).to have_http_status :unauthorized
        expect(response).not_to render_template 'show'
      end
    end

    context 'no user' do
      before do
        when_current_user_is nil
      end

      it 'does not allow access' do
        submit
        expect(response).to have_http_status :unauthorized
        expect(response).not_to render_template 'show'
      end
    end

    context 'staff' do
      before do
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

      it 'generates a pdf by calling prawn' do
        get :show, params: { id: @record.id, format: :pdf }
        expect(response.headers['Content-Type']).to eql 'application/pdf'
      end
    end
  end

  describe 'unreject' do
    before do
      when_current_user_is :staff
    end

    let!(:record) { create(:application_submission, reviewed: 'true') }
    let(:submit) { post :unreject, params: { id: record.id } }

    it 'changes attribute reviewed to false' do
      submit
      expect(record.reload.reviewed).to be false
    end
  end
end
