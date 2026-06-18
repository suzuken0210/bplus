import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  // 環境変数はリポジトリルートの .env を共通利用する（VITE_ プレフィックスのみ公開）
  envDir: '../../',
  // 参加者は 5174 固定（管理画面 5173 と衝突させない）
  server: { port: 5174, strictPort: true },
  preview: { port: 5174 },
  // PWA は public/manifest.webmanifest と public/sw.js（手書き Service Worker）で実現する。
  // 本格的なプリキャッシュ（Workbox）が必要になったら vite-plugin-pwa の導入を検討する。
})
