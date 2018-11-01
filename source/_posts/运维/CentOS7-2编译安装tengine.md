---
title: CentOS7.2编译安装tengine
cetegories:
  - 运维
  - LA/NMP服务
tags:
  - tengine
  - nginx lua扩展
abbrlink: f110b008
date: 2017-11-30 13:54:33
---

# Tengine介绍

Tengine是有淘宝网发起的web服务器项目。它在Nginx的基础上，针对大访问量网站的需求，添加了很多高级功能和特性。它的最终目标是打造一个高效、稳定、安全、已用的web平台。

### 特性

Tengine在Nginx的基础上作了很多改进，但是促使我弃Nginx转投它的原因是动态模块加载支持和多个请求报文重组（多个请求变成一个请求，比如多个css、js文件的访问）。

下面是官方列举的一些特性：

- 继承Nginx-1.8.1的所有特性，兼容Nginx的配置（最新v2.2.1）；
- 动态模块加载（DSO）支持。加入一个模块不再需要重新编译整个Tengine；
- 支持HTTP/2协议，HTTP/2模块替代SPDY模块；
- 流式上传到HTTP后端服务器或FastCGI服务器，大量减少机器的I/O压力；
- 更加强大的负载均衡能力，包括一致性hash模块、会话保持模块，还可以对后端的服务器进行主动健康检查，根据服务器状态自动上线下线，以及动态解析upstream中出现的域名；
- 输入过滤器机制支持。通过使用这种机制Web应用防火墙的编写更为方便；
- 支持设置proxy、memcached、fastcgi、scgi、uwsgi在后端失败时的重试次数
- 动态脚本语言Lua支持。扩展功能非常高效简单；
- 支持按指定关键字(域名，url等)收集Tengine运行状态；
- 组合多个CSS、JavaScript文件的访问请求变成一个请求；
- 自动去除空白字符和注释从而减小页面的体积
- 自动根据CPU数目设置进程个数和绑定CPU亲缘性；
- 监控系统的负载和资源占用从而对系统进行保护；
- 显示对运维人员更友好的出错信息，便于定位出错机器；
- 更强大的防攻击（访问速度限制）模块；
- 更方便的命令行参数，如列出编译的模块列表、支持的指令等；
- 可以根据访问文件类型设置过期时间；


# 安装

### 准备编译环境

```
$ yum update
$ yum install gcc gcc-c++ autoconf automake

```

### 安装所需组件

##### 安装PCRE库

PCRE(Perl Compatible Regular Expressions)是一个Perl库，包括 perl 兼容的正则表达式库。nginx rewrite模块处理正则正是依赖于PCRE库。

```
$ cd /usr/local/src
$ wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.40.tar.gz
$ tar xf pcre-8.40.tar.gz
$ cd pcre-8.40
$ ./configure --prefix=/usr/local/pcre
$ make && make install

```

##### 安装OpenSSL

OpenSSL是一个功能强大的安全套接字层密码库，囊括主要的密码算法、常用的秘钥和证书封装管理功能及SSL协议，并提供丰富的应用程序供测试或其它目的使用。Nginx处理https请求的http_ssl_module模块依赖OpenSSL库。

```
$ mv `which openssl` `which openssl`bak # 可选，备份本机已安装的旧openssl
$ cd /usr/local/src
$ wget http://www.openssl.org/source/openssl-1.0.2.tar.gz
$ tar xf openssl-1.0.2.tar.gz
$ cd openssl-1.0.2
$ ./config --prefix=/usr/local/openssl
$ make && make install
$ ln -s /usr/local/openssl/bin/openssl /usr/bin/openssl

```

##### 安装Zlib

Zlib是提供资料压缩的函数库，当nginx启动GZIP压缩时会依赖该库。

```
$ cd /usr/local/src
$ tar xf zlib-1.2.11.tar.gz
$ cd zlib-1.2.11
$ ./configure --prefix=/usr/local/zlib
$ make && make install

```

##### 安装jemalloc

jemalloc是一个更好的内存管理工具，使用jemalloc可以更好的优化Tengine的内存管理。

