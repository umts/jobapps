require 'rails_helper'
include RSpecHtmlMatchers

describe 'application_records/show.haml' do
  before :each do
    @record = create :application_record
  end
  context 'current user is staff' do
    before :each do
      when_current_user_is :staff, view: true
    end
    context 'application not reviewed' do
      before :each do
        @record.update reviewed: false
        assign :record, @record
      end
      it 'contains a form to reject the application and provide a staff note' do
        render
        action_path = review_application_record_path @record, accepted: false
        expect(rendered).to have_form action_path, :post do
          with_text_area :staff_note
        end
      end
      it 'contains form to accept the application and schedule an interview' do
        render
        action_path = review_application_record_path @record, accepted: true
        expect(rendered).to have_form action_path, :post do
          with_text_field 'interview[location]',
                          @record.position.default_interview_location
          with_tag 'input#interview_scheduled.datetimepicker'
        end
      end
    end
    context 'application reviewed' do
      before :each do
        @record.update reviewed: true
        assign :record, @record
      end
      context 'staff note present' do
        before :each do
          @note = 'note'
          @record.update staff_note: @note
          assign :record, @record
        end
        it 'contains the staff note' do
          render
          expect(rendered).to include @note
        end
      end
      context 'interview present' do
        before :each do
          @interview = create :interview, application_record: @record
        end
        context 'interview is not complete' do
          before :each do
            @interview.update completed: false
            assign :interview, @interview
          end
          it 'shows when the interview is scheduled' do
            render
            expect(rendered).to include @interview.information
          end
          it 'contains a link to a calendar export file' do
            render
            action_path = interview_path @interview, format: :ics
            expect(rendered).to have_tag '.export_link' do
              with_tag 'a', with: { href: action_path }
            end
          end
          it 'contains a form to reschedule an interview' do
            render
            action_path = reschedule_interview_path @interview
            expect(rendered).to have_form action_path, :post do
              with_tag 'input#scheduled.datetimepicker'
              with_text_field :location, @interview.location
            end
          end
          it 'contains a form to mark interview as complete' do
            render
            action_path = complete_interview_path @interview
            expect(rendered).to have_form action_path, :post
          end
        end
        context 'interview is complete' do
          before :each do
            @interview.update completed: true
            assign :interview, @interview
          end
          it 'shows when and where the interview occurred' do
            render
            expect(rendered).to include @interview.information
          end
        end
      end
    end
  end
  context 'current user is student' do
    before :each do
      when_current_user_is :student, view: true
    end
    context 'application not reviewed' do
      before :each do
        @record.update reviewed: false
        assign :record, @record
      end
      it 'explains that the application has not been reviewed' do
        render
        expect(rendered).to include 'has not yet been reviewed'
      end
    end
    context 'application reviewed' do
      before :each do
        @record.update reviewed: true
        assign :record, @record
      end
      context 'interview present' do
        before :each do
          @interview = create :interview
        end
        context 'interview is not complete' do
          before :each do
            @interview.update completed: false
            assign :interview, @interview
          end
          it 'contains text saying that the interview is scheduled' do
            render
            expect(rendered).to include 'interview is scheduled for'
          end
          it 'contains the time, date and location of the interview' do
            render
            expect(rendered).to include @interview.information
          end
        end
        context 'interview is complete' do
          before :each do
            @interview.update completed: true
            assign :interview, @interview
          end
          it 'contains text saying that the interview has occurred' do
            render
            expect(rendered).to include 'interview occurred on'
          end
          it 'contains the time, date and location of the interview' do
            render
            expect(rendered).to include @interview.information
          end
        end
      end
      context 'interview not present' do
        before :each do
          assign :interview, nil
        end
        it 'contains text saying application has been denied' do
          render
          expect(rendered).to include 'application has been denied'
        end
      end
    end
  end
end
