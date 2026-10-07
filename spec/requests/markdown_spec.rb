# frozen_string_literal: true

require 'rails_helper'

describe 'Markdown' do
  describe 'POST /markdown/explanation' do
    subject(:submit) { post '/markdown/explanation', params: { preview_input: input } }

    let(:input) { 'input' }

    shared_examples 'an authorized markdown user' do |role|
      context "with #{role} privilege" do
        before { when_current_user_is role }

        it 'returns a 200' do
          submit
          expect(response).to have_http_status(:ok)
        end

        it 'returns the input' do
          submit
          expect(response.body).to include(input)
        end
      end
    end

    it_behaves_like 'an authorized markdown user', :admin
    it_behaves_like 'an authorized markdown user', :staff

    context 'with student privilege' do
      before { when_current_user_is :student }

      it 'returns a 403' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
