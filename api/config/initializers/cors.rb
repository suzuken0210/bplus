# Be sure to restart your server when you modify this file.
#
# フロント（管理画面 / 参加者）からのクロスオリジンリクエストを許可する。
# 開発: Vite の admin(5173) / participant(5174)。本番のオリジンは別途追加する。
#
# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "http://localhost:5173", "http://localhost:5174"

    resource "/api/*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ]
  end
end
