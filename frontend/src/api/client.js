import axios from 'axios'

// Rails の CSRF 対策:
// Rails が払い出す Cookie "CSRF-TOKEN" の値を X-CSRF-Token ヘッダで送り返す
const client = axios.create({
  baseURL: '/api/v1',
  xsrfCookieName: 'CSRF-TOKEN',
  xsrfHeaderName: 'X-CSRF-Token'
})

// セッション切れ（401）時の共通ハンドラ。循環 import を避けるため登録方式にする
let onUnauthorized = null

export function setOnUnauthorized(handler) {
  onUnauthorized = handler
}

client.interceptors.response.use(
  (response) => response,
  (error) => {
    const status = error.response?.status
    const isLoginRequest = error.config?.method === 'post' && error.config?.url === '/session'
    if (status === 401 && !isLoginRequest && onUnauthorized) {
      onUnauthorized(error)
    }
    return Promise.reject(error)
  }
)

export default client
