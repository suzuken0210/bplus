import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'

// モノレポ全体のテストを 1 つの設定で実行する（プロジェクト単位で環境を分ける）。
// - apps/*: ブラウザ相当（jsdom）でコンポーネントを検証
// - packages/*: Node 環境でロジックを検証
export default defineConfig({
  test: {
    projects: [
      {
        plugins: [react()],
        test: { name: 'admin', root: './apps/admin', environment: 'jsdom' },
      },
      {
        plugins: [react()],
        test: { name: 'participant', root: './apps/participant', environment: 'jsdom' },
      },
      {
        test: { name: 'api-client', root: './packages/api-client', environment: 'node' },
      },
    ],
  },
})
