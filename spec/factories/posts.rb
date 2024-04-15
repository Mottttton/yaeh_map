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
    genre { 2 }
    place { "GhIJq63YX3aGQUARuTHipxbrYEA" }
    latitude { 35.0504875 }
    longitude { 135.3465156 }
    created_at { '2024-04-03 09:00:00' }
    updated_at { '2024-04-03 09:00:00' }
  end
  factory :fourth_post, class: Post do
    title { "メタセコイヤ並木" }
    region { 5 }
    description { "有名なメタセコイヤ並木です" }
    genre { 0 }
    place { "GhIJcfjuoCO9QUARaVDZVS0BYUA" }
    latitude { 35.4776498}
    longitude { 136.0367841 }
    created_at { '2024-04-03 09:00:00' }
    updated_at { '2024-04-03 09:00:00' }
  end
  factory :hokkaido_post, class: Post do
    title { "検索テスト1" }
    region { 0 }
    prefecture { 0 }
    description { "札幌" }
    genre { 0 }
    place { "ChIJ__-__p4pC18RTkvY6Fq6L6c" }
    latitude { 43.0643091 }
    longitude { 141.3468324 }
  end
  factory :aomori_post, class: Post do
    title { "検索テスト2" }
    region { 1 }
    prefecture { 1 }
    description { "青森" }
    genre { 1 }
    place { "ChIJAQDw-hyfm18RmXOxaYgVNKI" }
    latitude { 40.824209 }
    longitude { 140.7401206 }
  end
  factory :iwate_post, class: Post do
    title { "検索テスト3" }
    region { 1 }
    prefecture { 2 }
    description { "盛岡" }
    genre { 2 }
    place { "ChIJr5x67SR2hV8RwKlFAGsdoIA" }
    latitude { 39.7034692 }
    longitude { 141.1525894 }
  end
  factory :miyagi_post, class: Post do
    title { "検索テスト4" }
    region { 1 }
    prefecture { 3 }
    description { "仙台" }
    genre { 0 }
    place { "ChIJm6c6LCkoil8R1B8Bn6EJ3jw" }
    latitude { 38.2686717 }
    longitude { 140.8721701 }
  end
  factory :akita_post, class: Post do
    title { "検索テスト5" }
    region { 1 }
    prefecture { 4 }
    description { "秋田" }
    genre { 1 }
    place { "ChIJPSgCrNzCj18RCq_niuukBj4" }
    latitude { 39.71859970000001 }
    longitude { 140.1023338 }
  end
  factory :yamagata_post, class: Post do
    title { "検索テスト6" }
    region { 1 }
    prefecture { 5 }
    description { "山形" }
    genre { 2 }
    place { "ChIJr7YcsvW1i18RvPCXXaoYZmQ" }
    latitude { 38.2404091 }
    longitude { 140.3635408 }
  end
  factory :fukushima_post, class: Post do
    title { "検索テスト7" }
    region { 1 }
    prefecture { 6 }
    description { "福島" }
    genre { 0 }
    place { "ChIJP1tXMjWEil8RzyLD6Vy3RQo" }
    latitude { 37.7500681 }
    longitude { 140.4682317 }
  end
  factory :ibaraki_post, class: Post do
    title { "検索テスト8" }
    region { 2 }
    prefecture { 7 }
    description { "水戸" }
    genre { 1 }
    place { "ChIJ8SJCfyAlImAR6c4_hYNb4gA" }
    latitude { 36.3415041 }
    longitude { 140.4467739 }
  end
  factory :tochigi_post, class: Post do
    title { "検索テスト9" }
    region { 2 }
    prefecture { 8 }
    description { "宇都宮" }
    genre { 2 }
    place { "ChIJN_f3ZbBnH2ARqCV6bYw_MSI" }
    latitude { 36.5657943 }
    longitude { 139.8836544 }
  end
  factory :gunma_post, class: Post do
    title { "検索テスト10" }
    region { 2 }
    prefecture { 9 }
    description { "前橋" }
    genre { 0 }
    place { "ChIJbRuMe6DzHmARN_0iXYgqCnU" }
    latitude { 36.390642 }
    longitude { 139.0603145 }
  end
  factory :saitama_post, class: Post do
    title { "検索テスト11" }
    region { 2 }
    prefecture { 10 }
    description { "さいたま" }
    genre { 1 }
    place { "GhIJegygKYX_QUARErwhjUpuYUA" }
    latitude { 35.9962513 }
    longitude { 139.4466005 }
  end
  factory :chiba_post, class: Post do
    title { "検索テスト12" }
    region { 2 }
    prefecture { 11 }
    description { "千葉" }
    genre { 2 }
    place { "ChIJwbCJpDWbImAR60kqKLy6kAc" }
    latitude { 35.6050793 }
    longitude { 140.123328 }
  end
  factory :tokyo_post, class: Post do
    title { "検索テスト13" }
    region { 2 }
    prefecture { 12 }
    description { "新宿" }
    genre { 0 }
    place { "ChIJoTcat9SMGGAR6GGG8zdcZvE" }
    latitude { 35.6894807 }
    longitude { 139.6916863 }
  end
  factory :kanagawa_post, class: Post do
    title { "検索テスト14" }
    region { 2 }
    prefecture { 13 }
    description { "横浜" }
    genre { 1 }
    place { "ChIJ__8_V_BcGGARhyixr1QCYTk" }
    latitude { 35.4436739 }
    longitude { 139.6379639 }
  end
  factory :niigata_post, class: Post do
    title { "検索テスト15" }
    region { 3 }
    prefecture { 14 }
    description { "新潟" }
    genre { 2 }
    place { "ChIJo-TYeUvI9F8RpHp_98Y_n2Q" }
    latitude { 37.9024974 }
    longitude { 139.0232065 }
  end
  factory :toyama_post, class: Post do
    title { "検索テスト16" }
    region { 3 }
    prefecture { 15 }
    description { "富山" }
    genre { 0 }
    place { "ChIJFbau5IWQ918REU_4tHkjKQY" }
    latitude { 36.6955173 }
    longitude { 137.2112614 }
  end
  factory :ishikawa_post, class: Post do
    title { "検索テスト17" }
    region { 3 }
    prefecture { 16 }
    description { "金沢" }
    genre { 1 }
    place { "ChIJ7fRyA8jM-V8RNuY11cu1Jlo" }
    latitude { 36.5946708 }
    longitude { 136.6256627 }
  end
  factory :fukui_post, class: Post do
    title { "検索テスト18" }
    region { 3 }
    prefecture { 17 }
    description { "福井" }
    genre { 2 }
    place { "ChIJiSL7BPK--F8RH-tjj5_3nfs" }
    latitude { 36.0650939 }
    longitude { 136.2217502 }
  end
  factory :yamanashi_post, class: Post do
    title { "検索テスト19" }
    region { 4 }
    prefecture { 18 }
    description { "甲府" }
    genre { 0 }
    place { "ChIJM7ZICJlgGWARhtEgldwiRjc" }
    latitude { 35.664149 }
    longitude { 138.5684605 }
  end
  factory :nagano_post, class: Post do
    title { "検索テスト20" }
    region { 4 }
    prefecture { 19 }
    description { "長野" }
    genre { 1 }
    place { "ChIJSclb3eeGHWARfNrfLzFQzmI" }
    latitude { 36.65128199999999 }
    longitude { 138.180972 }
  end
  factory :gifu_post, class: Post do
    title { "検索テスト21" }
    region { 4 }
    prefecture { 20 }
    description { "岐阜" }
    genre { 2 }
    place { "ChIJ6QU96O6uA2ARKKdrUfKYLr0" }
    latitude { 35.391028 }
    longitude { 136.7234769 }
  end
  factory :shizuoka_post, class: Post do
    title { "検索テスト22" }
    region { 4 }
    prefecture { 21 }
    description { "静岡" }
    genre { 0 }
    place { "ChIJXW7_lh5KGmAR3315WNIcwEc" }
    latitude { 34.9768466 }
    longitude { 138.3829675 }
  end
  factory :aichi_post, class: Post do
    title { "検索テスト23" }
    region { 4 }
    prefecture { 22 }
    description { "名古屋" }
    genre { 1 }
    place { "ChIJyUhsNixxA2ARfLPi3nbC3wU" }
    latitude { 35.1802953 }
    longitude { 136.9067123 }
  end
  factory :mie_post, class: Post do
    title { "検索テスト24" }
    region { 5 }
    prefecture { 23 }
    description { "津" }
    genre { 2 }
    place { "ChIJSVXVkJsNBGARxyJ7I9DzUAY" }
    latitude { 34.7302573 }
    longitude { 136.5086816 }
  end
  factory :shiga_post, class: Post do
    title { "検索テスト25" }
    region { 5 }
    prefecture { 24 }
    description { "大津" }
    genre { 0 }
    place { "ChIJ4VZtdPcMAWARgoHz9T5pz_c" }
    latitude { 35.0044608 }
    longitude { 135.8685341 }
  end
  factory :kyoto_post, class: Post do
    title { "検索テスト26" }
    region { 5 }
    prefecture { 25 }
    description { "京都" }
    genre { 1 }
    place { "ChIJVcs9oHkIAWARqwE_VO4ljBA" }
    latitude { 35.0209325 }
    longitude { 135.7553164 }
  end
  factory :osaka_post, class: Post do
    title { "検索テスト27" }
    region { 5 }
    prefecture { 26 }
    description { "大阪" }
    genre { 2 }
    place { "ChIJA5rWky7nAGARqnbMxKSbyL4" }
    latitude { 34.6863114 }
    longitude { 135.5197095 }
  end
  factory :hyogo_post, class: Post do
    title { "検索テスト28" }
    region { 5 }
    prefecture { 27 }
    description { "神戸" }
    genre { 0 }
    place { "ChIJ7wcSXRyPAGARMPB9CXs5ZwM" }
    latitude { 34.690972 }
    longitude { 135.1833177 }
  end
  factory :nara_post, class: Post do
    title { "検索テスト29" }
    region { 5 }
    prefecture { 28 }
    description { "なら" }
    genre { 1 }
    place { "ChIJZSCq4YU5AWARKZrbXtzC47w" }
    latitude { 34.6853113 }
    longitude { 135.8329083 }
  end
  factory :wakayama_post, class: Post do
    title { "検索テスト30" }
    region { 5 }
    prefecture { 29 }
    description { "和歌山" }
    genre { 2 }
    place { "ChIJ0QKEZL-yAGAR9x6tb1BQvzQ" }
    latitude { 34.22603 }
    longitude { 135.167467 }
  end
  factory :tottori_post, class: Post do
    title { "検索テスト31" }
    region { 6 }
    prefecture { 30 }
    description { "鳥取" }
    genre { 0 }
    place { "ChIJa7qkF5CPVTURn6Wo3OMu5jE" }
    latitude { 35.5039956 }
    longitude { 134.2379897 }
  end
  factory :shimane_post, class: Post do
    title { "検索テスト32" }
    region { 6 }
    prefecture { 31 }
    description { "松江" }
    genre { 1 }
    place { "ChIJWR6RGgUFVzURsvPtxs1NYB0" }
    latitude { 35.4725753 }
    longitude { 133.0507377 }
  end
  factory :okayama_post, class: Post do
    title { "検索テスト33" }
    region { 6 }
    prefecture { 32 }
    description { "岡山" }
    genre { 2 }
    place { "ChIJOzyIlzUGVDURzS7OmUjoSz4" }
    latitude { 34.6615589 }
    longitude { 133.9345568 }
  end
  factory :hiroshima_post, class: Post do
    title { "検索テスト34" }
    region { 6 }
    prefecture { 33 }
    description { "広島" }
    genre { 0 }
    place { "ChIJW3W3BQmiWjUR31xlA1MvTBs" }
    latitude { 34.3965631 }
    longitude { 132.4596281 }
  end
  factory :yamaguchi_post, class: Post do
    title { "検索テスト35" }
    region { 6 }
    prefecture { 34 }
    description { "山口" }
    genre { 1 }
    place { "ChIJ_SlLpQiXRDURWbowaIi521A" }
    latitude { 34.1858925 }
    longitude { 131.4707249 }
  end
  factory :tokushima_post, class: Post do
    title { "検索テスト36" }
    region { 7 }
    prefecture { 35 }
    description { "徳島" }
    genre { 2 }
    place { "ChIJ__ZeKV1tUzURTT3_BHEhwwQ" }
    latitude { 34.065814 }
    longitude { 134.5592503 }
  end
  factory :kagawa_post, class: Post do
    title { "検索テスト37" }
    region { 7 }
    prefecture { 36 }
    description { "高松" }
    genre { 0 }
    place { "ChIJ93v6K5TrUzURFm8UqRbF71A" }
    latitude { 34.3401166 }
    longitude { 134.0433119 }
  end
  factory :ehime_post, class: Post do
    title { "検索テスト38" }
    region { 7 }
    prefecture { 37 }
    description { "松山" }
    genre { 1 }
    place { "ChIJM4K90JLlTzUR--uRU2TXSEw" }
    latitude { 33.8416797 }
    longitude { 132.7656776 }
  end
  factory :kochi_post, class: Post do
    title { "検索テスト39" }
    region { 7 }
    prefecture { 38 }
    description { "高知" }
    genre { 2 }
    place { "ChIJFQWBuCQZTjURayPvL8HzsqE" }
    latitude { 33.5595505 }
    longitude { 133.5311409 }
  end
  factory :fukuoka_post, class: Post do
    title { "検索テスト40" }
    region { 8 }
    prefecture { 39 }
    description { "福岡" }
    genre { 0 }
    place { "ChIJv4xc_tiRQTUR67mqyP-9tgo" }
    latitude { 33.6063137 }
    longitude { 130.4180291 }
  end
  factory :saga_post, class: Post do
    title { "検索テスト41" }
    region { 8 }
    prefecture { 40 }
    description { "佐賀" }
    genre { 1 }
    place { "ChIJwV9N3HrKQTURzofflS6dlAA" }
    latitude { 33.2494385 }
    longitude { 130.2988042 }
  end
  factory :nagasaki_post, class: Post do
    title { "検索テスト42" }
    region { 8 }
    prefecture { 41 }
    description { "長崎" }
    genre { 2 }
    place { "ChIJC4IxfD1TFTURFXiMxLkbVjM" }
    latitude { 32.7503362 }
    longitude { 129.8679084 }
  end
  factory :kumamoto_post, class: Post do
    title { "検索テスト43" }
    region { 8 }
    prefecture { 42 }
    description { "熊本" }
    genre { 0 }
    place { "ChIJo70u_v_vQDURkIwo_w3lJA0" }
    latitude { 32.8594427 }
    longitude { 130.7969149 }
  end
  factory :oita_post, class: Post do
    title { "検索テスト44" }
    region { 8 }
    prefecture { 43 }
    description { "大分" }
    genre { 1 }
    place { "ChIJxx9syXCfRjUREPEcq6CnVRo" }
    latitude { 33.2381996 }
    longitude { 131.6126744 }
  end
  factory :miyazaki_post, class: Post do
    title { "検索テスト45" }
    region { 8 }
    prefecture { 44 }
    description { "宮崎" }
    genre { 2 }
    place { "ChIJGe54f2y3ODUR3MI_ri3EdIU" }
    latitude { 31.9109084 }
    longitude { 131.4238976 }
  end
  factory :kagoshima_post, class: Post do
    title { "検索テスト46" }
    region { 8 }
    prefecture { 45 }
    description { "鹿児島" }
    genre { 0 }
    place { "ChIJ-ed-GNJgPjURsVAjHTh4zKI" }
    latitude { 31.5601825 }
    longitude { 130.5579681 }
  end
  factory :okinawa_post, class: Post do
    title { "検索テスト47" }
    region { 9 }
    prefecture { 46 }
    description { "那覇" }
    genre { 1 }
    place { "ChIJ0Zg7HZ5p5TQRXe29N0sxzDk" }
    latitude { 26.2123793 }
    longitude { 127.6806877 }
  end

end
