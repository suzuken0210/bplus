import { useEffect, useState, type FormEvent } from 'react'
import type { Event } from '@bplus/types'
import { ApiError } from '@bplus/api-client'
import { api } from './api'
import './App.css'

function App() {
  const [events, setEvents] = useState<Event[]>([])
  const [name, setName] = useState('')
  const [status, setStatus] = useState('')
  const [submitting, setSubmitting] = useState(false)

  async function loadEvents() {
    try {
      const list = await api.events.list()
      setEvents(list)
      setStatus('')
    } catch (e) {
      setStatus(errorMessage(e))
    }
  }

  // 初回ロード時に最新のイベント一覧を取得する。
  // アンマウント後の setState を防ぐため active フラグでガードする。
  useEffect(() => {
    let active = true
    void (async () => {
      try {
        const list = await api.events.list()
        if (!active) return
        setEvents(list)
        setStatus('')
      } catch (e) {
        if (active) setStatus(errorMessage(e))
      }
    })()
    return () => {
      active = false
    }
  }, [])

  async function handleSubmit(e: FormEvent) {
    e.preventDefault()
    const event_name = name.trim()
    if (!event_name || submitting) return
    setSubmitting(true)
    try {
      await api.events.create({ event_name })
      setName('')
      await loadEvents() // 追加後に一覧を更新
    } catch (err) {
      setStatus(errorMessage(err))
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <main className="container">
      <h1>bplus 管理画面</h1>
      <p className="lead">イベントを追加すると、参加者ページに表示されます。</p>

      <form className="add-form" onSubmit={handleSubmit}>
        <input
          type="text"
          value={name}
          onChange={(e) => setName(e.target.value)}
          placeholder="イベント名を入力"
          aria-label="イベント名"
        />
        <button type="submit" disabled={submitting || name.trim() === ''}>
          {submitting ? '追加中…' : '追加'}
        </button>
      </form>

      {status && <p className="status">{status}</p>}

      <h2>イベント一覧（{events.length} 件）</h2>
      <ol className="event-list">
        {events.map((ev) => (
          <li key={ev.id}>
            <span className="event-name">{ev.event_name}</span>
            <span className="event-date">{formatDate(ev.created_at)}</span>
          </li>
        ))}
      </ol>
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
