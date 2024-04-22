import { selectRegion } from "./map_common.js"

let map; 
let infoWindow;
let marker;
let geocoder;
let aft;
let searchLocationBtn = document.getElementById('search-location-btn')
const locationButton = document.getElementById("current_location");

function initEditPostMap() { 
  // 現在地への移動
  
  // データベースから取得した位置情報をLatLngコンストラクタでインスタンス化
  let latLng = new google.maps.LatLng(
    parseFloat(document.getElementById('post_latitude').value), 
    parseFloat(document.getElementById('post_longitude').value)
  )

  // 現在地ボタン
  locationButton.addEventListener("click", moveCurrentLocation);

  geocoder = new google.maps.Geocoder();

  map = new google.maps.Map(document.getElementById("map"), {
    center:  {lat: latLng.lat(), lng: latLng.lng()},  // 登録されている地点
    zoom: 15,
  });

  placeMarkerAndPanTo(latLng, map);
  
  map.addListener("click", (e) => {
    placeMarkerAndPanTo(e.latLng, map);
  });
}

function moveCurrentLocation() {
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(
      (position) => {
        const pos = new google.maps.LatLng(
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
  //新しくマーカーを作成する
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
    geocoder.geocode( { 'address': inputAddress }, function(results, status) {
      if (status == 'OK') {
        // マーカーが複数できないようにする
        if (aft === true){
          marker.setMap(null);
        }
        //新しくマーカーを作成する
        map.setCenter(results[0].geometry.location);
        placeMarker(results[0].geometry.location, map)

        //二度目以降か判断
        aft = true
  
        //検索した時に緯度経度を入力する
        inputLatLng(results[0].geometry.location);
  
        // マーカーのドロップ（ドラッグ終了）時のイベント
        google.maps.event.addListener( marker, 'dragend', e => {
          // イベントの引数evの、プロパティ.latLngが緯度経度
          inputLatLng(e.latLng)
        });
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

function inputRegion() {
  const prefSelectBox = document.getElementById('post_prefecture');
  prefSelectBox.addEventListener("change", () => {
    let pref = prefSelectBox.value;
    document.getElementById('post_region').value = selectRegion(pref);
  })
}

window.initMap = initEditPostMap;
window.onload = function() {
  searchAddress();
  inputRegion();
}