```
$ cd /usr/local/src
$ wget https://github.com/jemalloc/jemalloc/releases/download/5.0.1/jemalloc-5.0.1.tar.bz2
$ tar xf jemalloc-5.0.1.tar.bz2
$ cd jemalloc-5.0.1
$ ./configure --prefix=/usr/local/jemalloc
$ make && make install

```

##### 安装LuaJIT

LuaJIT(LuaJIT is a Just-In-Time Compilerfor the Lua programming languag)，它是Lua脚本的解释器，nginx可以通过lua扩展其功能，开启lua支持就需要LuaJIT。

```
$ cd /usr/local/src
$ wget http://luajit.org/download/LuaJIT-2.0.5.tar.gz
$ tar xf LuaJIT-2.0.5.tar.gz
$ make PREFIX=/usr/local/luajit
$ make install PREFIX=/usr/local/luajit
$ # 添加环境变量，告诉Nginx在哪里找LuaJIT执行lua脚本 
$ echo "export LUAJIT_LIB=/usr/local/luajit/lib" >> /etc/profile
$ echo "export LUAJIT_INC=/usr/local/luajit/include/luajit-2.0" >> /etc/profile
$ source /etc/profile

```

详情可以[参照这里](https://github.com/openresty/lua-nginx-module/blob/master/README.markdown#installation)。

### 下载lua模块

```
$ cd /usr/local/src
$ wget https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.tar.gz
$ wget https://github.com/openresty/lua-nginx-module/archive/v0.10.11.tar.gz
$ tar xf v0.3.0.tar.gz
$ tar xf v0.10.11.tar.gz

```

这里只需要下载解压到/usr/local/src目录下解压即可。

### 安装Tengine

Tengine和Nginx大多编译和配置选项均相同，Tengine特有的编译选项[参见这里](http://tengine.taobao.org/document_cn/install_cn.html)。

```
$ cd /usr/local/src
$ curl -O http://tengine.taobao.org/download/tengine-2.2.1.tar.gz
$ tar xf tengine-2.2.1.tar.gz
$ cd tengine-2.2.1
$ ./configure \
--prefix=/server/tengine \
--sbin-path=/server/tengine \
--conf-path=/server/tengine/conf/nginx.conf \
--user=www  \
--group=www \
--dso-path=/server/tengine/dso \
--with-http_concat_module \
--with-http_stub_status_module \
--with-http_ssl_module \
--with-http_gzip_static_module \
--with-http_realip_module \
--with-pcre=/usr/local/src/pcre-8.40  \
--with-zlib=/usr/local/src/zlib-1.2.11 \
--with-openssl=/usr/local/src/openssl-1.0.2 \
--with-jemalloc=/usr/local/src/jemalloc-5.0.1 \
--with-ld-opt="-Wl,-rpath,/usr/local/luajit/lib" \
--add-module=/usr/local/src/lua-nginx-module-0.10.11 \
--add-module=/usr/local/src/ngx_devel_kit-0.3.0

$ make && make install
$ ln -s /server/tengine/nginx /usr/bin/nginx # 可选

```

这里有几点需要注意：

- 运行Tengine的用户和组须先添加，这里省略了；
- pcre、zlib、openssl、jemalloc相关的编译选项需要指向的是安装源文件路径，不是安装该库是指定的prefix，这个一定要注意；
- ngx_devel_kit、lua-nginx-module两个模块编译选项只要需要指向解压路径，Tengine编译时会进入相应目录完成编译。

了解更多的编译选项参见[这里](http://nginx.org/en/docs/configure.html)、[这里](http://tengine.taobao.org/documentation_cn.html)、[还有这里](http://www.nginx.cn/doc/index.html)。

### 配置Tengine服务，设置开机启动


##### 创建nginx.service

```
$ vim /lib/systemd/system/nginx.service

[Unit]
Description=The nginx HTTP and reverse proxy server
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/server/tengine/logs/nginx.pid
ExecStartPre=/server/tengine/nginx -t
ExecStart=/server/tengine/nginx -c /server/tengine/conf/nginx.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target

```

##### 设置开机启动

```
$ chmod 745 /lib/systemd/system/nginx.service
$ systemctl enable nginx.service # 设置开机启动
```

##### 开启服务

```
$ systemctl start nginx.service

```

访问http://127.0.0.1看到欢迎页则安装过程完成。




