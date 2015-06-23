require 'rails_helper'

describe 'application_records/show.haml' do
  context 'current user is staff' do
    context 'application not reviewed' do
      it 'contains a form to reject the application and provide a staff note'
      it 'contains a form to accept the application and schedule an interview'
    end
    context 'application reviewed' do
      context 'staff note present' do
        it 'contains the staff note'
      end
      context 'interview present' do
        context 'interview is not complete' do
          it 'shows when the interview is scheduled'
          it 'contains a link to a calendar export file'
          it 'contains a form to reschedule an interview'
          it 'contains a form to mark interview as complete'
        end
        context 'interview is complete' do
          it 'shows when the interview occurred'
        end
      end
    end
  end
  context 'current user is student' do
    context 'application not reviewed' do
      it 'explains that the application has not been reviewed'
    end
    context 'application reviewed' do
      context 'interview present' do
        context 'interview is not complete' do
          it 'contains text saying that the interview is scheduled'
          it 'contains the time and date when the interview is scheduled'
        end
        context 'interview is complete' do
          it 'contains text saying that the interview has occurred'
          it 'contains the time and date when the interview is scheduled'
        end
      end
      context 'interview not present' do
        it 'contains text saying application has been denied'
      end
    end
  end
end
