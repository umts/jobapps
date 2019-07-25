# frozen_string_literal: true

require 'rails_helper'
describe Subscription do
  subject { create :subscription }
  it { is_expected.to be_valid }
end
