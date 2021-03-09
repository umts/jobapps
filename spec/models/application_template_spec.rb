# frozen_string_literal: true

require 'rails_helper'

describe ApplicationTemplate do
  describe 'create_draft' do
    before :each do
      @application_template = create :application_template,
                                     :with_questions,
                                     email: 'something@example.com'
      @user = create :user
    end
    let :call do
      @application_template.create_draft @user
    end
    context 'pre-existing draft belonging to user' do
      before :each do
        create :application_draft,
               application_template: @application_template,
               user: @user
      end
      it 'returns false' do
        expect(call).to be false
      end
    end
    context 'no pre-existing draft' do
      it 'creates an application template draft' do
        expect { call }.to change { ApplicationDraft.count }.by 1
      end
      it 'returns the draft' do
        expect(call).to be_a ApplicationDraft
      end
      it 'sets the user of the draft to the user argument' do
        expect(call.user).to eql @user
      end
      it 'sets the email of the draft to be same as template email' do
        expect(call.email).to eql @application_template.email
      end
      it 'sets the application template of the draft to the current one' do
        expect(call.application_template).to eql @application_template
      end
      it 'adds the questions of the application template to the draft' do
        expect(call.questions.size).to eql @application_template.questions.size
      end
    end
  end
  describe 'draft_belonging_to' do
    before :each do
      @user = create :user
      other_user = create :user
      @application_template = create :application_template
      @draft = create :application_draft,
                      application_template: @application_template,
                      user: @user
      # other draft
      create :application_draft,
             application_template: @application_template,
             user: other_user
    end
    it 'returns the application template draft belonging to the user' do
      expect(@application_template.draft_belonging_to @user).to eql @draft
    end
  end

  describe 'draft_belonging_to?' do
    before :each do
      @user = create :user
      @application_template = create :application_template
    end
    let :call do
      @application_template.draft_belonging_to? @user
    end
    it 'returns false if a draft does not exist for the user in question' do
      expect(call).to be false
    end
    it 'returns true if a draft does exist for the user in question' do
      create :application_draft, user: @user,
                                 application_template: @application_template
      expect(call).to be true
    end
  end
end
