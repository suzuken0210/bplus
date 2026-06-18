# bplus Rails API 開発用 Dockerfile
# 本番用は api/Dockerfile（rails new 生成物）を別途使用する。
ARG RUBY_VERSION=3.4.9
FROM ruby:${RUBY_VERSION}-slim-bookworm

# Rails の実行に必要なパッケージ
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      libpq-dev \
      libyaml-dev \
      libffi-dev \
      zlib1g-dev \
      postgresql-client \
      git \
      curl && \
    rm -rf /var/lib/apt/lists/*

ENV LANG=C.UTF-8 \
    BUNDLE_PATH=/bundle \
    BUNDLE_BIN=/bundle/bin \
    GEM_HOME=/bundle \
    BOOTSNAP_CACHE_DIR=/bundle/bootsnap
ENV PATH="${BUNDLE_BIN}:${PATH}"

WORKDIR /app

# bundle install はコンテナ起動時にボリュームマウントされた Gemfile に対して実行する。
# （開発中の Gemfile 変更を即座に反映するため、ここでは COPY/bundle しない）
EXPOSE 3000
CMD ["bash"]
