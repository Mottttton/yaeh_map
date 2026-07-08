import client from './client'

export const authApi = {
  fetchSession: () => client.get('/session'),
  login: (payload) => client.post('/session', payload),
  logout: () => client.delete('/session'),
  signup: (formData) => client.post('/registration', formData),
  updateCredentials: (payload) => client.patch('/registration', payload),
  deleteAccount: () => client.delete('/registration'),
  sendResetMail: (email) => client.post('/password', { email }),
  resetPassword: (payload) => client.patch('/password', payload)
}

export const metaApi = {
  fetch: () => client.get('/meta')
}

export const postsApi = {
  index: (params) => client.get('/posts', { params }),
  show: (id) => client.get(`/posts/${id}`),
  create: (formData) => client.post('/posts', formData),
  update: (id, formData) => client.patch(`/posts/${id}`, formData),
  destroy: (id) => client.delete(`/posts/${id}`)
}

export const favoritesApi = {
  create: (postId) => client.post(`/posts/${postId}/favorite`),
  destroy: (postId) => client.delete(`/posts/${postId}/favorite`)
}

export const accountsApi = {
  show: (id, params) => client.get(`/accounts/${id}`, { params }),
  update: (id, formData) => client.patch(`/accounts/${id}`, formData)
}

export const adminApi = {
  accounts: (params) => client.get('/admin/accounts', { params }),
  destroyAccount: (id) => client.delete(`/admin/accounts/${id}`)
}
