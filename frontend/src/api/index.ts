import client from './client'
import type {
  AccountProfile,
  AdminAccount,
  FavoriteState,
  MetaResponse,
  PaginationMeta,
  Post,
  SessionAccount
} from '../types'

export interface MessageResponse {
  message: string
}

export interface AccountResponse {
  account: SessionAccount
  message: string
}

export interface LoginPayload {
  email: string
  password: string
  remember_me: boolean
}

export interface CredentialsPayload {
  account: {
    name: string
    email: string
    password: string
    password_confirmation: string
    current_password: string
  }
}

export interface ResetPasswordPayload {
  reset_password_token: string
  password: string
  password_confirmation: string
}

export const authApi = {
  fetchSession: () => client.get<{ account: SessionAccount | null }>('/session'),
  login: (payload: LoginPayload) => client.post<AccountResponse>('/session', payload),
  logout: () => client.delete<MessageResponse>('/session'),
  signup: (formData: FormData) => client.post<AccountResponse>('/registration', formData),
  updateCredentials: (payload: CredentialsPayload) => client.patch<AccountResponse>('/registration', payload),
  deleteAccount: () => client.delete<MessageResponse>('/registration'),
  sendResetMail: (email: string) => client.post<MessageResponse>('/password', { email }),
  resetPassword: (payload: ResetPasswordPayload) => client.patch<MessageResponse>('/password', payload)
}

export const metaApi = {
  fetch: () => client.get<MetaResponse>('/meta')
}

/** 二段階アップロード API のレスポンス。signed_id をフォーム送信に含めると添付が確定する */
export interface UploadedBlob {
  signed_id: string
  url: string
}

export const uploadsApi = {
  create: (file: File) => {
    const formData = new FormData()
    formData.append('file', file)
    return client.post<UploadedBlob>('/uploads', formData)
  },
  // 未確定（未添付）のアップロードを破棄する
  destroy: (signedId: string) => client.delete<void>(`/uploads/${encodeURIComponent(signedId)}`)
}

export interface PostsIndexParams {
  page?: string | number
  q?: Record<string, unknown>
}

export interface PostPayload {
  post: {
    title: string
    description: string
    genre: string
    region: string
    prefecture: string
    /** 位置精度（enum の英語キー: exact / approximate / no_location） */
    location_accuracy: string
    place: string
    /** 位置なしでは null（おおまか / 位置なしのクリア・丸めはサーバ側でも強制される） */
    latitude: number | null
    longitude: number | null
    /** 投稿に残す写真の signed_id（全量置き換え。含めなかった既存写真は削除される） */
    photo_signed_ids: string[]
  }
}

export const postsApi = {
  index: (params: PostsIndexParams) => client.get<{ posts: Post[]; meta: PaginationMeta }>('/posts', { params }),
  show: (id: string | number) => client.get<{ post: Post }>(`/posts/${id}`),
  create: (payload: PostPayload) => client.post<{ post: Post; message: string }>('/posts', payload),
  update: (id: string | number, payload: PostPayload) => client.patch<{ post: Post; message: string }>(`/posts/${id}`, payload),
  destroy: (id: string | number) => client.delete<MessageResponse>(`/posts/${id}`)
}

export const favoritesApi = {
  create: (postId: number) => client.post<FavoriteState>(`/posts/${postId}/favorite`),
  destroy: (postId: number) => client.delete<FavoriteState>(`/posts/${postId}/favorite`)
}

export interface AccountUpdatePayload {
  account: {
    nickname: string
    region: string
    self_introduction: string
    /** uploads API が払い出した signed_id。指定するとアイコンを差し替える */
    portrait?: string
    /** true でアイコンを削除する（portrait の指定がある場合はそちらを優先） */
    remove_portrait?: boolean
  }
}

export const accountsApi = {
  show: (id: string | number, params?: Record<string, unknown>) =>
    client.get<{ account: AccountProfile; posts: Post[]; meta: PaginationMeta }>(`/accounts/${id}`, { params }),
  update: (id: string | number, payload: AccountUpdatePayload) =>
    client.patch<{ account: AccountProfile; message: string }>(`/accounts/${id}`, payload)
}

export const adminApi = {
  accounts: (params?: Record<string, unknown>) =>
    client.get<{ accounts: AdminAccount[]; meta: PaginationMeta }>('/admin/accounts', { params }),
  destroyAccount: (id: number) => client.delete<MessageResponse>(`/admin/accounts/${id}`)
}
