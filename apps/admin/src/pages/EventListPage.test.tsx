import { describe, it, expect, vi, afterEach } from 'vitest'
import { render, screen, cleanup } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { EventListPage } from './EventListPage'

// API 通信はモックし、描画のみを検証する。
vi.mock('../api', () => ({
  api: {
    events: {
      list: vi.fn().mockResolvedValue([]),
    },
  },
}))

describe('EventListPage', () => {
  // vitest の globals を使っていないため、Testing Library の自動クリーンアップが効かない。
  afterEach(cleanup)

  it('イベント作成ページへの導線が表示される', () => {
    render(
      <MemoryRouter>
        <EventListPage />
      </MemoryRouter>,
    )

    const link = screen.getByRole('link', { name: 'イベントを作成する' })
    expect(link.getAttribute('href')).toBe('/events/new')
  })
})
