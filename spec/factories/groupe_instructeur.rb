FactoryBot.define do
  sequence(:groupe_label) { |n| "label_#{n}" }

  factory :groupe_instructeur do
    label { generate(:groupe_label) }
    association :procedure

    trait :default do
      label { GroupeInstructeur::DEFAUT_LABEL }
    end

    trait :with_bulk_message do
      bulk_messages { [association(:bulk_message, strategy: :build)] }
    end
  end
end
