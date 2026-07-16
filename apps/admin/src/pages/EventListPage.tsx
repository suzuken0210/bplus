import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import type { Event } from '@bplus/types'
import { api } from '../api'
import { errorMessage, formatDate } from '../utils'

export function EventListPage() {
  const [events, setEvents] = useState<Event[]>([])
  const [status, setStatus] = useState('')

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

  return (
    <>
      <p className="lead">イベントを追加すると、参加者ページに表示されます。</p>

      <p>
        <Link className="button-link" to="/events/new">
          イベントを作成する
        </Link>
      </p>

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
    </>
  )
}
