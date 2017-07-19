---
title: MongoDB用户管理
date: 2017-07-19 11:58:17
tags:
	- 用户管理
	- auth
categorires:
	- 数据库
	- NoSQL/MongoDB
---

MongoDB为了使用方便，默认启动是不带用户认证的，也就是说所有人都可以连接并进行读写操作，这在开发阶段当然很方便，但是生产环境可就不能这么裸奔了。

首先来看看MongoDB的启动命令：
`$ mongod [--auth] --dbpath=<数据存放目录，默认/data/db> --fork --logpath=<日志存放目录>`

当带上参数--auth即在安全模式下启动，要在安全模式下启动，必须先完成用户的添加和授权。

# 添加管理员

首次在非认证模式下登录，然后添加管理员账户，在默认的admin数据库里，有一个名为*userAdminAnyDatabase*的内置角色，顾名思义，该角色的用户即为超级管理员，不过该角色只有管理用户和角色的功能，没有数据库读写权限。

```
$ mongo
#...省略连接输出..

> use admin
> db.createUser({
	user: "userAdmin",
    pwd: "123456"
    roles:[{role:"userAdminAnyDatabase",db:"admin"}]
})

```

# 重启MongoDB并在安全模式下登录

```
$ ps -ef | grep mongod | grep -v grep | cut -c 10-16 | xargs kill -9
$ mongod --auth --dbpath=<数据存放目录，默认/data/db> --fork --logpath=<日志存放目录>

```

# 以管理员身份登录

可以先连接到test数据库然后用db.auth进行认证，也可以直接在连接时候认证：
`$ mongo -u "userAdmin" -p "123456" --authenticationDatabase "admin" `，
从命令参数可以看出来，连接时认证真不好记那些参数，因此一般我都是先连接后认证的方式：

```
$ mongo
$ use admin
MongoDB shell version: 3.2.10
connecting to: test
> use admin
switched to db admin
> db.auth("root","ZzJK7Eg-akh9")
1

```

登录后可以查看下用户表:`> db.system.users.find()`

# 添加其它用户

和添加管理员方式一致，只是授权的数据库和赋予的角色有区别，一般常用的角色有read、readWrite、dbOwner等。

要了解其它内置角色参考这里[https://docs.mongodb.com/manual/reference/built-in-roles/](https://docs.mongodb.com/manual/reference/built-in-roles/),怎样自定义角色参考这里:[https://docs.mongodb.com/manual/core/security-user-defined-roles/#user-defined-roles](https://docs.mongodb.com/manual/core/security-user-defined-roles/#user-defined-roles)





