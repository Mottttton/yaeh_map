// Rails API のレスポンス型定義（app/serializers・各コントローラと 1:1 で対応）

/** AccountSerializer.basic — 投稿カードに載せる投稿者情報 */
export interface AccountBasic {
  id: number
  name: string
  nickname: string
  portrait_thumb_url: string | null
}

/** AccountSerializer.profile — プロフィール画面用 */
export interface AccountProfile extends AccountBasic {
  region: string | null
  self_introduction: string | null
  portrait_url: string | null
}

/** AccountSerializer.session — ログイン中の本人情報（セッション API 用） */
export interface SessionAccount extends AccountProfile {
  email: string
  admin: boolean
}

/** Api::V1::Admin::AccountsController#admin_json */
export interface AdminAccount {
  id: number
  name: string
  nickname: string
  email: string
  region: string | null
  admin: boolean
  posts_count: number
  created_at: string
}

/** PostSerializer.photo_json */
export interface PostPhoto {
  url: string
  thumb_url: string
}

/** PostSerializer.card */
export interface Post {
  id: number
  title: string
  description: string
  genre: string
  region: string
  prefecture: string | null
  place: string
  latitude: number
  longitude: number
  created_at: string
  account: AccountBasic
  photos: PostPhoto[]
  favorites_count: number
  favorited: boolean
}

/** Api::V1::BaseController#pagination_meta */
export interface PaginationMeta {
  current_page: number
  total_pages: number
  total_count: number
  per_page: number
}

/** Api::V1::MetaController#show の選択肢（label: 表示名 / value: enum 値） */
export interface MetaOption {
  label: string
  value: number
}

/** Api::V1::MetaController#show */
export interface MetaResponse {
  regions: MetaOption[]
  prefectures: MetaOption[]
  genres: MetaOption[]
  prefecture_to_region: Record<string, string>
}

/** いいねトグル API のレスポンス */
export interface FavoriteState {
  favorited: boolean
  favorites_count: number
}

/** MapPicker が emit する選択地点（逆ジオコーディング結果込み） */
export interface MapLocation {
  latitude: number
  longitude: number
  place: string
  prefecture: string
  region: string
}

/** フラッシュメッセージ（旧 Rails flash 相当。success / danger） */
export type FlashType = 'success' | 'danger'

export interface FlashMessage {
  id: number
  type: FlashType
  text: string
}
