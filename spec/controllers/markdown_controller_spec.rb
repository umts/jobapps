# frozen_string_literal: true

require 'rails_helper'

describe MarkdownController do
  describe 'POST #explanation' do
    let(:input) { 'input' }

    let :submit do
      post :explanation, params: { preview_input: input }
    end

    context 'when the current user is staff' do
      before do
        when_current_user_is :staff
      end

      it 'passes preview input parameter through as an instance variable' do
        submit
        expect(assigns[:preview_input]).to eq(input)
      end
    end
  end
end
