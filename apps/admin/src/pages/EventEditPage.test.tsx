import { describe, it, expect, vi, afterEach } from 'vitest'
import { render, screen, waitFor, cleanup } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter, Routes, Route } from 'react-router-dom'
import { EventEditPage } from './EventEditPage'
import { api } from '../api'

// API 通信はモックし、フォームの振る舞いのみを検証する。
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
        participants: [],
      }),
      update: vi.fn().mockResolvedValue({}),
    },
  },
}))

function renderEditPage() {
  return render(
    <MemoryRouter initialEntries={['/events/event-1/edit']}>
      <Routes>
        <Route path="/events/:eventId/edit" element={<EventEditPage />} />
      </Routes>
    </MemoryRouter>,
  )
}

describe('EventEditPage', () => {
  // vitest の globals を使っていないため、Testing Library の自動クリーンアップが効かない。
  afterEach(cleanup)

  it('既存のイベント名が初期値として読み込まれる', async () => {
    renderEditPage()

    const input = (await screen.findByLabelText('イベント名')) as HTMLInputElement
    expect(input.value).toBe('歓迎会')
  })

  it('保存すると更新 API が呼ばれる', async () => {
    const user = userEvent.setup()
    renderEditPage()

    const input = (await screen.findByLabelText('イベント名')) as HTMLInputElement
    await user.clear(input)
    await user.type(input, '歓迎会（改）')
    await user.click(screen.getByRole('button', { name: '保存する' }))

    await waitFor(() => {
      expect(api.events.update).toHaveBeenCalledWith('event-1', {
        event_name: '歓迎会（改）',
        held_at: null,
      })
    })
  })
})
