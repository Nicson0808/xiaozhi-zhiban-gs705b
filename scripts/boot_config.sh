#!/bin/sh
# 开机后把可调参数写回 sair（这些项只存在 /tmp，重启会丢）
sleep 30
BODY='{"session_timeout":900000}'
LEN=${#BODY}
printf 'PUT /api/assistant/config HTTP/1.0\r\nHost: 127.0.0.1\r\nContent-Type: application/json\r\nContent-Length: %s\r\n\r\n%s' "$LEN" "$BODY" | nc 127.0.0.1 8080 > /tmp/boot_config.log 2>&1
