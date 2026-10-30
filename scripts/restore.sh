#!/bin/sh
# 智伴 GS705B 小智环境一键恢复（走 WiFi，无需 USB 数据线）
# 用法: sh restore.sh [设备IP]     默认 192.168.1.100，请改成你的设备 IP
set -e
HOST=${1:-"192.168.1.100"}
DIR=$(cd "$(dirname "$0")" && pwd)

echo "== 目标设备: $HOST =="
for f in sair xwebd test.sh log_rotate.sh boot_watchdog.sh watchdog_guard.sh use_limit_exhausted.mp3; do
    printf "%-28s" "$f"
    curl -s --max-time 60 -X POST \
        -H "Content-Type: application/octet-stream" \
        -H "X-Filename: $f" \
        --data-binary @"$DIR/$f" \
        "http://$HOST:8080/api/upload"
    echo
done

echo "== 恢复 MCP 接入点 =="
TOK=$(cat "$DIR/mcp_endpoint.txt")
curl -s --max-time 10 -X PUT -H "Content-Type: application/json" \
    --data-binary "{\"mcp_endpoint\":\"$TOK\"}" \
    "http://$HOST:8080/api/assistant/config"
echo

echo "== 重启设备 =="
curl -s --max-time 5 -X POST -H "Content-Length: 0" "http://$HOST:8080/api/reboot" || true
echo
echo "完成。等 60 秒后访问 http://$HOST:8080/api/assistant/status 确认 running=true"
