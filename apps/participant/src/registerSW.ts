// Service Worker を登録する（対応ブラウザのみ）。
// 開発時はキャッシュが邪魔になるため本番ビルドでのみ登録する。
export function registerSW() {
  if (!('serviceWorker' in navigator)) return
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js').catch((err) => {
      console.error('Service Worker の登録に失敗しました:', err)
    })
  })
}
