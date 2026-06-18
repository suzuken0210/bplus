import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  // 環境変数はリポジトリルートの .env を共通利用する（VITE_ プレフィックスのみ公開）
  envDir: '../../',
  // 管理画面は 5173 固定（参加者 5174 と衝突させない）
  server: { port: 5173, strictPort: true },
  preview: { port: 5173 },
})
