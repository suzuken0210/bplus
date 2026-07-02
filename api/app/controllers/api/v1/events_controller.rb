module Api
  module V1
    class EventsController < ApplicationController
      # GET /api/v1/events
      # 有効なイベントを作成順（古い順）に返す。
      def index
        events = Event.kept.order(created_at: :asc)
        render json: events.map { |event| serialize(event) }
      end

      # GET /api/v1/events/:id
      # イベント1件と、そのイベントに参加中（有効）のユーザー一覧を返す。
      def show
        event = Event.kept.find_by(id: params[:id])
        return render json: { error: "イベントが見つかりません" }, status: :not_found unless event

        participants = User.kept
          .joins(:user_join_events)
          .where(user_join_events: { event_id: event.id, discarded_at: nil })
          .order("users.created_at ASC")

        render json: serialize(event).merge(
          participants: participants.map { |user| { id: user.id, name: user.name } }
        )
      end

      # POST /api/v1/events
      # event_name を受け取りイベントを1件追加する。
      def create
        event = Event.new(event_params)
        if event.save
          render json: serialize(event), status: :created
        else
          render json: { errors: event.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def event_params
        params.require(:event).permit(:event_name)
      end

      def serialize(event)
        {
          id: event.id,
          event_name: event.event_name,
          created_at: event.created_at.iso8601,
          updated_at: event.updated_at.iso8601,
          discarded_at: event.discarded_at&.iso8601
        }
      end
    end
  end
end
