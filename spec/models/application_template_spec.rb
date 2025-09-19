# frozen_string_literal: true

require 'rails_helper'

describe ApplicationTemplate do
  describe '#create_draft' do
    subject(:call) { application_template.create_draft user }

    let :application_template do
      create(:application_template, :with_questions, email: 'something@example.com')
    end
    let(:user) { create(:user) }

    context 'with a pre-existing draft belonging to user' do
      before do
        create(:application_draft, application_template:, user:)
      end

      it 'returns false' do
        expect(call).to be(false)
      end
    end

    context 'without a pre-existing draft' do
      it 'creates an application template draft' do
        expect { call }.to change(ApplicationDraft, :count).by 1
      end

      it 'returns the draft' do
        expect(call).to be_a(ApplicationDraft)
      end

      it 'sets the user of the draft to the user argument' do
        expect(call.user).to eq(user)
      end

      it 'sets the email of the draft to be same as template email' do
        expect(call.email).to eq(application_template.email)
      end

      it 'sets the application template of the draft to the current one' do
        expect(call.application_template).to eq(application_template)
      end

      it 'adds the questions of the application template to the draft' do
        expect(call.questions.size).to eq(application_template.questions.size)
      end
    end
  end

  describe '#draft_belonging_to' do
    let(:user) { create(:user) }
    let(:application_template) { create(:application_template) }
    let!(:draft) { create(:application_draft, application_template:, user:) }

    before do
      create(:application_draft, application_template:, user: create(:user))
    end

    it 'returns the application template draft belonging to the user' do
      expect(application_template.draft_belonging_to user).to eq(draft)
    end
  end

  describe '#draft_belonging_to?' do
    subject :call do
      application_template.draft_belonging_to? user
    end

    let(:application_template) { create(:application_template) }
    let(:user) { create(:user) }

    it 'returns false if a draft does not exist for the user in question' do
      expect(call).to be(false)
    end

    it 'returns true if a draft does exist for the user in question' do
      create(:application_draft, user:, application_template:)
      expect(call).to be(true)
    end
  end
end
