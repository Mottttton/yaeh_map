<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { MapPinIcon } from '@lucide/vue'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { loadGoogleMaps, googleMapsApiKey } from '../utils/googleMaps'
import { useMetaStore } from '../stores/meta'
import type { MapLocation } from '../types'

const props = withDefaults(
  defineProps<{
    initialLatitude?: number | null
    initialLongitude?: number | null
    // 新規投稿では地図の初期位置（現在地）もフォームへ反映する（旧 map_new_post.js の挙動）
    emitInitialLocation?: boolean
    // 「位置なし」選択時に地図のクリック・検索・現在地を無効化する
    disabled?: boolean
  }>(),
  {
    initialLatitude: null,
    initialLongitude: null,
    emitInitialLocation: false,
    disabled: false
  }
)
const emit = defineEmits<{ 'location-selected': [location: MapLocation] }>()

const meta = useMetaStore()
const mapElement = ref<HTMLDivElement | null>(null)
const searchWord = ref('')
const mapAvailable = ref(!!googleMapsApiKey)

let gmaps: typeof google | null = null
let map: google.maps.Map | null = null
let marker: google.maps.Marker | null = null
let geocoder: google.maps.Geocoder | null = null

const TOKYO_STATION = { lat: 35.6803997, lng: 139.7690174 }

onMounted(async () => {
  await meta.ensureLoaded()
  gmaps = await loadGoogleMaps()
  if (!gmaps) return // API キー未設定 → 地図なしで動作を続ける

  geocoder = new gmaps.maps.Geocoder()

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

function initMap(center: google.maps.LatLngLiteral, { withMarker, emitLocation }: { withMarker: boolean; emitLocation: boolean }) {
  if (!gmaps || !mapElement.value) return
  map = new gmaps.maps.Map(mapElement.value, { center, zoom: 15 })
  const latLng = new gmaps.maps.LatLng(center.lat, center.lng)
  if (withMarker) placeMarker(latLng)
  if (emitLocation) resolveAndEmit(latLng)
  map.addListener('click', (event: google.maps.MapMouseEvent) => {
    if (event.latLng) selectLocation(event.latLng)
  })
}

function placeMarker(latLng: google.maps.LatLng) {
  if (!gmaps || !map) return
  if (marker) marker.setMap(null)
  marker = new gmaps.maps.Marker({ map, position: latLng, draggable: true })
  // マーカーのドロップ（ドラッグ終了）時にも位置情報を更新する
  marker.addListener('dragend', (event: google.maps.MapMouseEvent) => {
    if (event.latLng) selectLocation(event.latLng, { pan: false })
  })
}

function selectLocation(latLng: google.maps.LatLng, { pan = true } = {}) {
  if (pan) map?.panTo(latLng)
  placeMarker(latLng)
  resolveAndEmit(latLng)
}

// 逆ジオコーディングで都道府県・地域・place_id を取得してフォームへ反映する
function resolveAndEmit(latLng: google.maps.LatLng) {
  if (!geocoder) return
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
      place: results[0].place_id ?? '',
      prefecture: known ? prefecture : '',
      region: known ? meta.prefectureToRegion[prefecture] : ''
    })
  })
}

// 現在地への移動
function moveToCurrentLocation() {
  if (!navigator.geolocation || !map) return
  navigator.geolocation.getCurrentPosition((position) => {
    if (!gmaps || !map) return
    const latLng = new gmaps.maps.LatLng(position.coords.latitude, position.coords.longitude)
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
      map?.setCenter(location)
      placeMarker(location)
      resolveAndEmit(location)
    } else {
      window.alert('該当する結果がありませんでした：' + status)
    }
  })
}
</script>

<template>
  <div class="space-y-2">
    <div class="flex items-center gap-1 text-sm">
      <MapPinIcon class="size-4" />地図にピンをさしてください
    </div>
    <template v-if="mapAvailable">
      <div class="flex gap-2">
        <Button type="button" id="current_location" variant="outline" :disabled="disabled" @click="moveToCurrentLocation">現在地</Button>
        <Input
          id="placeSearch"
          v-model="searchWord"
          type="text"
          placeholder="場所を検索"
          :disabled="disabled"
          @keydown.enter.prevent="searchLocation"
        />
        <Button type="button" id="search-location-btn" variant="outline" :disabled="disabled" @click="searchLocation">検索</Button>
      </div>
      <div class="relative">
        <div id="map" ref="mapElement" class="h-100 w-full rounded-md" :class="{ 'pointer-events-none': disabled }"></div>
        <!-- overlay で地図を覆い、クリック不可であることを視覚的にも示す -->
        <div
          v-if="disabled"
          class="bg-background/60 text-muted-foreground absolute inset-0 z-10 flex items-center justify-center rounded-md"
        >
          位置情報は保存されません
        </div>
      </div>
    </template>
    <Alert v-else>
      <AlertDescription>
        Google Maps API キー（VITE_GOOGLE_MAPS_API_KEY）が設定されていないため地図を表示できません。
        位置情報を設定できないため、投稿の作成には API キーの設定が必要です。
      </AlertDescription>
    </Alert>
  </div>
</template>
