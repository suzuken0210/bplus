module Api
  module V1
    class ParticipationsController < ApplicationController
      # GET /api/v1/users/:user_id/participations
      # そのユーザーが参加中（有効）のイベント参加を返す。イベント自体が論理削除済みのものは除く。
      def index
        participations = UserJoinEvent.kept.where(user_id: params[:user_id]).joins(:event).merge(Event.kept)
        render json: participations.map { |p| { event_id: p.event_id } }
      end

      # POST /api/v1/events/:event_id/participation
      # ユーザーをイベントに参加させる。取り消し済みなら復活、無ければ作成（冪等）。
      def create
        user_id = params[:user_id]
        event_id = params[:event_id]

        # 有効なイベントのみ参加可能（events#show と挙動を揃える）。
        unless Event.kept.exists?(id: event_id)
          return render json: { error: "イベントが見つかりません" }, status: :not_found
        end

        active = UserJoinEvent.kept.find_by(user_id: user_id, event_id: event_id)
        return render json: { event_id: active.event_id }, status: :ok if active

        # 取り消し済みの行があれば復活、無ければ新規作成。
        participation = UserJoinEvent
          .where(user_id: user_id, event_id: event_id)
          .order(created_at: :desc)
          .first_or_initialize
        participation.discarded_at = nil
        participation.save!
        render json: { event_id: participation.event_id }, status: :created
      end

      # DELETE /api/v1/events/:event_id/participation
      # 参加を取り消す（論理削除）。冪等。
      def destroy
        participation = UserJoinEvent.kept.find_by(
          user_id: params[:user_id],
          event_id: params[:event_id]
        )
        participation&.update!(discarded_at: Time.current)
        head :no_content
      end
    end
  end
end
