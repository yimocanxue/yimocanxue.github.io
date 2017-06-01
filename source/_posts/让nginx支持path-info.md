---
title: 让nginx支持path_info
date: 2015-11-28 11:21:44
tags: nginx
categories:
	- 运维
	- LA/NMP服务
---


nginx默认是不支持path_info模式的，也就是说不支持index.php/*这样的url，因此像Thinkphp中URL model为2的那种路径方式nginx不支持。

只要修改虚拟主机的下面三个地方即可：

```
location ~ .php { #删除.php后的$
         fastcgi_pass   soopj_phpfcgi;
         fastcgi_index  default.php;
          
         fastcgi_split_path_info ^((?U).+.php)(/?.+)$;       #增加这句
         fastcgi_param PATH_INFO $fastcgi_path_info;   #增加这句
    
         fastcgi_param  SCRIPT_FILENAME   $document_root$fastcgi_script_name;
         include        fastcgi_params;
    } 

```