---
title: 查询linux版本方法
categories:
  - 运维
  - 系统管理
tags:
  - linux
  - 发型版本
comments: false
abbrlink: 1addf0dc
date: 2015-11-29 11:54:33
---

1、查看/etc/redhat-release

` $ cat /etc/redhat-release `

2、查看rpm包版本

`$ rpm -q centos-release`

如果是redhat则执行rpm -q redhat-release

3、所有版本通用的lsb_release

``` shell

#lsb_release -a
LSB Version:	:base-4.0-amd64:base-4.0-noarch:core-4.0-amd64:core-4.0-noarch
Distributor ID:	CentOS
Description:	CentOS release 6.5 (Final)
Release:	6.5
Codename:	Final

```

4、使用uname-a
