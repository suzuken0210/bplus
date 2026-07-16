import { describe, it, expect, vi, afterEach } from 'vitest'
import { render, screen, waitFor, cleanup } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter } from 'react-router-dom'
import { EventCreatePage } from './EventCreatePage'
import { api } from '../api'

// API 通信はモックし、フォームの振る舞いのみを検証する。
vi.mock('../api', () => ({
  api: {
    events: {
      create: vi.fn().mockResolvedValue({}),
    },
  },
}))

describe('EventCreatePage', () => {
  // vitest の globals を使っていないため、Testing Library の自動クリーンアップが効かない。
  afterEach(cleanup)

  it('イベント名と開催日時の入力欄が表示される', () => {
    render(
      <MemoryRouter>
        <EventCreatePage />
      </MemoryRouter>,
    )
    expect(screen.getByLabelText('イベント名')).toBeTruthy()
    expect(screen.getByLabelText('開催日時（任意）')).toBeTruthy()
  })

  it('イベント名のみ入力して送信すると held_at なしで作成 API を呼ぶ', async () => {
    const user = userEvent.setup()
    render(
      <MemoryRouter>
        <EventCreatePage />
      </MemoryRouter>,
    )

    await user.type(screen.getByLabelText('イベント名'), '歓迎会')
    await user.click(screen.getByRole('button', { name: '作成する' }))

    await waitFor(() => {
      expect(api.events.create).toHaveBeenCalledWith({ event_name: '歓迎会' })
    })
  })
})
