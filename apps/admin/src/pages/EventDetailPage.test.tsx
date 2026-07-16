import { describe, it, expect, vi, afterEach } from 'vitest'
import { render, screen, cleanup } from '@testing-library/react'
import { MemoryRouter, Routes, Route } from 'react-router-dom'
import { EventDetailPage } from './EventDetailPage'

// API 通信はモックし、描画のみを検証する。
vi.mock('../api', () => ({
  api: {
    events: {
      get: vi.fn().mockResolvedValue({
        id: 'event-1',
        event_name: '歓迎会',
        held_at: null,
        created_at: '2026-07-01T10:00:00Z',
        updated_at: '2026-07-01T10:00:00Z',
        discarded_at: null,
        participants: [{ id: 'user-1', name: '参加者A' }],
      }),
    },
  },
}))

describe('EventDetailPage', () => {
  // vitest の globals を使っていないため、Testing Library の自動クリーンアップが効かない。
  afterEach(cleanup)

  it('イベント名・開催日時（未定）・参加者一覧が表示される', async () => {
    render(
      <MemoryRouter initialEntries={['/events/event-1']}>
        <Routes>
          <Route path="/events/:eventId" element={<EventDetailPage />} />
        </Routes>
      </MemoryRouter>,
    )

    expect(await screen.findByRole('heading', { name: '歓迎会' })).toBeTruthy()
    expect(screen.getByText('未定')).toBeTruthy()
    expect(screen.getByText('参加者（1人）')).toBeTruthy()
    expect(screen.getByText('参加者A')).toBeTruthy()
  })
})
