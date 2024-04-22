export function selectRegion(pref) {
  let region
  switch (pref) {
    case '北海道':
      region = '北海道'
      break;
    case '青森':
      region = '東北'
      break;
    case '岩手':
      region = '東北'
      break;
    case '宮城':
      region = '東北'
      break;
    case '秋田':
      region = '東北'
      break;
    case '山形':
      region = '東北'
      break;
    case '福島':
      region = '東北'
      break;
    case '茨城':
      region = '関東'
      break;
    case '栃木':
      region = '関東'
      break;
    case '群馬':
      region = '関東'
      break;
    case '埼玉':
      region = '関東'
      break;
    case '千葉':
      region = '関東'
      break;
    case '東京':
      region = '関東'
      break;
    case '神奈川':
      region = '関東'
      break;
    case '新潟':
      region = '北陸'
      break;
    case '富山':
      region = '北陸'
      break;
    case '石川':
      region = '北陸'
      break;
    case '福井':
      region = '北陸'
      break;
    case '山梨':
      region = '東海'
      break;
    case '長野':
      region = '東海'
      break;
    case '岐阜':
      region = '東海'
      break;
    case '静岡':
      region = '東海'
      break;
    case '愛知':
      region = '東海'
      break;
    case '三重':
      region = '近畿'
      break;
    case '滋賀':
      region = '近畿'
      break;
    case '京都':
      region = '近畿'
      break;
    case '大阪':
      region = '近畿'
      break;
    case '兵庫':
      region = '近畿'
      break;
    case '奈良':
      region = '近畿'
      break;
    case '和歌山':
      region = '近畿'
      break;
    case '鳥取':
      region = '中国'
      break;
    case '島根':
      region = '中国'
      break;
    case '岡山':
      region = '中国'
      break;
    case '広島':
      region = '中国'
      break;
    case '山口':
      region = '中国'
      break;
    case '徳島':
      region = '四国'
      break;
    case '香川':
      region = '四国'
      break;
    case '愛媛':
      region = '四国'
      break;
    case '高知':
      region = '四国'
      break;
    case '福岡':
      region = '鹿児島'
      break;
    case '佐賀':
      region = '鹿児島'
      break;
    case '長崎':
      region = '鹿児島'
      break;
    case '熊本':
      region = '鹿児島'
      break;
    case '大分':
      region = '鹿児島'
      break;
    case '宮崎':
      region = '鹿児島'
      break;
    case '鹿児島':
      region = '鹿児島'
      break;
    case '沖縄':
      region = '沖縄'
      break;
    default:
      region = '';
  }
  return region;
}