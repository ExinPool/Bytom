#!/bin/bash
#
# Copyright © 2019 ExinPool <robin@exin.one>
#
# Distributed under terms of the MIT license.
#
# Desc: Bytom process monitor script.
# User: Robin@ExinPool
# Date: 2021-08-22
# Time: 17:23:29

# load the config library functions
source config.shlib

# load configuration
service="$(config_get SERVICE)"
base_dir="$(config_get BASE_DIR)"
log_file="$(config_get LOG_FILE)"
webhook_url="$(config_get WEBHOOK_URL)"
access_token="$(config_get ACCESS_TOKEN)"

# votes snapshots
curl https://bcapi.movapi.com/blockmeta/bytom2/v1/node/vote-transactions\?pub_key\=cc499725c708f272b3111c9e0694b66bba61f0321b14ee07b41cd677c9a633259bdbc96b9e67097d026dc9d4f859967194fd6e1770bf5cb6785c388d18486d80\&start\=0\&limit\=200 | jq '.' > ${base_dir}/votes-`date '+%Y%m%d'`.log

# balance snapshots
curl https://bcapi.movapi.com/blockmeta/bytom2/v1/address\?address\=bn1q3hqjn68pj9r5uhdwqsve3xwu6x2rlla2w8er0p | jq '.' > ${base_dir}/balance-`date '+%Y%m%d'`.log

# allvotes snapshots
curl https://bcapi.movapi.com/blockmeta/bytom2/v1/node/detail\?pub_key\=cc499725c708f272b3111c9e0694b66bba61f0321b14ee07b41cd677c9a633259bdbc96b9e67097d026dc9d4f859967194fd6e1770bf5cb6785c388d18486d80 | jq '.' > ${base_dir}/allvotes-`date '+%Y%m%d'`.log

log="时间: `date '+%Y-%m-%d %H:%M:%S'` UTC \n主机名: `hostname` \n节点: $service \n状态: 快照已完成。"
echo -e $log >> $log_file
success=`curl ${webhook_url}=${access_token} -XPOST -H 'Content-Type: application/json' -d '{"category":"PLAIN_TEXT","data":"'"$log"'"}' | awk -F',' '{print $1}' | awk -F':' '{print $2}'`

if [ "$success" = "true" ]
then
    log="`date '+%Y-%m-%d %H:%M:%S'` UTC `hostname` `whoami` INFO send mixin successfully."
    echo $log >> $log_file
else
    log="`date '+%Y-%m-%d %H:%M:%S'` UTC `hostname` `whoami` INFO send mixin failed."
     echo $log >> $log_file
fi
