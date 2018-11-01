---
title: centos6.5安装Memcached和php memcached扩展
cetegories:
  - 运维
  - LA/NMP服务
tags:
  - php扩展
  - memcached
abbrlink: 61bbb9b8
date: 2015-11-29 13:12:15
---

### 安装memcached服务

`$ yum -y install memcached`

把memcached加入开机启动

`$ chkconfig memcached on`

这个比较简单，yum同时安装依赖的libevent，安装后只要执行memcached -h有输出即安装成功,memcached的默认启动参数可以在/etc/sysconfig/memcached 修改。


### 安装memcached扩展依赖的libmemcached

```
$ wget https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz
$ tar zxvf libmemcached-1.0.18.tar.gz 
$ cd libmemcached-1.0.18
$ ./configure -prefix=/usr/local/libmemcached -with-memcached
$ make && make install

```

### 安装php-devel

如果在你php的bin目录下有phpize这个东东这步可以省略，phpize主要用来编译php外挂扩展

` $ yum -y install php-devel`

### 安装igbinary扩展

```
$ wget http://pecl.php.net/get/igbinary-1.2.1.tgz
$ tar zxvf igbinary-1.2.1.tgz
$ cd igbinary-1.2.1
$ /alidata/server/php/bin/phpize
$ ./configure --with-php-config=/alidata/server/php/bin/php-config
$ make &&  make install

```

然后在在php.ini中增加extension=igbinary.so


### 安装memcached扩展

```
$ wget http://pecl.php.net/get/memcached-2.2.0.tgz
$ tar zxvf memcached-2.2.0.tgz
$ cd memcached-2.2.0
$ /alidata/server/php/bin/phpize
$ ./configure -enable-memcached -enable-memcached-igbinary -enable-memcached-json -with-php-config=/alidata/server/php/bin/php-config -with-zlib-dir -with-libmemcached-dir=/usr/local/libmemcached -prefix=/usr/local/phpmemcached --disable-memcached-sasl
$ make && make install
```

最后编辑php.ini，加入memcached扩展
extension=memcached.so

正常情况安装就成功了。
