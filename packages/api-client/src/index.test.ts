import { describe, it, expect, vi, beforeEach } from 'vitest'
import { createApiClient, ApiError } from './index'

function jsonResponse(body: unknown, init?: ResponseInit) {
  return new Response(JSON.stringify(body), {
    status: 200,
    headers: { 'Content-Type': 'application/json' },
    ...init,
  })
}

describe('createApiClient', () => {
  beforeEach(() => {
    vi.restoreAllMocks()
  })

  it('events.list が GET /events を正しい URL で呼ぶ', async () => {
    const fetchMock = vi.fn().mockResolvedValue(jsonResponse([]))
    vi.stubGlobal('fetch', fetchMock)

    const client = createApiClient({ baseUrl: 'http://api.test/api/v1' })
    await client.events.list()

    expect(fetchMock).toHaveBeenCalledOnce()
    expect(fetchMock.mock.calls[0][0]).toBe('http://api.test/api/v1/events')
  })

  it('非 2xx は ApiError を throw する', async () => {
    const fetchMock = vi
      .fn()
      .mockResolvedValue(jsonResponse({}, { status: 500, statusText: 'Server Error' }))
    vi.stubGlobal('fetch', fetchMock)

    const client = createApiClient({ baseUrl: 'http://api.test/api/v1' })
    await expect(client.events.list()).rejects.toBeInstanceOf(ApiError)
  })

  it('getToken があれば Authorization ヘッダを付与する', async () => {
    const fetchMock = vi.fn().mockResolvedValue(jsonResponse([]))
    vi.stubGlobal('fetch', fetchMock)

    const client = createApiClient({ baseUrl: 'http://api.test/api/v1', getToken: () => 'tok123' })
    await client.events.list()

    const init = fetchMock.mock.calls[0][1] as RequestInit
    const headers = init.headers as Headers
    expect(headers.get('Authorization')).toBe('Bearer tok123')
  })
})
