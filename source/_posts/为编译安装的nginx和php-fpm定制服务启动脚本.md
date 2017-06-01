---
title: 为编译安装的nginx和php-fpm定制服务启动脚本
date: 2015-11-29 13:26:38
categories:
	- 运维
	- LA/NMP服务
tags:
	- 启动脚本
	- nginx
	- php-fpm
---

源码编译安装的nginx和php-fpm没有centos自带的服务那样可以通过start|stop|restart等管理服务，只能自己定制了。

### nginx启动脚本/etc/init.d/nginx

```shell
#!/bin/bash
#
# Startup script for Nginx - this script starts and stops the nginx daemon
#
# chkconfig:   - 85 15
# description:  Nginx is an HTTP(S) server, HTTP(S) reverse proxy and IMAP/POP3 proxy server
# processname: nginx

# Source function library.
. /etc/rc.d/init.d/functions

# Source networking configuration.
. /etc/sysconfig/network

# Check that networking is up.
[ "$NETWORKING" = "no" ] && exit 0

nginx="/alidata/server/nginx/sbin/nginx"
prog=$(basename $nginx)

NGINX_CONF_FILE="/alidata/server/nginx/conf/nginx.conf"

[ -f /etc/sysconfig/nginx ] && . /etc/sysconfig/nginx

lockfile=/var/lock/subsys/nginx

start() {
    [ -x $nginx ] || exit 5
    [ -f $NGINX_CONF_FILE ] || exit 6
    echo -n $"Starting $prog: "
    daemon $nginx -c $NGINX_CONF_FILE
    retval=$?
    echo
    [ $retval -eq 0 ] && touch $lockfile
    return $retval
}

stop() {
    echo -n $"Stopping $prog: "
    killproc $prog -QUIT
    retval=$?
    echo
    [ $retval -eq 0 ] && rm -f $lockfile
    return $retval
}

restart() {
    configtest || return $?
    stop
    sleep 1
    start
}

reload() {
    configtest || return $?
    echo -n $"Reloading $prog: "
    killproc $nginx -HUP
    RETVAL=$?
    echo
}

force_reload() {
    restart
}

configtest() {
  $nginx -t -c $NGINX_CONF_FILE
}

rh_status() {
    status $prog
}

rh_status_q() {
    rh_status >/dev/null 2>&1
}

case "$1" in
    start)
        rh_status_q && exit 0
        $1
        ;;
    stop)
        rh_status_q || exit 0
        $1
        ;;
    restart|configtest)
        $1
        ;;
    reload)
        rh_status_q || exit 7
        $1
        ;;
    force-reload)
        force_reload
        ;;
    status)
        rh_status
        ;;
    condrestart|try-restart)
        rh_status_q || exit 0
            ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart|reload|force-reload|configtest}"
        exit 2
esac
```

保存后赋予执行权限，加入开机启动

```shell
sudo chmod +x /etc/init.d/nginx
sudo /sbin/chkconfig nginx on

```

### PHP-FPM启动脚本/etc/init.d/php-fpm

```shell
	#!/bin/bash
#
# Startup script for the PHP-FPM server.
#
# chkconfig: 345 85 15
# description: PHP is an HTML-embedded scripting language
# processname: php-fpm
# config: /usr/local/php/etc/php.ini

# Source function library.
. /etc/rc.d/init.d/functions

PHP_PATH=/alidata/server
DESC="php-fpm daemon"
NAME=php-fpm
# php-fpm路径
DAEMON=$PHP_PATH/php/sbin/$NAME
# 配置文件路径
CONFIGFILE=$PHP_PATH/php/etc/php-fpm.conf
# PID文件路径(在php-fpm.conf设置)
PIDFILE=$PHP_PATH/php/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME

# Gracefully exit if the package has been removed.
test -x $DAEMON || exit 0

rh_start() {
  $DAEMON -y $CONFIGFILE || echo -n " already running"
}

rh_stop() {
  kill -QUIT `cat $PIDFILE` || echo -n " not running"
}

rh_reload() {
  kill -HUP `cat $PIDFILE` || echo -n " can't reload"
}

case "$1" in
  start)
        echo -n "Starting $DESC: $NAME"
        rh_start
        echo "."
        ;;
  stop)
        echo -n "Stopping $DESC: $NAME"
        rh_stop
        echo "."
        ;;
  reload)
        echo -n "Reloading $DESC configuration..."
        rh_reload
        echo "reloaded."
  ;;
  restart)
        echo -n "Restarting $DESC: $NAME"
        rh_stop
        sleep 1
        rh_start
        echo "."
        ;;
  *)
         echo "Usage: $SCRIPTNAME {start|stop|restart|reload}" >&2
         exit 3
        ;;
esac
exit 0
```

同样赋予执行权限和设置开机启动：

```shell
sudo chmod +x /etc/init.d/php-fpm
sudo /sbin/chkconfig php-fpm on

```

