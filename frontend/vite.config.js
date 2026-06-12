import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    port: 5173,
    proxy: {
      '/restaurants': {
        target: 'http://localhost:8183',
        changeOrigin: true
      },
      '/orders': {
        target: 'http://localhost:8181',
        changeOrigin: true
      },
      '/customers': {
        target: 'http://localhost:8184',
        changeOrigin: true
      }
    }
  }
})
