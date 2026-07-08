import { defineStore } from 'pinia'
import { authApi } from '../api'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    account: null,
    initialized: false
  }),
  getters: {
    signedIn: (state) => !!state.account,
    isAdmin: (state) => !!state.account?.admin
  },
  actions: {
    // SPA 起動時にセッション状態を復元する
    async fetchSession() {
      try {
        const { data } = await authApi.fetchSession()
        this.account = data.account
      } catch {
        this.account = null
      } finally {
        this.initialized = true
      }
    },
    setAccount(account) {
      this.account = account
    },
    clear() {
      this.account = null
    }
  }
})
