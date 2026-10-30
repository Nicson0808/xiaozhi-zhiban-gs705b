#!/bin/sh
# 日志轮转：sair 以 O_APPEND 打开日志，可用 copytruncate 安全裁剪
LOG=/var/upgrade/xiaozhi.log
MAX=524288
KEEP=204800

while true; do
    sleep 600
    [ -f "$LOG" ] || continue
    sz=$(wc -c < "$LOG" 2>/dev/null)
    [ -z "$sz" ] && continue
    if [ "$sz" -gt "$MAX" ]; then
        tail -c $KEEP "$LOG" > /tmp/.logtail 2>/dev/null
        cat /tmp/.logtail > "$LOG" 2>/dev/null
        rm -f /tmp/.logtail
        echo "[rotate] $(date) size=$sz -> $KEEP" >> /tmp/rotate.log
    fi
done
