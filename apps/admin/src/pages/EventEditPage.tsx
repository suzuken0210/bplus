import { useEffect, useState, type FormEvent } from 'react'
import { Link, useNavigate, useParams } from 'react-router-dom'
import { ApiError } from '@bplus/api-client'
import { api } from '../api'
import { errorMessage, toDatetimeLocal } from '../utils'

export function EventEditPage() {
  const { eventId } = useParams()
  const navigate = useNavigate()
  const [name, setName] = useState('')
  const [heldAt, setHeldAt] = useState('')
  const [status, setStatus] = useState('読み込み中…')
  const [loaded, setLoaded] = useState(false)
  const [submitting, setSubmitting] = useState(false)

  // 既存の値を初期値としてフォームに読み込む。
  useEffect(() => {
    if (!eventId) return
    api.events
      .get(eventId)
      .then((detail) => {
        setName(detail.event_name)
        setHeldAt(detail.held_at ? toDatetimeLocal(detail.held_at) : '')
        setStatus('')
        setLoaded(true)
      })
      .catch((e) => {
        setStatus(
          e instanceof ApiError && e.status === 404 ? 'イベントが見つかりません' : errorMessage(e),
        )
      })
  }, [eventId])

  async function handleSubmit(e: FormEvent) {
    e.preventDefault()
    const event_name = name.trim()
    if (!eventId || !event_name || submitting) return
    setSubmitting(true)
    try {
      // datetime-local はタイムゾーンなしのローカル時刻なので ISO 8601（UTC）に変換して送る。
      // 空なら held_at を null で送り、開催日時を「未定」に戻す。
      await api.events.update(eventId, {
        event_name,
        held_at: heldAt ? new Date(heldAt).toISOString() : null,
      })
      navigate(`/events/${eventId}`)
    } catch (err) {
      setStatus(errorMessage(err))
      setSubmitting(false)
    }
  }

  return (
    <>
      <p className="lead">イベントの内容を編集してください。</p>

      {status && <p className="status">{status}</p>}

      {loaded && (
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
            <input
              type="datetime-local"
              value={heldAt}
              onChange={(e) => setHeldAt(e.target.value)}
            />
          </label>
          <button type="submit" disabled={submitting || name.trim() === ''}>
            {submitting ? '保存中…' : '保存する'}
          </button>
        </form>
      )}

      <p>
        <Link to={eventId ? `/events/${eventId}` : '/'}>← イベント詳細に戻る</Link>
      </p>
    </>
  )
}
