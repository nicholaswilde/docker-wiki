FROM golang:1.16.5-alpine3.14 as build
ARG VERSION
ARG COMMIT
ENV GO111MODULE on
WORKDIR /go/src/github.com/prologic/wiki
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    git=2.32.0-r0 \
    make=4.3-r0 \
    build-base=0.5-r2 && \
  echo "**** download wiki ****" && \
  mkdir /app && \
  git clone "https://github.com/prologic/wiki.git" /go/src/github.com/prologic/wiki && \
  git reset --hard "${COMMIT}" && \
  go get -v -d && \
  go get -v github.com/GeertJohan/go.rice/rice && \
  go install -v && \
  go build . && \
  echo "**** cleanup ****" && \
  rm -rf \
    ./*.md \
    .github \
    screenshots

FROM ghcr.io/linuxserver/baseimage-alpine:3.14
ARG BUILD_DATE
ARG VERSION
ENV GOPATH /go
# hadolint ignore=DL3048
LABEL build_version="Version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="nicholaswilde"
COPY --from=build --chown=abc:abc /go /go
COPY root/ /
RUN \
  mkdir /data && \
  chown -R abc:abc \
    /data \
    /go
WORKDIR /go/bin
EXPOSE 8000/tcp
VOLUME \
  /data
