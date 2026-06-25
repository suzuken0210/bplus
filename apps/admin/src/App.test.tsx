import { describe, it, expect, vi } from 'vitest'
import { render, screen } from '@testing-library/react'
import App from './App'

// API 通信はモックし、描画のみを検証する。
vi.mock('./api', () => ({
  api: {
    events: {
      list: vi.fn().mockResolvedValue([]),
      create: vi.fn(),
    },
  },
}))

describe('App (admin)', () => {
  it('見出しが表示される', () => {
    render(<App />)
    expect(screen.getByRole('heading', { name: 'bplus 管理画面' })).toBeTruthy()
  })
})
