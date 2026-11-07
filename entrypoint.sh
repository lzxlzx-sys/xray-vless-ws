#!/bin/sh
set -e

UUID="${XRAY_UUID:-}"
if [ -z "$UUID" ]; then
  echo "XRAY_UUID is not set; refusing to start so the client link stays stable." >&2
  exit 1
fi

WS_PATH="${XRAY_WS_PATH:-/xray}"
case "$WS_PATH" in
  /*) ;;
  *) WS_PATH="/$WS_PATH" ;;
esac

mkdir -p /etc/xray

cat > /etc/xray/config.json <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "listen": "0.0.0.0",
      "port": ${XRAY_PORT},
      "protocol": "vless",
      "settings": {
        "clients": [{ "id": "${UUID}" }],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": { "path": "${WS_PATH}" }
      }
    }
  ],
  "outbounds": [
    { "protocol": "freedom", "tag": "direct" }
  ]
}
EOF

echo "UUID=${UUID}"
echo "WS_PATH=${WS_PATH}"
echo "PORT=${XRAY_PORT}"

exec xray run -config /etc/xray/config.json
