# frozen_string_literal: true

require 'rails_helper'

class DummyController < ApplicationController
  include ConfigurableMessages
end

describe DummyController do
  context 'valid calls' do
    describe 'show_message' do
      let(:call) { subject.show_message :cool_message, default: "I'm cool" }
      before :each do
        expect_any_instance_of(ApplicationConfiguration)
          .to receive(:configured_value)
          .with(%i[messages cool_message], default: "I'm cool")
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
      subject.send(
        :check_message_default, :user_create, default: 'not the actual default'
      )
    end
    it 'raises an error with invalid parameters' do
      expect { call }.to raise_error(ArgumentError)
    end
  end
end
