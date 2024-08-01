import { resetMarker, panTo, placeMarker, inputLatLng, inputPrefRegionPlaceId, inputRegion } from "./map_common.js"

let map;
let infoWindow;
let geocoder;
let marker;
let hasMarker = false;

const searchLocationBtn = document.getElementById('search-location-btn')
const locationButton = document.getElementById("current_location");

function initNewPostMap() {

  function succeedGetCurrentPosition(position) {
    const pos = new google.maps.LatLng(
      position.coords.latitude,
      position.coords.longitude
    );
    // 現在地を地図の中心に移動
    window.map = new google.maps.Map(document.getElementById("map"), {
      center:  {lat: pos.lat(), lng: pos.lng()},  // 現在地
      zoom: 15,
    });
    
    // 現在地の経度と緯度を入力
    inputLatLng(pos);
    inputPrefRegionPlaceId(pos, geocoder);
    
    window.map.addListener("click", (e) => {
      if (hasMarker === true) {
        resetMarker();
      }
      panTo(e.latLng);
      marker = placeMarker(e.latLng);
      hasMarker = true;
      inputLatLng(e.latLng);
      inputPrefRegionPlaceId(e.latLng, geocoder);
      // マーカーのドロップ（ドラッグ終了）時のイベント
      google.maps.event.addListener( window.marker, 'dragend', e => {
        // イベントの引数eの、プロパティ.latLngが緯度経度
        inputLatLng(e.latLng)
        inputPrefRegionPlaceId(e.latLng, geocoder);
      });
    });
  };
  function failGetCurrentPosition() {
    // 現在位置を取得できない場合は東京駅を指定
    const pos = new google.maps.LatLng(
      35.6803997,
      139.7690174
    );
    window.map = new google.maps.Map(document.getElementById("map"), {
      center:  {lat: pos.lat(), lng: pos.lng()},
      zoom: 15,
    });
    // 現在地の経度と緯度を入力
    inputLatLng(pos);
    inputPrefRegionPlaceId(pos, geocoder);
    
    window.map.addListener("click", (e) => {
      if (hasMarker === true) {
        resetMarker();
      }
      panTo(e.latLng);
      placeMarker(e.latLng);
      hasMarker = true;
      inputLatLng(e.latLng);
      inputPrefRegionPlaceId(e.latLng, geocoder);
      // マーカーのドロップ（ドラッグ終了）時のイベント
      google.maps.event.addListener( window.marker, 'dragend', e => {
        // イベントの引数eの、プロパティ.latLngが緯度経度
        inputLatLng(e.latLng);
        inputPrefRegionPlaceId(e.latLng, geocoder);
      });
    });
  }

  geocoder = new google.maps.Geocoder()
  navigator.geolocation.getCurrentPosition(succeedGetCurrentPosition, failGetCurrentPosition);
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
        window.map.setCenter(pos);

        // 現在地の経度と緯度を入力
        inputLatLng(pos);
        inputPrefRegionPlaceId(pos, geocoder);
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

window.onload = function() {
  inputRegion();
  // 現在地ボタンのイベント設定
  locationButton.addEventListener("click", moveCurrentLocation);
  // 検索ボタンのイベント設定
  searchLocationBtn.addEventListener("click", () => {
    const inputAddress = document.getElementById('placeSearch').value;
    geocoder.geocode( { 'address': inputAddress}, function(results, status) {
      if (status == 'OK') {
        // マーカーが複数できないようにする
        if (hasMarker === true){
          window.marker.setMap(null);
        }
        //新しくマーカーを作成する
        window.map.setCenter(results[0].geometry.location);
        placeMarker(results[0].geometry.location)
        hasMarker = true;

        //検索した時に緯度経度を入力する
        inputLatLng(results[0].geometry.location);
        inputPrefRegionPlaceId(results[0].geometry.location, geocoder)
      } else {
        alert('該当する結果がありませんでした：' + status);
      }
    });
  });
}
window.initMap = initNewPostMap;
