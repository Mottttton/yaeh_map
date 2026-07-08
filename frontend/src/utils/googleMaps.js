import { Loader } from '@googlemaps/js-api-loader'

export const googleMapsApiKey = import.meta.env.VITE_GOOGLE_MAPS_API_KEY || ''

let loaderPromise = null

// Google Maps JS API を一度だけロードする。
// API キー未設定なら null を返し、呼び出し側は地図なしで動作を続ける。
export function loadGoogleMaps() {
  if (!googleMapsApiKey) return Promise.resolve(null)
  if (!loaderPromise) {
    const loader = new Loader({ apiKey: googleMapsApiKey, language: 'ja' })
    loaderPromise = Promise.all([
      loader.importLibrary('maps'),
      loader.importLibrary('marker'),
      loader.importLibrary('geocoding')
    ]).then(() => window.google)
  }
  return loaderPromise
}

// 投稿カードに表示する Static Maps API の画像 URL
export function staticMapUrl(latitude, longitude, { width = 400, height = 300, zoom = 16 } = {}) {
  if (!googleMapsApiKey) return null
  const markers = encodeURIComponent(`color:red|${latitude},${longitude}`)
  return `https://maps.googleapis.com/maps/api/staticmap?center=${latitude},${longitude}&zoom=${zoom}&size=${width}x${height}&markers=${markers}&key=${googleMapsApiKey}`
}

// 投稿詳細に表示する Embed API の iframe URL
export function embedMapUrl(placeId, latitude, longitude, zoom = 15) {
  if (!googleMapsApiKey) return null
  return `https://www.google.com/maps/embed/v1/place?key=${googleMapsApiKey}&q=place_id:${placeId}&center=${latitude},${longitude}&zoom=${zoom}`
}

// キー無しでも使える Google マップへの外部リンク
export function googleMapsLinkUrl(latitude, longitude) {
  return `https://www.google.com/maps/search/?api=1&query=${latitude},${longitude}`
}
