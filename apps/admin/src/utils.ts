import { ApiError } from '@bplus/api-client'

export function errorMessage(e: unknown): string {
  return e instanceof ApiError
    ? `API エラー: ${e.status}`
    : '通信に失敗しました（API サーバーが起動しているか確認してください）'
}

export function formatDate(iso: string): string {
  return new Date(iso).toLocaleString('ja-JP')
}
