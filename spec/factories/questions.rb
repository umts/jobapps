# frozen_string_literal: true

FactoryBot.define do
  factory :question do
    data_type   'text'
    sequence    :number
    prompt      'Question prompt'
    required    true
  end
end
