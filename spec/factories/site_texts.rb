FactoryGirl.define do
  factory :site_text do
    sequence(:name) { |n| "Name #{n}" }
    text 'text'
  end
end
