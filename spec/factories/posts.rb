FactoryBot.define do
  factory :first_post, class: Post do
    title { "凍結注意" }
    region { 4 }
    prefecture { 0 }
    description { "路面が凍結しているのでスリップに注意してください。札幌以北は全面凍結してそうです。" }
    genre { 2 }
    place { "ChIJp1vPXf1fGWARLHcVVU3Nwyo" }
    latitude { 35.48254011970254 }
    longitude { 138.72773962840543 }
    created_at { '2024-04-01 09:00:00' }
    updated_at { '2024-04-01 09:00:00' }
  end
  factory :second_post, class: Post do
    title { "駅前駐車場" }
    region { 4 }
    description { "駅前にバイク専用駐輪場があります。大型バイクでも停められます！" }
    genre { 1 }
    place { "ChIJyfAqfLbfGmARGQBSb0PIzxw" }
    latitude { 34.7035125 }
    longitude { 137.7335781 }
    created_at { '2024-04-05 09:00:00' }
    updated_at { '2024-04-05 09:00:00' }
  end
  factory :third_post, class: Post do
    title { "工事中。片側1車線で交互に通行しています。" }
    region { 5 }
    description { "先日の土砂崩れの影響で工事しています。路面に砂利も乗っているので気をつけてください。" }
    genre { 4 }
    place { "GhIJq63YX3aGQUARuTHipxbrYEA" }
    latitude { 35.0504875 }
    longitude { 135.3465156 }
    created_at { '2024-04-03 09:00:00' }
    updated_at { '2024-04-03 09:00:00' }
  end
end
