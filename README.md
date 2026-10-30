# 智伴 GS705B（智伴儿童机器人2）刷入小智 AI

把一台 2018 年的儿童机器人，改成能自然对话的 AI 音箱。**不拆机、不烧写固件、可一键回退。**

> 原理不是"刷固件"，而是**替换语音助手进程**：原厂固件完全不动（只读 squashfs），
> 小智跑在独立可写分区里，删掉一个文件就回原厂。

## 一、适用设备

| 项目 | 值 |
|---|---|
| 机型 | 智伴儿童机器人2（内部型号 **GS705B**） |
| 主控 | ACTIONS OWL / ATS3605，4×Cortex-A5 900MHz |
| 内存 / 存储 | 56MB RAM；NAND（SYSTEM 只读 + UPGRADE 9.8MB 可写） |
| 系统 | Linux 3.10.52（armv7l），uClibc，squashfs 根分区 |
| 屏幕 | 800×480 LCD，触摸上报 `KEY_HOME` |
| 音频 | 2 麦 + 1 参考通道，思必驰 AEC/唤醒（闭源 `libduilite_fespl.so`） |
| 网络 | RTL8189FS，仅 2.4G |

识别方法：底部标签 `CMIIT ID 2018DP9338`，`adb devices` 显示 `model:GS705B`。

## 二、能做到什么

| 能力 | 状态 |
|---|---|
| 语音唤醒 + 多轮对话（LLM） | ✅ |
| 屏幕字幕、表情联动 | ✅ |
| 音量/息屏/重启等语音控制（设备侧 MCP 工具） | ✅ |
| Web 管理面板（日志、音量、灯光、卸载） | ✅ |
| 远程唤醒、抓屏、配置热更新 | ✅ |
| 唤醒词改成「你好小智」 | ❌ 原生模型绑定「智伴智伴」，见 docs/04 |
| 一句话点歌（播放音频） | ❌ 设备侧无播放音频入口，只能 TTS 唱 |
| 换 UI 皮肤 | ❌ 闭源 launcher + 私有资源包，见 docs/04 |

## 三、原理（三句话）

1. 原厂 `/usr/bin/sair` 只是个"录音上传云端"的哑终端，ASR/TTS 全在云上。
2. `rcS` 把 `/var/upgrade` 加到 `PATH` 最前，所以 manager 启动 `sair` 时实际执行的是 `/var/upgrade/sair`。
3. 把开源项目 [moyu929/xiaozhi-zhiban](https://github.com/moyu929/xiaozhi-zhiban) 编译出的 `sair` 放进 `/var/upgrade`，就完成了替换——原厂固件一个字节没动。

## 四、快速开始

```bash
# 1) 确认通道（二选一）
adb devices                      # USB
curl http://<device-ip>:8080/api/system   # WiFi

# 2) 按顺序部署：先 xwebd，再 sair
adb push xwebd /var/upgrade/xwebd && adb shell chmod 755 /var/upgrade/xwebd
adb push sair  /var/upgrade/sair  && adb shell chmod 755 /var/upgrade/sair
adb shell reboot

# 3) 到 xiaozhi.me 绑定设备（激活码看面板），并关闭该设备的 OTA 升级
# 4) 唤醒词说「智伴智伴」
```

无 USB 时，用设备 8080 端口的 `/api/upload` 上传文件，见 [docs/02-部署步骤.md](docs/02-部署步骤.md)。

## 五、仓库结构

```
.
├── README.md
├── docs/
│   ├── 01-设备实测.md      硬件/分区/外设的实测数据
│   ├── 02-部署步骤.md      两条通道、部署顺序、验证、回退
│   ├── 03-运维与坑.md      日志轮转、会话超时、telnet 收敛、备份恢复
│   └── 04-走不通的路.md    换皮/唤醒词/二进制补丁的失败记录（省你时间）
├── scripts/
│   ├── test.sh             开机自启钩子（telnet 窗口 + xwebd + 轮转 + 看门狗）
│   ├── log_rotate.sh       日志轮转（copytruncate）
│   ├── boot_config.sh      开机回写易失配置
│   └── restore.sh          一键恢复（走 WiFi）
└── LICENSE
```

## 六、声明

- 本仓库**不包含任何固件二进制**。`sair` / `xwebd` 请从上游项目自行获取与编译，遵守其 MIT 许可。
- 文中不含设备 MAC、激活码、WiFi 凭据、API token。
- 改机有风险：刷坏需自行恢复；关键前置是**用只读 squashfs 保护原厂固件**，不要在 SYSTEM 分区写任何东西。

## 七、致谢

- [78/xiaozhi-esp32](https://github.com/78/xiaozhi-esp32) — 小智 AI 原始项目
- [moyu929/xiaozhi-zhiban](https://github.com/moyu929/xiaozhi-zhiban) — 本机型的移植版（MIT）
- [100askTeam/xiaozhi-linux](https://github.com/100askTeam/xiaozhi-linux) — Linux 平台参考

## 八、License

MIT，见 [LICENSE](LICENSE)。
