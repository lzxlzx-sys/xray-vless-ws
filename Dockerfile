# Official xray image is distroless (no shell), so pull the binary out of it
# in a stage of its own and drop it into alpine, giving us a shell + CMD.
FROM ghcr.io/xtls/xray-core:25.9.11 AS xray

FROM alpine:3.20

RUN apk add --no-cache ca-certificates tzdata

COPY --from=xray /usr/local/bin/xray /usr/local/bin/xray
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/xray /usr/local/bin/entrypoint.sh

ENV XRAY_PORT=3000 \
    XRAY_WS_PATH=/xray

EXPOSE 3000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
