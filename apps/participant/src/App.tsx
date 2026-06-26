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
  const [joined, setJoined] = useState<Set<string>>(new Set())
  const [pending, setPending] = useState<Set<string>>(new Set())
  const [status, setStatus] = useState('読み込み中…')

  // 表示（リロード）時に、イベント一覧と自分の参加状況を取得する。
  useEffect(() => {
    Promise.all([api.events.list(), api.participations.listByUser(user.id)])
      .then(([list, parts]) => {
        setEvents(list)
        setJoined(new Set(parts.map((p) => p.event_id)))
        setStatus(list.length === 0 ? 'まだイベントはありません。' : '')
      })
      .catch((e) => setStatus(errorMessage(e)))
  }, [user.id])

  async function toggle(eventId: string) {
    if (pending.has(eventId)) return
    const isJoined = joined.has(eventId)
    setPending((s) => new Set(s).add(eventId))
    try {
      if (isJoined) {
        await api.participations.cancel(eventId, user.id)
      } else {
        await api.participations.join(eventId, user.id)
      }
      setJoined((s) => {
        const next = new Set(s)
        if (isJoined) next.delete(eventId)
        else next.add(eventId)
        return next
      })
    } catch (e) {
      setStatus(errorMessage(e))
    } finally {
      setPending((s) => {
        const next = new Set(s)
        next.delete(eventId)
        return next
      })
    }
  }

  return (
    <main className="container">
      <h1>bplus</h1>
      <p className="lead">ようこそ、{user.name} さん（開催予定・開催済みのイベント一覧）</p>

      {status && <p className="status">{status}</p>}

      <ul className="event-list">
        {events.map((ev) => {
          const isJoined = joined.has(ev.id)
          return (
            <li key={ev.id}>
              <span className="event-main">
                <span className="event-name">{ev.event_name}</span>
                <span className="event-date">{formatDate(ev.created_at)}</span>
              </span>
              <button
                type="button"
                className={isJoined ? 'btn-cancel' : 'btn-join'}
                disabled={pending.has(ev.id)}
                onClick={() => toggle(ev.id)}
              >
                {isJoined ? 'キャンセル' : '参加'}
              </button>
            </li>
          )
        })}
      </ul>
    </main>
  )
}

function errorMessage(e: unknown): string {
  return e instanceof ApiError
    ? `API エラー: ${e.status}`
    : '通信に失敗しました（API サーバーが起動しているか確認してください）'
}

function formatDate(iso: string): string {
  return new Date(iso).toLocaleString('ja-JP')
}

export default App
