---
title: gitlab系列教程之1-安装
date: 2017-07-07 19:11:16
tags: 
	- gitlab
	- 安装
	- docker
categories:
	- 运维
	- devops
---


# 一、安装gitlabe

### 1.1、安装docker

安装环境为`centos_7.0 3.10.0-327.10.1.el7.x86_64`，参考链接https://docs.docker.com/engine/installation/linux/centos/#install-docker。安装方式有两种，一种是通过yum安装，另外一种是下载RPM包手动安装，这里采用第一种方式。

这里以安装docker-ce stable为例，docker-ee安装类似，可以参照上面的链接。

##### 1.1.1 设置yum repository

安装yum-utils，它提供yum-config-manager这个工具包：

```shell
$ sudo yum install -y yum-utils

```
添加docker资源库：

```js
$ sudo yum-config-manager \
	--add-repo \
	https://download.docker.com/linux/centos/docker-ce.repo
```
![](http://xuh.cn-etc.com/2017/04/15/1492271229468.png!md)


如果需要安装edage版，则执行下面的命令启用其repository：

```
$ sudo yum-config-manager --enable docker-ce-edage

```

###### 1.1.2 安装

更新yum的安装包索引：

```
$ sudo yum makecache fast

```
安装最新版的docker:

```
$ sudo yum install docker-ce

```
输入docker version输出类似下面的内容则表示安装成功。

![](http://xuh.cn-etc.com/2017/04/16/1492272094596.png!md)

启动docker服务

```
$ sudo systemctl start docker.service

```


##### 1.1.3 安装docker-compose

因为一个完整的gitlab应用包含gitlab容器、redis、postgresql等服务，每个服务都启动一个docker实例，那么gitlab的管理就会很麻烦，docker-compose就是这么一个管理多容器应用的神器，它基于一个yml配置文件搞定依赖服务之前的管理。

由于docker-compose依赖Python-pip，因此先安装它：

```
$ sudo yum install -y python-pip

```

对安装的pip进行升级：

```
$ sudo pip install --upgrade pip

```

利用pip安装docker-compose

```
$ sudo pip install docker-compose

```
安装后查看版本如下：

![](http://xuh.cn-etc.com/2017/04/16/1492273456118.png!md)


### 1.2、安装gitlab

gitlab依赖redis、postgresql、其中redis提供缓存服务，postgresql负责持久化数据存储(当然也可以是MySQL)，因此需要开启三个容器，大致步骤如下。

启动postgresql容器

```
$ docker run --name gitlab-postgresql -d \
    --env 'DB_NAME=gitlabhq_production' \
    --env 'DB_USER=gitlab' --env 'DB_PASS=password' \
    --volume /srv/docker/gitlab/postgresql:/var/lib/postgresql \
    sameersbn/postgresql:9.4-12
    
```

启动redis容器   
 
```
docker run --name gitlab-redis -d \
    --volume /srv/docker/gitlab/redis:/var/lib/redis \
    sameersbn/redis:latest
    
```

然后再启动gitlab容器，然后通过--link连接redis和postgresql容器

```
docker run --name gitlab -d \
    --link gitlab-postgresql:postgresql --link gitlab-redis:redisio \
    --publish 10022:22 --publish 10080:80 \
    --env 'GITLAB_PORT=10080' --env 'GITLAB_SSH_PORT=10022' \
    --env 'GITLAB_SECRETS_DB_KEY_BASE=long-and-random-alpha-numeric-string' \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:8.4.4
    
``` 

这样相当复杂，因此我们可以把这些启动配置写到一个yml文件里面去，让docker-compose帮我们来管理这些容器，而这些容器之间的compose配置，已经有大牛贡献出来了（[点击这里查看](https://github.com/sameersbn/docker-gitlab)）。

因此我们这里把它的配置文件下载下来

```
$ wget https://raw.githubusercontent.com/sameersbn/docker-gitlab/master/docker-compose.yml

```

然后修改里面的配置项（见下节），然后一条命令即可启动gitlab服务

```
$ docker-compose up

```

不过出现如下错误：

```
docker: Error response from daemon: mkdir /data/docker/mnt/overlay/e37098a0043c2bd200b919c4cd466a1cfe98a03865b08be82efa215e32e92196-init/merged/dev/shm: invalid argument.

```

查了很久，找到两篇帖子（[看这里](https://github.com/docker/docker/issues/22937),[还有这里](https://github.com/docker/docker/issues/5122)），说啥的都有，不过隐约觉得应该是内核版本问题（[最新内核版本](https://www.kernel.org/)），具体内核升级参照[这里](https://baijiahao.baidu.com/po/feed/share?wfr=spider&for=pc&context=%7B%22sourceFrom%22%3A%22bjh%22%2C%22nid%22%3A%22news_3323164689172649603%22%7D)。

果然，升级内核后不再报错了。

### 1.3、配置gitlab

这里只列出有配置改动的部分：

```
version: '2'

services:
  redis:
    restart: always
    image: sameersbn/redis:latest
    command:
    - --loglevel warning
    volumes:
    - /server/docker/gitlab/redis:/var/lib/redis:Z

  postgresql:
    restart: always
    image: sameersbn/postgresql:9.6-2
    volumes:
    - /server/docker/gitlab/postgresql:/var/lib/postgresql:Z
    environment:
    # postgsql的账户设置
    - DB_USER=gitlab
    - DB_PASS=8uf0s3cxdf
    - DB_NAME=gitlabhq_production
    - DB_EXTENSION=pg_trgm

  gitlab:
    restart: always
    image: sameersbn/gitlab:9.0.5
    depends_on:
    - redis
    - postgresql
    ports:
    # 把容器内nginx的80端口隐射到宿主机的10080端口上
    - "10080:80"
    # 把容器内ssh的22号端口映射到宿主机的10022端口上
    - "10022:22"
    volumes:
    # 通过数据卷把gitlab的数据挂载到/server/docker/gitlab/gitlab目录下，这样容器重启后数据就不会丢失了
    - /server/docker/gitlab/gitlab:/home/git/data:Z
    environment:
    - DEBUG=false

    - DB_ADAPTER=postgresql
    - DB_HOST=postgresql
    - DB_PORT=5432
    - DB_USER=gitlab
    - DB_PASS=8uf0s3cxdf
    - DB_NAME=gitlabhq_production

    - REDIS_HOST=redis
    - REDIS_PORT=6379

    # 修改时区
    - TZ=Asia/Shanghai
    - GITLAB_TIMEZONE=Beijing

    - GITLAB_HTTPS=false
    - SSL_SELF_SIGNED=false

	 # 发布gitlab应用的主机名称 
    - GITLAB_HOST=gitlab.cn-etc.com
    - GITLAB_PORT=10080
    - GITLAB_SSH_PORT=10022
    - GITLAB_RELATIVE_URL_ROOT=
    - GITLAB_SECRETS_DB_KEY_BASE=long-and-random-alphanumeric-string
    - GITLAB_SECRETS_SECRET_KEY_BASE=long-and-random-alphanumeric-string
    - GITLAB_SECRETS_OTP_KEY_BASE=long-and-random-alphanumeric-string

    - GITLAB_ROOT_PASSWORD=cnetc123
    - GITLAB_ROOT_EMAIL=gitlab@cn-etc.com

    - GITLAB_NOTIFY_ON_BROKEN_BUILDS=true
    - GITLAB_NOTIFY_PUSHER=false

    - GITLAB_EMAIL=gitlab@cn-etc.com
    - GITLAB_EMAIL_REPLY_TO=gitlab@cn-etc.com
    - GITLAB_INCOMING_EMAIL_ADDRESS=gitlab@cn-etc.com
    # 发送邮件时的显示名称
    - GITLAB_EMAIL_DISPLAY_NAME=Gitlab系统

    - GITLAB_BACKUP_SCHEDULE=daily
    - GITLAB_BACKUP_TIME=01:00

    # SMTP配置
    - SMTP_ENABLED=true
    - SMTP_DOMAIN=smtp.exmail.qq.com
    - SMTP_HOST=smtp.exmail.qq.com
    - SMTP_PORT=465
    - SMTP_USER=gitlab@cn-etc.com
    - SMTP_PASS=Gitlab123
    - SMTP_STARTTLS=true
    - SMTP_AUTHENTICATION=login

```

重新启动

```
$ docker-compose up

```

至此，gitlab安装完成，登录http://gitlab.cn-etc.com:10080 去注册用户新建group、project开干。



# 二、持续集成(CI/CD)

### 2.1 继续集成介绍

为了更好的理解gitlab持续集成的配置和管理，有必要详细理顺与持续集成相关概念，这里单独另开了一篇来说明这些概念，[点击这里查看](./持续集成介绍.md)。

### 2.1 安装gitlab-runner

runner就是一个用来跑集成任务的特殊进程，可以和gitlab在同一台服务器，也可以安装在其它服务器上。

添加gitlab-runner资源库

```
$ curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-ci-multi-runner/script.rpm.sh | sudo bash

```

然后安装

```
$ sudo yum install -y gitlab-ci-multi-runner

```




   
   


	

