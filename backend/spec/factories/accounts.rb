FactoryBot.define do
  factory :first_account, class: Account do
    name { "taro" }
    email { "taro@sample.com" }
    nickname { "taro" }
    region { 5 }
    self_introduction { "はじめまして、太郎です。バイク歴10年です。" }
    password { "password" }
    admin { true }

    trait :with_posts do
      after(:create) do |account|
        account.posts.create!(FactoryBot.build(:first_post).attributes)
        account.posts.create!(FactoryBot.build(:second_post).attributes)
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
      after(:create) do |account|
        account.posts.create!(FactoryBot.build(:third_post).attributes)
      end
    end
  end

  factory :posts_all_region_account, class: Account do
    name { "complete_japan" }
    email { "complete_japan@sample.com" }
    nickname { "complete_japan" }
    self_introduction { "検索機能のテストをします。" }
    password { "password" }
    admin { false }

    trait :with_posts do
      after(:create) do |account|
        account.posts.create!(FactoryBot.build(:hokkaido_post).attributes)
        account.posts.create!(FactoryBot.build(:aomori_post).attributes)
        account.posts.create!(FactoryBot.build(:iwate_post).attributes)
        account.posts.create!(FactoryBot.build(:miyagi_post).attributes)
        account.posts.create!(FactoryBot.build(:akita_post).attributes)
        account.posts.create!(FactoryBot.build(:yamagata_post).attributes)
        account.posts.create!(FactoryBot.build(:fukushima_post).attributes)
        account.posts.create!(FactoryBot.build(:ibaraki_post).attributes)
        account.posts.create!(FactoryBot.build(:tochigi_post).attributes)
        account.posts.create!(FactoryBot.build(:gunma_post).attributes)
        account.posts.create!(FactoryBot.build(:saitama_post).attributes)
        account.posts.create!(FactoryBot.build(:chiba_post).attributes)
        account.posts.create!(FactoryBot.build(:tokyo_post).attributes)
        account.posts.create!(FactoryBot.build(:kanagawa_post).attributes)
        account.posts.create!(FactoryBot.build(:niigata_post).attributes)
        account.posts.create!(FactoryBot.build(:toyama_post).attributes)
        account.posts.create!(FactoryBot.build(:ishikawa_post).attributes)
        account.posts.create!(FactoryBot.build(:fukui_post).attributes)
        account.posts.create!(FactoryBot.build(:yamanashi_post).attributes)
        account.posts.create!(FactoryBot.build(:nagano_post).attributes)
        account.posts.create!(FactoryBot.build(:gifu_post).attributes)
        account.posts.create!(FactoryBot.build(:shizuoka_post).attributes)
        account.posts.create!(FactoryBot.build(:aichi_post).attributes)
        account.posts.create!(FactoryBot.build(:mie_post).attributes)
        account.posts.create!(FactoryBot.build(:shiga_post).attributes)
        account.posts.create!(FactoryBot.build(:kyoto_post).attributes)
        account.posts.create!(FactoryBot.build(:osaka_post).attributes)
        account.posts.create!(FactoryBot.build(:hyogo_post).attributes)
        account.posts.create!(FactoryBot.build(:nara_post).attributes)
        account.posts.create!(FactoryBot.build(:wakayama_post).attributes)
        account.posts.create!(FactoryBot.build(:tottori_post).attributes)
        account.posts.create!(FactoryBot.build(:shimane_post).attributes)
        account.posts.create!(FactoryBot.build(:okayama_post).attributes)
        account.posts.create!(FactoryBot.build(:hiroshima_post).attributes)
        account.posts.create!(FactoryBot.build(:yamaguchi_post).attributes)
        account.posts.create!(FactoryBot.build(:tokushima_post).attributes)
        account.posts.create!(FactoryBot.build(:kagawa_post).attributes)
        account.posts.create!(FactoryBot.build(:ehime_post).attributes)
        account.posts.create!(FactoryBot.build(:kochi_post).attributes)
        account.posts.create!(FactoryBot.build(:fukuoka_post).attributes)
        account.posts.create!(FactoryBot.build(:saga_post).attributes)
        account.posts.create!(FactoryBot.build(:nagasaki_post).attributes)
        account.posts.create!(FactoryBot.build(:kumamoto_post).attributes)
        account.posts.create!(FactoryBot.build(:oita_post).attributes)
        account.posts.create!(FactoryBot.build(:miyazaki_post).attributes)
        account.posts.create!(FactoryBot.build(:kagoshima_post).attributes)
        account.posts.create!(FactoryBot.build(:okinawa_post).attributes)
      end
    end
  end

  factory :no_region_account, class: Account do
    name { "no_region" }
    email { "no_region@sample.com" }
    nickname { "no_region" }
    self_introduction { "テストアカウント。地域設定なし。" }
    password { "password" }
    admin { false }

    trait :with_posts do
      after(:create) do |account|
        account.posts.create!(FactoryBot.build(:third_post).attributes)
      end
    end
  end

  factory :set_region_account, class: Account do
    name { "set_region" }
    email { "set_region@sample.com" }
    nickname { "set_region" }
    region { 5 }
    self_introduction { "テストアカウント。地域設定なし。" }
    password { "password" }
    admin { false }

    trait :with_posts do
      after(:create) do |account|
        account.posts.create!(FactoryBot.build(:fourth_post).attributes)
      end
    end
  end
end
