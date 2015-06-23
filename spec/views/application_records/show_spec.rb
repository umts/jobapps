require 'rails_helper'

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
      it 'contains a form to reject the application and provide a staff note'
      it 'contains a form to accept the application and schedule an interview'
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
          it 'shows when the interview is scheduled'
          it 'contains a link to a calendar export file'
          it 'contains a form to reschedule an interview'
          it 'contains a form to mark interview as complete'
        end
        context 'interview is complete' do
          before :each do
            @interview.update completed: true
            assign :interview, @interview
          end
          it 'shows when the interview occurred'
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
      it 'explains that the application has not been reviewed'
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
            expect(rendered).to include 'interview is scheduled'
          end
          it 'contains the time and date when the interview is scheduled'
        end
        context 'interview is complete' do
          before :each do
            @interview.update completed: true
            assign :interview, @interview
          end
          it 'contains text saying that the interview has occurred'
          it 'contains the time and date when the interview is scheduled'
        end
      end
      context 'interview not present' do
        before :each do
          @interview.delete
          assign :interview, nil
        end
        it 'contains text saying application has been denied'
      end
    end
  end
end
