import { createApiClient } from '@bplus/api-client'

// ベース URL はリポジトリルートの .env（VITE_API_BASE_URL）から読み込む。
const baseUrl = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:3000/api/v1'

export const api = createApiClient({ baseUrl })
