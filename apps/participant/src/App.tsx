import { useEffect, useState, type FormEvent } from 'react'
import type { Event } from '@bplus/types'
import { ApiError } from '@bplus/api-client'
import { api } from './api'
import './App.css'

// モックのログインユーザー（API が返す最小情報）。
type LoginUser = { id: string; name: string }

function App() {
  // ログイン状態は state のみで保持する。リロードで消える＝自動ログアウト（mock）。
  const [user, setUser] = useState<LoginUser | null>(null)

  if (!user) return <LoginView onLogin={setUser} />
  return <EventListView user={user} />
}

function LoginView({ onLogin }: { onLogin: (user: LoginUser) => void }) {
  const [name, setName] = useState('')
  const [status, setStatus] = useState('')
  const [submitting, setSubmitting] = useState(false)

  async function handleSubmit(e: FormEvent) {
    e.preventDefault()
    const value = name.trim()
    if (!value || submitting) return
    setSubmitting(true)
    setStatus('')
    try {
      onLogin(await api.login(value))
    } catch (err) {
      setStatus(
        err instanceof ApiError && err.status === 404
          ? '該当するユーザーが見つかりません'
          : '通信に失敗しました（API サーバーが起動しているか確認してください）',
      )
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <main className="container">
      <h1>bplus ログイン</h1>
      <p className="lead">登録済みの名前を入力してください（モック）。</p>
      <form className="login-form" onSubmit={handleSubmit}>
        <input
          type="text"
          value={name}
          onChange={(e) => setName(e.target.value)}
          placeholder="名前を入力"
          aria-label="名前"
        />
        <button type="submit" disabled={submitting || name.trim() === ''}>
          {submitting ? '確認中…' : '確定'}
        </button>
      </form>
      {status && <p className="status">{status}</p>}
    </main>
  )
}

function EventListView({ user }: { user: LoginUser }) {
  const [events, setEvents] = useState<Event[]>([])
  const [status, setStatus] = useState('読み込み中…')

  // 表示（リロード）時に DB の最新イベントを取得する。
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
      <p className="lead">ようこそ、{user.name} さん（開催予定・開催済みのイベント一覧）</p>

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
