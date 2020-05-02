# Copyright (C) 2018 Betalo AB - All Rights Reserved

FROM golang:1.14 as builder

LABEL maintainer="Betalo Backend Team <backend-team@betalo.se>"

RUN mkdir /build
WORKDIR /build
ADD . .
ENV CGO_ENABLED=0
RUN go build

FROM alpine


RUN mkdir /app
WORKDIR /app
COPY --from=builder /build/forwardingproxy .
RUN chown -R 1001:0 . && chmod -R 550 /app
RUN apk add --update-cache libcap && \
    setcap 'cap_net_bind_service=+ep' ./forwardingproxy && \
    apk del libcap && \
    rm -rf /var/cache/apk/*
USER 1001

EXPOSE 80 443

ENTRYPOINT ["/app/forwardingproxy"]
