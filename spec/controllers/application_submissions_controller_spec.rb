# frozen_string_literal: true

require 'rails_helper'

describe ApplicationSubmissionsController do
  it_behaves_like 'an access-controlled resource', record: -> { create(:application_submission).id }, routes: [
    %i[post review member],
    %i[post toggle_saved_for_later member]
  ]

  it 'denies the reports to users who manage no positions' do
    when_current_user_is :anyone
    %i[csv_export eeo_data past_applications].each do |action|
      expect { get action, format: :csv }.to raise_error(ActionPolicy::Unauthorized)
    end
  end

  describe 'POST #create' do
    let(:position) { create(:position) }
    let :params do
      {
        position_id: position.id,
        user: { email: 'applicant@umass.edu' },
        data: {
          'response_1' => 'No',
          'prompt_1' => 'Do you like cats',
          'response_2' => '10/07/2015',
          'prompt_2' => 'Another question',
          'response_3' => '',
          'prompt_3' => 'This thing'
        },
        unavailability: {
          'sunday_7AM' => '0',
          'sunday_8AM' => '0',
          'tuesday_11AM' => '1',
          'tuesday_12AM' => '1',
          'friday_4PM' => '1',
          'friday_5PM' => '0'
        }
      }
    end
    let(:submit) { post :create, params: }

    before { create(:application_template, position:, unavailability_enabled: true) }

    context 'when the current user is a student' do
      let(:user) { create(:user) }

      before { when_current_user_is user }

      it 'creates an application record as specified' do
        expect { submit }.to change(ApplicationSubmission, :count).by(1)
      end

      it 'updates the applicant email from the form' do
        submit
        expect(user.reload.email).to eq 'applicant@umass.edu'
      end

      it 'creates an unavailability' do
        expect { submit }.to change(Unavailability, :count).by(1)
      end

      it 'emails the subscribers to the position of the application record' do
        application_submission = create(:application_submission, user:, position:)
        allow(ApplicationSubmission).to receive(:create).and_return(application_submission)
        allow(application_submission).to receive(:email_subscribers)
        submit
        expect(application_submission).to have_received(:email_subscribers).with(applicant: user)
      end

      context 'with an invalid email' do
        let(:params) { super().merge(user: { email: 'applicant@localhost' }) }

        it 'does not create an application record' do
          expect { submit }.not_to change(ApplicationSubmission, :count)
        end

        it 'does not update the applicant email' do
          expect { submit }.not_to(change { user.reload.email })
        end

        it 'shows the validation errors' do
          submit
          expect(flash[:errors]).to include 'Email is invalid'
        end
      end
    end

    context 'when the current user is a manager' do
      let(:user) { create(:user, :manager) }

      before { when_current_user_is user }

      it 'creates an application record as specified' do
        expect { submit }.to change(ApplicationSubmission, :count).by(1)
      end

      it 'emails the subscribers to the position of the application record' do
        application_submission = create(:application_submission, user:, position:)
        allow(ApplicationSubmission).to receive(:create).and_return(application_submission)
        allow(application_submission).to receive(:email_subscribers)
        submit
        expect(application_submission).to have_received(:email_subscribers).with(applicant: user)
      end

      it 'redirects to the student dashboard' do
        submit
        expect(response).to redirect_to student_dashboard_path
      end
    end
  end

  describe 'GET #csv_export' do
    let(:position) { create(:position) }

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

    before do
      when_current_user_is create(:user, :manager, managing: position)
      allow(ApplicationSubmission).to receive(:in_positions).and_return ApplicationSubmission.none
    end

    context 'when submitting with the position id param' do
      let(:extra_params) { { position_ids: [position.id, create(:position).id] } }

      it 'calls .in_positions with only the requested positions the user manages' do
        submit
        expect(ApplicationSubmission).to have_received(:in_positions).with([position.id])
      end
    end

    context 'when submitting without the position id param' do
      it 'calls .in_positions with every position the user manages' do
        create(:position)
        submit
        expect(ApplicationSubmission).to have_received(:in_positions).with([position.id])
      end

      it 'calls .between with the correct parameters' do
        allow(ApplicationSubmission).to receive(:between)
        submit
        expect(ApplicationSubmission).to have_received(:between).with(params[:start_date], params[:end_date])
      end

      it 'assigns the correct records to the instance variable' do
        allow(ApplicationSubmission).to receive(:between).and_return :a_record
        submit
        expect(assigns.fetch(:records)).to be(:a_record)
      end
    end

    context 'when the current user is an admin' do
      before { when_current_user_is :admin }

      it 'calls .in_positions with every position' do
        other = create(:position)
        submit
        expect(ApplicationSubmission).to have_received(:in_positions).with(contain_exactly(position.id, other.id))
      end
    end
  end

  describe 'GET #eeo_data' do
    let(:position) { create(:position) }
    let :params do
      {
        eeo_start_date: 1.week.ago.to_date.to_fs(:db),
        eeo_end_date: 1.week.since.to_date.to_fs(:db)
      }
    end

    before do
      when_current_user_is create(:user, :manager, managing: position)
    end

    context 'when submitting with the position ID param' do
      let :submit do
        get :eeo_data, params: params.merge(position_ids: [position.id, create(:position).id])
      end

      it 'calls .eeo_data with only the requested positions the user manages' do
        allow(ApplicationSubmission).to receive(:eeo_data)
        submit
        expect(ApplicationSubmission).to have_received(:eeo_data)
          .with(params[:eeo_start_date], params[:eeo_end_date], [position.id])
      end

      it 'assigns the correct records to the instance variable' do
        records = ApplicationSubmission.none
        allow(ApplicationSubmission).to receive(:eeo_data).and_return records
        submit
        expect(assigns.fetch(:records)).to eql records
      end
    end

    context 'when submitting without the position ID param' do
      let(:submit) { get :eeo_data, params: }

      it 'calls .eeo_data with every position the user manages' do
        create(:position)
        allow(ApplicationSubmission).to receive(:eeo_data).and_return(ApplicationSubmission.none)
        submit
        expect(ApplicationSubmission).to have_received(:eeo_data)
          .with(params[:eeo_start_date], params[:eeo_end_date], [position.id])
      end
    end
  end

  describe 'GET #past_applications' do
    let(:position) { create(:position) }
    let :params do
      {
        records_start_date: 1.week.ago.to_date.to_fs(:db),
        records_end_date: Time.zone.today.to_fs(:db)
      }
    end

    before do
      when_current_user_is create(:user, :manager, managing: position)
    end

    context 'when submitting with the position ID param' do
      let(:submit) do
        get :past_applications, params: params.merge(position_ids: [position.id, create(:position).id])
      end

      it 'calls .between with the correct parameters' do
        allow(ApplicationSubmission).to receive(:between).and_return ApplicationSubmission.none
        submit
        expect(ApplicationSubmission).to have_received(:between)
          .with(params[:records_start_date], params[:records_end_date])
      end

      it 'calls .in_positions with only the requested positions the user manages' do
        allow(ApplicationSubmission).to receive(:in_positions).and_return ApplicationSubmission.none
        submit
        expect(ApplicationSubmission).to have_received(:in_positions).with([position.id])
      end
    end

    context 'when submitting without the position ID param' do
      let(:submit) { get :past_applications, params: }

      it 'calls .in_positions with every position the user manages' do
        create(:position)
        allow(ApplicationSubmission).to receive(:in_positions).and_return ApplicationSubmission.none
        submit
        expect(ApplicationSubmission).to have_received(:in_positions).with([position.id])
      end
    end
  end

  describe 'POST #review' do
    let(:record) { create(:application_submission) }
    let(:interview) { { location: 'somewhere', scheduled: 1.day.since.strftime('%Y/%m/%d %H:%M') } }

    context 'when the current user manages the position' do
      before do
        when_current_user_is create(:user, :manager, managing: record.position)
      end

      context 'when the record is accepted' do
        let :submit do
          post :review, params: {
            id: record.id,
            application_submission: { accepted: 'true' },
            interview: interview
          }
        end

        it 'creates an interview as given' do
          expect { submit }.to change(Interview, :count).by(1)
        end

        it 'marks record as reviewed' do
          submit
          expect(record.reload.reviewed).to be(true)
        end

        it 'redirects to staff dashboard' do
          submit
          expect(response).to redirect_to(staff_dashboard_path)
        end
      end

      context 'when the record is not accepted' do
        let :submit do
          post :review, params: {
            id: record.id,
            application_submission: {
              accepted: 'false',
              staff_note: 'because I said so'
            }
          }
        end

        it 'updates record with staff note given' do
          allow(ApplicationSubmission).to receive(:find).and_return(record)
          allow(record).to receive(:deny)
          submit
          expect(record).to have_received(:deny)
        end

        it 'marks record as reviewed' do
          submit
          expect(record.reload.reviewed).to be(true)
        end

        it 'redirects to staff dashboard' do
          submit
          expect(response).to redirect_to(staff_dashboard_path)
        end
      end
    end
  end

  describe 'POST #toggle_saved_for_later' do
    before do
      when_current_user_is create(:user, :manager, managing: record.position)
    end

    context 'when something goes wrong' do
      let(:record) { create(:application_submission, saved_for_later: false) }

      let(:submit) do
        post :toggle_saved_for_later,
             params: { id: record.id, commit: 'Save for later',
                       application_submission: { mail_note_for_later: true } }
      end

      it "doesn't save the record" do
        submit
        expect(record.saved_for_later).to be(false)
      end

      it 'puts the errors in the flash' do
        submit
        expect(flash[:errors]).to include("Note for later can't be blank")
      end
    end
  end

  describe 'GET #show' do
    let(:record) { create(:application_submission, user: create(:user)) }

    let :submit do
      get :show, params: { id: record.id }
    end

    context 'when the current user is the student applicant' do
      before do
        when_current_user_is record.user
      end

      it 'renders the correct template' do
        submit
        expect(response).to render_template('show')
      end

      it 'assigns the correct variables' do
        submit
        expect(assigns.keys).to include('record', 'interview')
      end
    end

    context 'when the record belongs to another student' do
      let(:record) { create(:application_submission, user: create(:user)) }

      before do
        when_current_user_is :anyone
      end

      it 'does not allow access' do
        expect { submit }.to raise_error(ActionPolicy::Unauthorized)
      end
    end

    context 'with no current user' do
      before do
        when_current_user_is nil
      end

      it 'does not allow access' do
        expect { submit }.to raise_error(ActionPolicy::Unauthorized)
      end
    end

    context 'when the current user manages the position' do
      before do
        when_current_user_is create(:user, :manager, managing: record.position)
      end

      it 'renders the correct template' do
        submit
        expect(response).to render_template('show')
      end

      it 'assigns the correct variables' do
        submit
        expect(assigns.keys).to include('record', 'interview')
      end

      it 'generates a pdf' do
        get :show, params: { id: record.id, format: :pdf }
        expect(response.headers['Content-Type']).to eql 'application/pdf'
      end
    end
  end

  describe 'unreject' do
    before do
      when_current_user_is create(:user, :manager, managing: record.position)
    end

    let!(:record) { create(:application_submission, reviewed: 'true') }
    let(:submit) { post :unreject, params: { id: record.id } }

    it 'changes attribute reviewed to false' do
      submit
      expect(record.reload.reviewed).to be false
    end
  end
end
