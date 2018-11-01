---
title: Nginx日期切割
cetegories:
  - 运维
  - LA/NMP服务
tags:
  - tengine
  - nginx lua扩展
abbrlink: 6528fea8
date: 2017-11-30 15:21:57
---

### 编写切割日志脚本

```
#!/bin/bash

LOG_PATH=/server/log/nginx
BACKUP_PATH=${LOG_PATH}/backup

CURRENT_FILE=""

# 备份目录不存在则创建
[[ ! -x "${BACKUP_PATH}" ]] && { mkdir -p $BACKUP_PATH ; }

# 遍历日志文件并备份
for file in `ls ${LOG_PATH}`;do
    CURRENT_FILE="${LOG_PATH}/${file}"
    if [[ -f "${CURRENT_FILE}" && "${file: -4}" = ".log" ]];then
        echo ${file%.*}
        mv "${CURRENT_FILE}" "${BACKUP_PATH}/${file%.*}-$(date +%Y%m%d).log"
    fi
done


kill -USR1 $(cat /server/tengine/logs/nginx.pid)

```

比如保存在根目录下/rotateLog，设置脚本执行权限
```
$ chmod +x /rotateLog

```

### 设置crontab任务

```
$ crontab -e

59 23 * * * /rotateLog

```