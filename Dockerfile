# Build stage
FROM golang:1.10.3-alpine3.8 AS builder

WORKDIR /go/src/github.com/stellar/go

RUN apk add --update --no-cache curl git mercurial

ARG GOOS=linux
ARG GOARCH=amd64
ARG CGO_ENABLED=0

ARG GLIDE_VERSION=0.13.1
ARG GLIDE_SHA256SUM=c403933503ea40308ecfadcff581ff0dc3190c57958808bb9eed016f13f6f32c

COPY scripts/install_glide.sh /tmp/

RUN /tmp/install_glide.sh

ARG BRIDGE_VERSOIN=0.0.31
ARG BRIDGE_GIT_REVISION=ebab9eefa5a3e3c7be62548fe82317caf70d8df1

RUN git clone https://github.com/stellar/go.git . \
  && git checkout ${BRIDGE_GIT_REVISION}
RUN glide --debug install
RUN go install -ldflags "-X main.version=$GLIDE_VERSION" github.com/stellar/go/services/bridge

# Release stage
FROM alpine:3.8

LABEL maintainer="Mobius Operations Team <ops@mobius.network>"

COPY --from=builder /go/bin/bridge /usr/local/bin/bridge
COPY --from=builder /go/src/github.com/stellar/go/services/bridge/bridge_example.cfg /etc/bridge_example.cfg
COPY scripts/init_db.sh /usr/local/bin/bridge_init_db.sh
COPY scripts/entrypoint.sh /entrypoint.sh

RUN apk add --no-cache postgresql-client ca-certificates \
  && update-ca-certificate || true

USER nobody

WORKDIR /tmp

ENV BRIDGE_CONFIG_FILE=/etc/bridge.cfg
ENV BRIDGE_SKIP_DB_INIT=false

ENTRYPOINT ["/entrypoint.sh"]
