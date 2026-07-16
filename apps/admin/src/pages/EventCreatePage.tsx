import { useState, type FormEvent } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { api } from '../api'
import { errorMessage } from '../utils'

export function EventCreatePage() {
  const navigate = useNavigate()
  const [name, setName] = useState('')
  const [heldAt, setHeldAt] = useState('')
  const [status, setStatus] = useState('')
  const [submitting, setSubmitting] = useState(false)

  async function handleSubmit(e: FormEvent) {
    e.preventDefault()
    const event_name = name.trim()
    if (!event_name || submitting) return
    setSubmitting(true)
    try {
      // datetime-local はタイムゾーンなしのローカル時刻なので、ISO 8601（UTC）に変換して送る。
      // 未入力なら held_at 自体を送らない（未定のイベント）。
      await api.events.create({
        event_name,
        ...(heldAt ? { held_at: new Date(heldAt).toISOString() } : {}),
      })
      navigate('/')
    } catch (err) {
      setStatus(errorMessage(err))
      setSubmitting(false)
    }
  }

  return (
    <>
      <p className="lead">イベント名と開催日時（任意）を入力してください。</p>

      <form className="create-form" onSubmit={handleSubmit}>
        <label>
          イベント名
          <input
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="イベント名を入力"
          />
        </label>
        <label>
          開催日時（任意）
          <input type="datetime-local" value={heldAt} onChange={(e) => setHeldAt(e.target.value)} />
        </label>
        <button type="submit" disabled={submitting || name.trim() === ''}>
          {submitting ? '作成中…' : '作成する'}
        </button>
      </form>

      {status && <p className="status">{status}</p>}

      <p>
        <Link to="/">イベント一覧へ戻る</Link>
      </p>
    </>
  )
}
