FROM ruby:2.4.2-alpine
ENV LANG ja_JP.UTF-8
ENV PAGER busybox less

RUN apk update && \
    apk upgrade && \
    apk add --update\
    bash \
    build-base \
    curl-dev \
    git \
    libxml2-dev \
    libxslt-dev \
    linux-headers \
    mysql-dev \
    openssh \
    ruby-dev \
    ruby-json \
    tzdata \
    yaml \
    yaml-dev \
    zlib-dev \
    curl

ENV BATS_VER 1.1.0
RUN curl -sL "https://github.com/bats-core/bats-core/archive/v${BATS_VER}.tar.gz" | tar zx -C /var/opt \
    && cd "/var/opt/bats-core-${BATS_VER}/" && ./install.sh /usr/local \
    && rm -rf "/var/opt/bats-core-${BATS_VER}/"

ENV BC_DIR /bucky-core/
WORKDIR $BC_DIR
COPY . $BC_DIR

RUN \
  gem install bundler -v 1.17.3 && \
  echo 'gem: --no-document' >> ~/.gemrc && \
  cp ~/.gemrc /etc/gemrc && \
  chmod uog+r /etc/gemrc && \
  bundle config --global build.nokogiri --use-system-libraries && \
  bundle config --global jobs 4 && \
  bundle install && \
  rm -rf ~/.gem

WORKDIR /app
