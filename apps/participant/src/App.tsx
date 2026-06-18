import { useEffect, useState } from 'react'
import type { Event } from '@bplus/types'
import { ApiError } from '@bplus/api-client'
import { api } from './api'
import './App.css'

function App() {
  const [events, setEvents] = useState<Event[]>([])
  const [status, setStatus] = useState('読み込み中…')

  // ページ表示（リロード）時に DB の最新イベントを取得する。
  useEffect(() => {
    api.events
      .list()
      .then((list) => {
        setEvents(list)
        setStatus(list.length === 0 ? 'まだイベントはありません。' : '')
      })
      .catch((e) => {
        setStatus(
          e instanceof ApiError
            ? `API エラー: ${e.status}`
            : '通信に失敗しました（API サーバーが起動しているか確認してください）',
        )
      })
  }, [])

  return (
    <main className="container">
      <h1>bplus</h1>
      <p className="lead">開催予定・開催済みのイベント一覧</p>

      {status && <p className="status">{status}</p>}

      <ul className="event-list">
        {events.map((ev) => (
          <li key={ev.id}>
            <span className="event-name">{ev.event_name}</span>
            <span className="event-date">{formatDate(ev.created_at)}</span>
          </li>
        ))}
      </ul>
    </main>
  )
}

function formatDate(iso: string): string {
  return new Date(iso).toLocaleString('ja-JP')
}

export default App
