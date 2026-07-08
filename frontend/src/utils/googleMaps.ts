import { Loader } from '@googlemaps/js-api-loader'

export const googleMapsApiKey = import.meta.env.VITE_GOOGLE_MAPS_API_KEY || ''

let loaderPromise: Promise<typeof google | null> | null = null

// Google Maps JS API を一度だけロードする。
// API キー未設定なら null を返し、呼び出し側は地図なしで動作を続ける。
export function loadGoogleMaps(): Promise<typeof google | null> {
  if (!googleMapsApiKey) return Promise.resolve(null)
  if (!loaderPromise) {
    const loader = new Loader({ apiKey: googleMapsApiKey, language: 'ja' })
    loaderPromise = Promise.all([
      loader.importLibrary('maps'),
      loader.importLibrary('marker'),
      loader.importLibrary('geocoding')
    ]).then(() => google)
  }
  return loaderPromise
}

interface StaticMapOptions {
  width?: number
  height?: number
  zoom?: number
}

// 投稿カードに表示する Static Maps API の画像 URL
export function staticMapUrl(
  latitude: number,
  longitude: number,
  { width = 400, height = 300, zoom = 16 }: StaticMapOptions = {}
): string | null {
  if (!googleMapsApiKey) return null
  const markers = encodeURIComponent(`color:red|${latitude},${longitude}`)
  return `https://maps.googleapis.com/maps/api/staticmap?center=${latitude},${longitude}&zoom=${zoom}&size=${width}x${height}&markers=${markers}&key=${googleMapsApiKey}`
}

// 投稿詳細に表示する Embed API の iframe URL
export function embedMapUrl(placeId: string, latitude: number, longitude: number, zoom = 15): string | null {
  if (!googleMapsApiKey) return null
  return `https://www.google.com/maps/embed/v1/place?key=${googleMapsApiKey}&q=place_id:${placeId}&center=${latitude},${longitude}&zoom=${zoom}`
}

// キー無しでも使える Google マップへの外部リンク
export function googleMapsLinkUrl(latitude: number, longitude: number): string {
  return `https://www.google.com/maps/search/?api=1&query=${latitude},${longitude}`
}
