let map; 
let infoWindow;
let marker;
let geocoder;
let aft;
const searchLocationBtn = document.getElementById('search-location-btn')
const locationButton = document.getElementById("current_location");

function initNewPostMap() {
  function succeedGetCurrentPosition(position) {
    const pos = new google.maps.LatLng(
      position.coords.latitude,
      position.coords.longitude
    );
    // 現在地を地図の中心に移動
    map = new google.maps.Map(document.getElementById("map"), {
      center:  {lat: pos.lat(), lng: pos.lng()},  // 現在地
      zoom: 15,
    });
    // 現在地の経度と緯度を入力
    inputLatLng(pos);
    
    map.addListener("click", (e) => {
      placeMarkerAndPanTo(e.latLng, map);
    });
  };
  function failGetCurrentPosition() {
    // 現在位置を取得できない場合は東京駅を指定
    const pos = new google.maps.LatLng(
      35.6803997,
      139.7690174
    );
    map = new google.maps.Map(document.getElementById("map"), {
      center:  {lat: pos.lat(), lng: pos.lng()},
      zoom: 15,
    });
    // 現在地の経度と緯度を入力
    inputLatLng(pos);
    
    map.addListener("click", (e) => {
      placeMarkerAndPanTo(e.latLng, map);
    });
  }
  
  // 現在地ボタンのイベント設定
  locationButton.addEventListener("click", moveCurrentLocation)
  
  navigator.geolocation.getCurrentPosition(succeedGetCurrentPosition, failGetCurrentPosition);
  geocoder = new google.maps.Geocoder()
}

// 現在地への移動
function moveCurrentLocation() {
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(
      (position) => {
        const pos = new google.maps.LatLng (
          position.coords.latitude,
          position.coords.longitude
        );

        // 現在地を地図の中心に移動
        map.setCenter(pos);

        // 現在地の経度と緯度を入力
        inputLatLng(pos);
      },
      () => {
        handleLocationError(true, infoWindow, map.getCenter());
      }
    );
  } else {
    // Browser doesn't support Geolocation
    handleLocationError(false, infoWindow, map.getCenter());
  }
};

// 現在地取得時にエラーが発生した場合の処理
function handleLocationError(browserHasGeolocation, infoWindow, pos) {
  infoWindow.setPosition(pos);
  infoWindow.setContent(
    browserHasGeolocation
      ? "Error: The Geolocation service failed."
      : "Error: Your browser doesn't support geolocation."
  );
  infoWindow.open(map);
}

// マーカーの設置
function placeMarkerAndPanTo(latLng, map) {
  map.panTo(latLng);
  if (aft == true){
    marker.setMap(null);
  }
  placeMarker(latLng, map);

  //検索した時に緯度経度を入力する
  inputLatLng(latLng);
}

function placeMarker(latLng, map) {
  marker = new google.maps.Marker({
    map: map,
    position: latLng,
    draggable: true	// ドラッグ可能にする
  });

  //二度目以降か判断
  aft = true

  // マーカーのドロップ（ドラッグ終了）時のイベント
  google.maps.event.addListener( marker, 'dragend', e => {
    // イベントの引数evの、プロパティ.latLngが緯度経度
    inputLatLng(e.latLng)
  });
}

// 検索後のマップ作成
function searchAddress(){
  searchLocationBtn.addEventListener("click", () => {
    let inputAddress = document.getElementById('placeSearch').value;
    geocoder.geocode( { 'address': inputAddress}, function(results, status) {
      if (status == 'OK') {
        // マーカーが複数できないようにする
        if (aft === true){
          marker.setMap(null);
        }
        //新しくマーカーを作成する
        map.setCenter(results[0].geometry.location);
        placeMarker(results[0].geometry.location, map)

        //検索した時に緯度経度を入力する
        inputLatLng(results[0].geometry.location);
      } else {
        alert('該当する結果がありませんでした：' + status);
      }
    });
  })
}
// 取得した位置情報を入力
function inputLatLng(latLng) {
  document.getElementById('post_latitude').value = latLng.lat();
  document.getElementById('post_longitude').value = latLng.lng();
  geocoder.geocode({location: latLng}, (results) => {
    let arryLength = results[0].address_components.length;
    let pref = results[0].address_components[arryLength-3].short_name.replace('県', '').replace('府', '').replace('東京都', '東京');
    let region = selectRegion(pref)
    document.getElementById('post_prefecture').value = pref
    document.getElementById('post_region').value = region;
    document.getElementById('post_place').value = results[0].place_id;
  })
}

function selectRegion(pref) {
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
function inputRegion() {
  const prefSelectBox = document.getElementById('post_prefecture');
  prefSelectBox.addEventListener("change", () => {
    let pref = prefSelectBox.value;
    document.getElementById('post_region').value = selectRegion(pref);
  })
}



window.initMap = initNewPostMap;
window.onload = function() {
  searchAddress();
  inputRegion();
}
