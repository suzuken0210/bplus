module Api
  module V1
    class EventsController < ApplicationController
      # GET /api/v1/events
      # 有効なイベントを作成順（古い順）に返す。
      def index
        events = Event.kept.order(created_at: :asc)
        render json: events.map { |event| serialize(event) }
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
