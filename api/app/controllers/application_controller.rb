class ApplicationController < ActionController::API
  # エラーレスポンスの形をアプリ側で明示的に統一する
  # （ミドルウェアの rescue_responses フォールバックによる Rails 汎用ボディを暗黙の API 契約にしない）。
  rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid
  rescue_from ActionController::ParameterMissing, with: :render_parameter_missing

  private

  # バリデーションエラー: events#create が自前で返す { errors: [...] } と同じ形式。
  def render_record_invalid(exception)
    render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  # 必須パラメータ不足: 404 系と同じ { error: "..." } 形式。
  def render_parameter_missing(exception)
    render json: { error: exception.message }, status: :bad_request
  end
end
