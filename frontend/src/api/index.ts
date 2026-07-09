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

export interface PostsIndexParams {
  page?: string | number
  q?: Record<string, unknown>
}

export const postsApi = {
  index: (params: PostsIndexParams) => client.get<{ posts: Post[]; meta: PaginationMeta }>('/posts', { params }),
  show: (id: string | number) => client.get<{ post: Post }>(`/posts/${id}`),
  create: (formData: FormData) => client.post<{ post: Post; message: string }>('/posts', formData),
  update: (id: string | number, formData: FormData) => client.patch<{ post: Post; message: string }>(`/posts/${id}`, formData),
  destroy: (id: string | number) => client.delete<MessageResponse>(`/posts/${id}`)
}

export const favoritesApi = {
  create: (postId: number) => client.post<FavoriteState>(`/posts/${postId}/favorite`),
  destroy: (postId: number) => client.delete<FavoriteState>(`/posts/${postId}/favorite`)
}

export const accountsApi = {
  show: (id: string | number, params?: Record<string, unknown>) =>
    client.get<{ account: AccountProfile; posts: Post[]; meta: PaginationMeta }>(`/accounts/${id}`, { params }),
  update: (id: string | number, formData: FormData) =>
    client.patch<{ account: AccountProfile; message: string }>(`/accounts/${id}`, formData)
}

export const adminApi = {
  accounts: (params?: Record<string, unknown>) =>
    client.get<{ accounts: AdminAccount[]; meta: PaginationMeta }>('/admin/accounts', { params }),
  destroyAccount: (id: number) => client.delete<MessageResponse>(`/admin/accounts/${id}`)
}
