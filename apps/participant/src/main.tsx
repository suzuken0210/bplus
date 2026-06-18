import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.tsx'
import { registerSW } from './registerSW.ts'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)

// PWA: 本番ビルドでのみ Service Worker を登録する。
if (import.meta.env.PROD) {
  registerSW()
}
