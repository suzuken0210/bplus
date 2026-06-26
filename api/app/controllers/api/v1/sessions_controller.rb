module Api
  module V1
    class SessionsController < ApplicationController
      # POST /api/v1/login
      # モック認証: name が一致する有効なユーザーを返す（PoC のためパスワード等は無し）。
      def create
        user = User.kept.find_by(name: params[:name].to_s)
        if user
          render json: { id: user.id, name: user.name }
        else
          render json: { error: "該当するユーザーが見つかりません" }, status: :not_found
        end
      end
    end
  end
end
