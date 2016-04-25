FactoryGirl.define do
  factory :application_template do
    position
    active true
  end

  trait :with_questions do
    after :create do |instance|
      create :question, application_template: instance
    end
  end
end
