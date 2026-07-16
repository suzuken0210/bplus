import { ApiError } from '@bplus/api-client'

export function errorMessage(e: unknown): string {
  return e instanceof ApiError
    ? `API エラー: ${e.status}`
    : '通信に失敗しました（API サーバーが起動しているか確認してください）'
}

export function formatDate(iso: string): string {
  return new Date(iso).toLocaleString('ja-JP')
}

// ISO 8601（UTC）を datetime-local 入力欄用のローカル時刻文字列（YYYY-MM-DDTHH:mm）へ変換する。
// 編集フォームの初期値セットに使う。
export function toDatetimeLocal(iso: string): string {
  const d = new Date(iso)
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`
}
