# EasyTier IPv4 出口路由

`easytier-route.sh` 给 EasyTier 的底层连接指定直连网关，避免 P2P 和 STUN
随系统默认路由绕行。依赖 Linux、Bash、iproute2、awk，不依赖 Python、jq、
systemd 或特定的服务管理器。默认网关不会自动猜测，因为它正是需要绕开的路径。

选择顺序：本地地址 → main 表的非默认路由 → 专用表的直连默认路由。
已有的局域网路由和目的地静态路由仍优先生效。其他未带标记的流量保持原有选路。
优先级数值更小的已有策略规则仍可能先命中，部署时用 `ip -4 rule show` 检查。

## 使用

在 **easytier-core 所在的网络命名空间**运行，不是在 `ns-alt` 内运行。
以下例子适用于 ubuntu-dev；其他机器替换网关即可，网卡默认自动检测。

```bash
bash scripts/easytier-route.sh apply --gateway 192.168.3.1 --dry-run
sudo bash scripts/easytier-route.sh apply --gateway 192.168.3.1
bash scripts/easytier-route.sh status
```

在 `/etc/easytier.toml` 已有的 `[flags]` 段增加以下一行，然后用当前服务管理器
重启 EasyTier，让 STUN 和 P2P 连接重新建立。脚本仅管理路由，不编辑密钥配置、
不自动重启服务。

```toml
socket_mark = 109
```

ubuntu-dev 当前由 Supervisor 管理，可以执行 `sudo supervisorctl restart easytier`。
这是当前版本支持的设置；其他机器先用 `easytier-core --help` 确认存在
`--socket-mark`。进程需要设置 SO_MARK 的权限，常规 root 服务已具备。

```bash
ip -4 route get 113.99.99.3 mark 109
easytier-cli node
easytier-cli peer
```

第一条应显示直连网关，节点公网地址也应来自预期出口。脚本不配置 IPv6；
使用 IPv6 底层连接时，应另外配置对应的 IPv6 策略路由。

## 参数、重复执行与撤销

```bash
# 网关在多张网卡上可达时，明确指定网卡。
sudo bash scripts/easytier-route.sh apply --gateway 192.168.3.1 --dev ens18 \
  --mark 109 --table 109 --priority 9000

# 使用与 apply 相同的网关、标记、表号和优先级撤销。
sudo bash scripts/easytier-route.sh remove --gateway 192.168.3.1
```

默认使用表 109、标记 109，以及规则优先级 9000/9001；请专用于此用途。
`--mark` 支持十进制或十六进制，并且必须与 EasyTier 的 `socket_mark` 一致。
表号和优先级可按机器调整，不会写入 `/etc/iproute2/rt_tables`。

重复 apply 不增加路由或规则，并会将同一优先级上的完全相同规则去重；
重复 remove 也能成功。脚本在任何写操作前检查两个优先级和整个专用表，
发现不同规则、不同路由或其他规则引用此表时退出，不清空其他配置。
改网关或网卡前先用旧参数 remove，再用新参数 apply。不要并发运行脚本。
执行中断后的部分配置可以用同样参数再次 apply 修复。

## 开机恢复

这些是运行时路由。将脚本放到稳定路径，在网络已配置完成后、EasyTier 启动前，
从现有启动机制调用同一条 apply 命令即可。网络重连后也可重新执行。
systemd 系统可用如下 oneshot 单元；按实际安装路径和网关修改：

```ini
[Unit]
Description=EasyTier IPv4 routing
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/env bash /usr/local/sbin/easytier-route.sh apply --gateway 192.168.3.1
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

另在实际管理 EasyTier 的服务中设置对该单元的依赖和启动顺序；例如由 Supervisor
统一启动时，把路由配置安排在 Supervisor 启动前。脚本不假定服务名称或修改默认路由。
同局域网的节点仍建议配置 LAN listener/peer，使 EasyTier 直接连接局域网地址。

参考：[ip-rule](https://man7.org/linux/man-pages/man8/ip-rule.8.html)、
[EasyTier socket_mark 配置](https://github.com/EasyTier/EasyTier/blob/8b7f1f01/easytier/src/core.rs#L523)。
