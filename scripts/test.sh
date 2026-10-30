#!/bin/sh
# 小智·智伴 开机自启脚本

# telnet：开机后只开放 15 分钟（远程调试窗口），随后自动关闭
busybox telnetd -p 23 -l /bin/sh
( sleep 900; killall telnetd 2>/dev/null ) &

# xwebd 面板内核服务
if [ -x /var/upgrade/xwebd ]; then
    cd /var/upgrade && ./xwebd -d
fi

# 日志轮转守护
/var/upgrade/log_rotate.sh &

# 开机回写可调参数
/var/upgrade/boot_config.sh &

# 开机频率检测与自动回退
/var/upgrade/boot_watchdog.sh
