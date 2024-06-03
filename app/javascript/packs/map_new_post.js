import { resetMarkerAndPanTo, placeMarker, searchAddress, inputLatLng, inputRegion } from "./map_common.js"

let map;
let infoWindow;
let geocoder;
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
    inputLatLng(pos, geocoder);
    
    window.map.addListener("click", (e) => {
      resetMarkerAndPanTo(e.latLng, hasMarker);
      hasMarker = true;
      placeMarker(e.latLng);
      inputLatLng(e.latLng, geocoder);
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
    inputLatLng(pos, geocoder);
    
    window.map.addListener("click", (e) => {
      resetMarkerAndPanTo(e.latLng, hasMarker);
      placeMarker(e.latLng);
      hasMarker = true;
      inputLatLng(e.latLng, geocoder);
    });
  }
  
  geocoder = new google.maps.Geocoder()
  navigator.geolocation.getCurrentPosition(succeedGetCurrentPosition, failGetCurrentPosition);
  // 現在地ボタンのイベント設定
  locationButton.addEventListener("click", moveCurrentLocation)
  searchAddress(searchLocationBtn, geocoder);
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
        inputLatLng(pos, geocoder);
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
}
window.initMap = initNewPostMap;
