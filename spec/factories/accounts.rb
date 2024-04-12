FactoryBot.define do
  factory :first_account, class: Account do
    name { "taro" }
    email { "taro@sample.com" }
    nickname { "taro" }
    region { 0 }
    self_introduction { "はじめまして、太郎です。バイク歴10年です。" }
    password { "password" }
    admin { true }

    trait :with_posts do
      after(:create) do |user|
        user.posts.create!(FactoryBot.build(:first_post).attributes)
        user.posts.create!(FactoryBot.build(:second_post).attributes)
      end
    end
  end

  factory :second_account, class: Account do
    name { "hanako" }
    email { "hanako@sample.com" }
    nickname { "hanako" }
    region { 5 }
    self_introduction { "花子です。バイク歴1年です。" }
    password { "password" }
    admin { false }

    trait :with_posts do
      after(:create) do |user|
        user.posts.create!(FactoryBot.build(:third_post).attributes)
      end
    end
  end
end
