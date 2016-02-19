require 'rails_helper'
include RSpecHtmlMatchers

describe 'dashboard/student.haml' do
  context 'interview is present' do
    before :each do
      @interview = create :interview
      assign :interviews, Array(@interview)
    end
    it 'displays the date, time, and location of the interview' do
      render
      expect(rendered).to include @interview.information
    end
    it 'contains an interview review link that reviews the application' do
      render
      action_path = application_record_path @interview.application_record
      expect(rendered).to have_tag '.interview_review_link' do
        with_tag 'a', with: { href: action_path }
      end
    end
  end
  context 'interview is not present' do
    before :each do
      assign :interviews, nil
      @department = create :department
      @position = create :position
      # hash mapping positions to departments
      assign :positions, Hash[@department, Array(@position)]
    end
    context 'student has already submitted an application' do
      before :each do
        @application_record = create :application_record
        # hash mapping application records to their positions
        assign :application_records, Hash[@position, Array(@application_record)]
      end
      context 'configured value notify of application denial reason is true' do
        before :each do
          allow_any_instance_of(ApplicationConfiguration)
            .to receive :configured_value
          allow_any_instance_of(ApplicationConfiguration)
            .to receive(:configured_value)
            .with([:on_application_denial, :notify_applicant], anything)
            .and_return true
        end
        it 'contains a link to review the application' do
          render
          action_path = application_record_path @application_record
          expect(rendered).to have_tag 'a', with: { href: action_path }
        end
      end
      context 'configured value notify of application denial reason is false' do
        before :each do
          allow_any_instance_of(ApplicationConfiguration)
            .to receive :configured_value
          allow_any_instance_of(ApplicationConfiguration)
            .to receive(:configured_value)
            .with([:on_application_denial, :notify_applicant], anything)
            .and_return false
        end
        context 'application is pending' do
          before :each do
            @application_record.update reviewed: false
          end
          it 'contains a link to review the application' do
            render
            action_path = application_record_path @application_record
            expect(rendered).to have_tag 'a', with: { href: action_path }
          end
        end
        context 'application has been reviewed' do
          before :each do
            @application_record.update reviewed: true
          end
          it 'does not contain a link to review the application' do
            render
            action_path = application_record_path @application_record
            expect(rendered).not_to have_tag 'a', with: { href: action_path }
          end
        end
      end
    end
    context 'student has not submitted an application' do
      before :each do
        assign :application_records, Hash.new
      end
      context 'applications are present for position' do
        it 'lists links to submit application for positions' do
          application = create :application_template,
                               position: @position,
                               active: true
          action_path = application_path(application)
          render
          expect(rendered).to have_tag 'a',
                                       with: { href: action_path }
        end
      end
      context 'no applications are present for position' do
        it 'does not list links to submit application for position' do
          application = create :application_template,
                               active: true
          action_path = application_path(application)
          render
          expect(rendered).not_to have_tag 'a',
                                           with: { href: action_path }
        end
      end
      context 'applications for the position are inactive' do
        it 'does not list the link to submit application for position' do
          application = create :application_template,
                               position: @position,
                               active: false
          action_path = application_path(application)
          render
          expect(rendered).not_to have_tag 'a',
                                           with: { href: action_path }
        end
      end
    end
  end
end
