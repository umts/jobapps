require 'rails_helper'
include ConfigurableMessages

describe ConfigurableMessages do
  context 'valid calls' do
    describe 'show_message' do
      let(:call) { show_message :cool_message, default: "I'm cool" }
      before :each do
        expect_any_instance_of(ApplicationConfiguration)
          .to receive(:configured_value)
          .with([:messages, :cool_message], default: "I'm cool")
          .and_return 'a retrieved value'
      end
      it 'calls ApplicationConfiguration#configured_value as expected' do
        call
      end
      it 'stores the returned value in the flash' do
        call
        expect(flash[:message]).to eql 'a retrieved value'
      end
    end
  end
  context 'invalid calls' do
    let(:call) do
      check_message_default(:user_create, default: 'not the actual default')
    end
    it 'raises an error with invalid parameters' do
      expect { call }.to raise_error(ArgumentError)
    end
  end
end
