// マーカーの設置
export function resetMarker() {
  window.marker.setMap(null);
}

export function panTo(latLng) {
  window.map.panTo(latLng);
}

export function placeMarker(latLng) {
  window.marker = new google.maps.Marker({
    map: window.map,
    position: latLng,
    draggable: true	// ドラッグ可能にする
  });
}

// 取得した位置情報を入力
export function inputLatLng(latLng) {
  document.getElementById('post_latitude').value = latLng.lat();
  document.getElementById('post_longitude').value = latLng.lng();
}

export function inputPrefRegionPlaceId(latLng, gCoder){ 
  gCoder.geocode({location: latLng}, (results) => {
    let arryLength = results[0].address_components.length;
    let pref = results[0].address_components[arryLength-3].short_name.replace('県', '').replace('府', '').replace('東京都', '東京');
    let region = selectRegion(pref)
    document.getElementById('post_prefecture').value = pref
    document.getElementById('post_region').value = region;
    document.getElementById('post_place').value = results[0].place_id;
  })
}

export function inputRegion() {
  const prefSelectBox = document.getElementById('post_prefecture');
  prefSelectBox.addEventListener("change", () => {
    let pref = prefSelectBox.value;
    document.getElementById('post_region').value = selectRegion(pref);
  })
}

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