<script setup>
import { onMounted, ref } from 'vue'
import { loadGoogleMaps, googleMapsApiKey } from '../utils/googleMaps'
import { useMetaStore } from '../stores/meta'

const props = defineProps({
  initialLatitude: { type: Number, default: null },
  initialLongitude: { type: Number, default: null },
  // 新規投稿では地図の初期位置（現在地）もフォームへ反映する（旧 map_new_post.js の挙動）
  emitInitialLocation: { type: Boolean, default: false }
})
const emit = defineEmits(['location-selected'])

const meta = useMetaStore()
const mapElement = ref(null)
const searchWord = ref('')
const mapAvailable = ref(!!googleMapsApiKey)

let google = null
let map = null
let marker = null
let geocoder = null

const TOKYO_STATION = { lat: 35.6803997, lng: 139.7690174 }

onMounted(async () => {
  await meta.ensureLoaded()
  google = await loadGoogleMaps()
  if (!google) return // API キー未設定 → 地図なしで動作を続ける

  geocoder = new google.maps.Geocoder()

  if (props.initialLatitude != null && props.initialLongitude != null) {
    // 編集時: 登録済みの地点を表示
    initMap({ lat: props.initialLatitude, lng: props.initialLongitude }, { withMarker: true, emitLocation: false })
  } else {
    // 新規投稿時: 現在地（取得できない場合は東京駅）を表示
    navigator.geolocation.getCurrentPosition(
      (position) => initMap(
        { lat: position.coords.latitude, lng: position.coords.longitude },
        { withMarker: false, emitLocation: props.emitInitialLocation }
      ),
      () => initMap(TOKYO_STATION, { withMarker: false, emitLocation: props.emitInitialLocation })
    )
  }
})

function initMap(center, { withMarker, emitLocation }) {
  map = new google.maps.Map(mapElement.value, { center, zoom: 15 })
  const latLng = new google.maps.LatLng(center.lat, center.lng)
  if (withMarker) placeMarker(latLng)
  if (emitLocation) resolveAndEmit(latLng)
  map.addListener('click', (event) => {
    selectLocation(event.latLng)
  })
}

function placeMarker(latLng) {
  if (marker) marker.setMap(null)
  marker = new google.maps.Marker({ map, position: latLng, draggable: true })
  // マーカーのドロップ（ドラッグ終了）時にも位置情報を更新する
  marker.addListener('dragend', (event) => {
    selectLocation(event.latLng, { pan: false })
  })
}

function selectLocation(latLng, { pan = true } = {}) {
  if (pan) map.panTo(latLng)
  placeMarker(latLng)
  resolveAndEmit(latLng)
}

// 逆ジオコーディングで都道府県・地域・place_id を取得してフォームへ反映する
function resolveAndEmit(latLng) {
  geocoder.geocode({ location: latLng }, (results, status) => {
    if (status !== 'OK' || !results?.length) {
      emit('location-selected', {
        latitude: latLng.lat(),
        longitude: latLng.lng(),
        place: '',
        prefecture: '',
        region: ''
      })
      return
    }
    const components = results[0].address_components
    const rawName = components[components.length - 3]?.short_name || ''
    const prefecture = rawName.replace('県', '').replace('府', '').replace('東京都', '東京')
    const known = meta.prefectureToRegion[prefecture] != null
    emit('location-selected', {
      latitude: latLng.lat(),
      longitude: latLng.lng(),
      place: results[0].place_id,
      prefecture: known ? prefecture : '',
      region: known ? meta.prefectureToRegion[prefecture] : ''
    })
  })
}

// 現在地への移動
function moveToCurrentLocation() {
  if (!navigator.geolocation || !map) return
  navigator.geolocation.getCurrentPosition((position) => {
    const latLng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
    map.setCenter(latLng)
    resolveAndEmit(latLng)
  })
}

// キーワードから場所を検索
function searchLocation() {
  if (!geocoder || !searchWord.value) return
  geocoder.geocode({ address: searchWord.value }, (results, status) => {
    if (status === 'OK' && results?.length) {
      const location = results[0].geometry.location
      map.setCenter(location)
      placeMarker(location)
      resolveAndEmit(location)
    } else {
      window.alert('該当する結果がありませんでした：' + status)
    }
  })
}
</script>

<template>
  <div class="mb-3">
    <div class="mb-1">
      <i class="bi bi-pin-map"></i>地図にピンをさしてください
    </div>
    <template v-if="mapAvailable">
      <div class="input-group mb-2">
        <button type="button" id="current_location" class="btn btn-outline-secondary" @click="moveToCurrentLocation">現在地</button>
        <div class="form-floating">
          <input
            id="placeSearch"
            v-model="searchWord"
            class="form-control"
            type="text"
            placeholder="場所を検索"
            @keydown.enter.prevent="searchLocation"
          />
          <label for="placeSearch">場所を検索</label>
        </div>
        <button type="button" id="search-location-btn" class="btn btn-outline-secondary" @click="searchLocation">検索</button>
      </div>
      <div id="map" ref="mapElement" class="mb-3"></div>
    </template>
    <div v-else class="alert alert-info">
      Google Maps API キー（VITE_GOOGLE_MAPS_API_KEY）が設定されていないため地図を表示できません。
      位置情報を設定できないため、投稿の作成には API キーの設定が必要です。
    </div>
  </div>
</template>
