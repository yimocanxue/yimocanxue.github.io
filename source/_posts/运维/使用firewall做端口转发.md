---
title: 使用centos7 firewall-cmd做端口转发
tags:
  - centos
  - 端口转发
  - firewall
categories:
  - 运维
  - 系统管理
abbrlink: a395cd40
date: 2017-12-27 15:27:41
---

可以做端口转发的工具有很多，centos7以前的防火墙软件iptables就是其中之一，但是因为使用复杂，centos7以后被firewall代替了，下面就简单看看怎么用它来做端口转发。

### 开通伪IP

```shell
$ firewall-cmd --query-masquerade
# 如果没有开通，则开通
$ firewall-cmd --add-masquerade --permanent
$ firewall-cmd --reload
```

### 设置端口转发

```shell
$ firewall-cmd --add-forward-port=port=<开放的本地端口>:proto=tcp:toaddr=<目的主机IP>:toport=<目的主机端口> --permanent
$ systecmctl restart firewalld.service

```

OK,就是这么简单
