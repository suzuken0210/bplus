// bplus 共有ドメイン型
// 管理画面(apps/admin)・参加者(apps/participant)・将来の RN アプリから再利用する。

/** ユーザーの役割。 */
export type UserRole = 'admin' | 'organizer' | 'member';

/** ユーザー（社員）。 */
export interface User {
  id: string;
  email: string;
  name: string;
  role: UserRole;
  /** 作成日時（ISO 8601）。 */
  createdAt: string;
}

/** 社内イベント（events テーブルに対応）。 */
export interface Event {
  id: string;
  /** イベント名。 */
  event_name: string;
  /** 作成日時（ISO 8601）。 */
  created_at: string;
  /** 更新日時（ISO 8601）。 */
  updated_at: string;
  /** 論理削除日時（ISO 8601）。未削除なら null。 */
  discarded_at: string | null;
}

/** イベント作成の入力。 */
export interface CreateEventInput {
  event_name: string;
}

/** 電子チケットの状態。 */
export type TicketStatus = 'issued' | 'used' | 'revoked';

/** 電子チケット（イベント参加証）。 */
export interface Ticket {
  id: string;
  eventId: string;
  userId: string;
  status: TicketStatus;
  /** チケット識別コード（QR 等の元データ）。 */
  code: string;
  /** 発行日時（ISO 8601）。 */
  issuedAt: string;
  /** 使用（来場）日時（ISO 8601）。 */
  usedAt?: string;
}

/** ページング付き一覧レスポンスの共通形。 */
export interface Paginated<T> {
  items: T[];
  total: number;
  page: number;
  perPage: number;
}
