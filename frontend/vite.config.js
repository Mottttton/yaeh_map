import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// Rails API サーバのオリジン（開発時の proxy 先）。
// Rails を別ポートで動かす場合は VITE_API_ORIGIN で上書きする。
const apiOrigin = process.env.VITE_API_ORIGIN || 'http://localhost:3000'

export default defineConfig({
  plugins: [vue()],
  server: {
    port: 5173,
    proxy: {
      // API と Active Storage（画像配信）を Rails へ転送し、同一オリジンとして扱う
      '/api': { target: apiOrigin },
      '/rails': { target: apiOrigin }
    }
  },
  build: {
    // Rails の public/ へ出力し、Rails（または Nginx）がそのまま配信できるようにする
    outDir: '../public',
    emptyOutDir: false
  }
})
