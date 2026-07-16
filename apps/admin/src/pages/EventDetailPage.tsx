import { useEffect, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import type { EventDetail } from '@bplus/types'
import { ApiError } from '@bplus/api-client'
import { api } from '../api'
import { errorMessage, formatDate } from '../utils'

export function EventDetailPage() {
  const { eventId } = useParams()
  const [event, setEvent] = useState<EventDetail | null>(null)
  const [status, setStatus] = useState('読み込み中…')

  // 表示（リロード）時にイベント詳細と参加者を取得する＝常に最新状況。
  useEffect(() => {
    if (!eventId) return
    api.events
      .get(eventId)
      .then((detail) => {
        setEvent(detail)
        setStatus('')
      })
      .catch((e) => {
        setEvent(null)
        setStatus(
          e instanceof ApiError && e.status === 404 ? 'イベントが見つかりません' : errorMessage(e),
        )
      })
  }, [eventId])

  return (
    <>
      <p>
        <Link to="/">← イベント一覧に戻る</Link>
      </p>

      <h2>{event ? event.event_name : 'イベント詳細'}</h2>

      {status && <p className="status">{status}</p>}

      {event && (
        <>
          <dl className="event-meta">
            <dt>開催日時</dt>
            <dd>{event.held_at ? formatDate(event.held_at) : '未定'}</dd>
            <dt>作成日時</dt>
            <dd>{formatDate(event.created_at)}</dd>
          </dl>

          <h2>参加者（{event.participants.length}人）</h2>
          {event.participants.length === 0 ? (
            <p className="status">まだ参加者はいません。</p>
          ) : (
            <ul className="participant-list">
              {event.participants.map((p) => (
                <li key={p.id}>{p.name}</li>
              ))}
            </ul>
          )}
        </>
      )}
    </>
  )
}
