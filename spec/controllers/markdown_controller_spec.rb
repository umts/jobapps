# frozen_string_literal: true

describe MarkdownController do
  context 'POST' do
    before do
      @input = 'input'
    end

    let :submit do
      post :explanation, params: { preview_input: @input }
    end

    context 'staff' do
      before do
        when_current_user_is :staff
      end

      it 'passes preview input parameter through as an instance variable' do
        submit
        expect(assigns[:preview_input]).to eql @input
      end
    end
  end
end
