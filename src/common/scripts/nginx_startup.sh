#!/bin/bash

# 基本認証のユーザー名とパスワード
#echo "${USER_NAME}:$(openssl passwd -apr1 ${PASSWORD})" > "/etc/nginx/.htpasswd"

/usr/sbin/nginx -g "daemon off;" 
