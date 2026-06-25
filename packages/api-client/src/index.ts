// bplus API クライアント
// Rails API（/api/v1 配下）への型付きアクセスを提供する。
// Web/将来の RN から共通利用するため、fetch のみに依存する。

import type { CreateEventInput, Event, Paginated, Ticket, User } from '@bplus/types'

export interface ApiClientOptions {
  /** API のベース URL（例: http://localhost:3000/api/v1）。 */
  baseUrl: string
  /** 認証トークンを返す関数（任意）。設定すると Authorization ヘッダに付与する。 */
  getToken?: () => string | null | undefined
}

/** API がエラー応答（非 2xx）を返したときに throw される。 */
export class ApiError extends Error {
  readonly status: number
  readonly body?: unknown

  constructor(status: number, message: string, body?: unknown) {
    super(message)
    this.name = 'ApiError'
    this.status = status
    this.body = body
  }
}

export function createApiClient(options: ApiClientOptions) {
  const { baseUrl, getToken } = options

  async function request<T>(path: string, init?: RequestInit): Promise<T> {
    const headers = new Headers(init?.headers)
    headers.set('Accept', 'application/json')
    if (init?.body) headers.set('Content-Type', 'application/json')
    const token = getToken?.()
    if (token) headers.set('Authorization', `Bearer ${token}`)

    const res = await fetch(`${baseUrl}${path}`, { ...init, headers })
    const text = await res.text()
    const data: unknown = text ? JSON.parse(text) : undefined
    if (!res.ok) {
      throw new ApiError(res.status, `API ${res.status} ${res.statusText}`, data)
    }
    return data as T
  }

  return {
    /** 任意パスへの低レベルリクエスト。 */
    request,
    /** ヘルスチェック（GET /api/v1/ping を想定。Step2 で実装予定）。 */
    ping: () => request<{ status: string }>('/ping'),
    /** ログイン中ユーザー。 */
    me: () => request<User>('/me'),
    events: {
      /** イベント一覧（作成順）。 */
      list: () => request<Event[]>('/events'),
      /** イベントを1件追加する。 */
      create: (input: CreateEventInput) =>
        request<Event>('/events', {
          method: 'POST',
          body: JSON.stringify({ event: input }),
        }),
    },
    tickets: {
      listByUser: (userId: string) => request<Paginated<Ticket>>(`/users/${userId}/tickets`),
    },
  }
}

export type ApiClient = ReturnType<typeof createApiClient>
