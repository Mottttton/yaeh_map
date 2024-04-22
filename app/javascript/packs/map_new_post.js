import { selectRegion } from "./map_common.js"

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
