// bplus 参加者アプリ 最小 Service Worker
// アプリシェルをキャッシュし、オフラインでも起動できるようにする最小実装。
// 本格的なプリキャッシュ（ビルド成果物のハッシュ管理など）が必要になったら
// vite-plugin-pwa（Workbox）の導入を検討する。
const CACHE = 'bplus-participant-v1'
const APP_SHELL = ['/', '/index.html', '/manifest.webmanifest', '/icon.svg']

self.addEventListener('install', (event) => {
  event.waitUntil(caches.open(CACHE).then((cache) => cache.addAll(APP_SHELL)))
  self.skipWaiting()
})

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)))),
  )
  self.clients.claim()
})

self.addEventListener('fetch', (event) => {
  const { request } = event
  if (request.method !== 'GET') return

  // API リクエスト（/api/ 配下）はキャッシュせず常にネットワークへ。
  const url = new URL(request.url)
  if (url.pathname.startsWith('/api/')) return

  if (request.mode === 'navigate') {
    // ナビゲーションは network-first（オフライン時はアプリシェルにフォールバック）。
    event.respondWith(
      fetch(request).catch(() =>
        caches.match('/index.html').then((cached) => cached ?? Response.error()),
      ),
    )
    return
  }

  // その他の同一オリジン資産は cache-first。
  event.respondWith(caches.match(request).then((cached) => cached ?? fetch(request)))
})
