FactoryBot.define do
  factory :first_post, class: Post do
    title { "凍結注意" }
    region { 0 }
    prefecture { 0 }
    description { "路面が凍結しているのでスリップに注意してください。札幌以北は全面凍結してそうです。" }
    genre { 2 }
    place_id { "X4CV+Q3H 幌加内町、北海道" }
  end
  factory :second_post, class: Post do
    title { "駅前駐車場" }
    region { 4 }
    description { "駅前にバイク専用駐輪場があります。大型バイクでも停められます！" }
    genre { 1 }
    place_id { "PP3M+CC4 浜松市、静岡県" }
  end
  factory :third_post, class: Post do
    title { "工事中。片側1車線で交互に通行しています。" }
    region { 5 }
    description { "先日の土砂崩れの影響で工事しています。路面に砂利も乗っているので気をつけてください。" }
    genre { 4 }
    place_id { "382W+5JR 丹波篠山市、兵庫県" }
  end
end
