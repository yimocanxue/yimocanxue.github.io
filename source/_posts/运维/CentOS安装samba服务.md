---
title: CentOS安装samba服务
tags: samba
categories:
  - 运维
  - 系统管理
abbrlink: 294fe70
date: 2015-11-28 11:21:44
---


检查是否有安装samba服务：

`$ rpm -qa | grep samba`

如果没安装则yum安装

`$ yum -y install samba samba-client samba-common`

默认的安装目录是/etc/samba，配置文件为smb.conf,先备份下smb文件
`$ cd /etc/samba`
`$ cp smb.conf smb.conf.bak`

然后编辑smb.conf加入以下内容：

```
[remote_dev]
        path = /alidata/nginx_www/wx.soopj.com
        public =no
        writable = yes
        write list = @www
        valid users = @www
```

@www是客户端登录所需要的用户，设置nginx的用户密码：

`$ smbpasswd -a www`

为了避免在启动Samba时出现以下警告信息：rlimit_max: increasing rlimit_max (1024) tominimum Windows limit (16384)，
配置内核参数

```

$ ulimit -n 16384
$ vi /etc/security/limits.conf
#在最后加入以下内容
* - nofile 16384

```


然后运行testparm检测配置文件。

然后启动服务，关闭防火墙：

```
$ service smb start
$ service nmb start
$ service iptables stop

```
centos7后启动服务由systemctl管理，防火墙换成firewalld，因此命令稍有不同。然后客户端即可测试。
