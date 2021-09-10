#!/bin/bash
#
# Copyright © 2019 ExinPool <robin@exin.one>
#
# Distributed under terms of the MIT license.
#
# Desc: Mixin process monitor script.
# User: Robin@ExinPool
# Date: 2021-09-1
# Time: 07:50:15

# load the config library functions
source config.shlib

# load configuration
service="$(config_get SERVICE)"
local_host="$(config_get LOCAL_HOST)"
remote_host_first="$(config_get REMOTE_HOST_FIRST)"
remote_host_second="$(config_get REMOTE_HOST_SECOND)"
abs_num="$(config_get ABS_NUM)"
node_id="$(config_get NODE_ID)"
log_file="$(config_get LOG_FILE)"
webhook_url="$(config_get WEBHOOK_URL)"
access_token="$(config_get ACCESS_TOKEN)"

local_blocks=`curl https://bcapi.movapi.com/blockmeta/bytom2/v1/block-headers\?start\=0\&limit\=20 | jq | grep ${local_host} -B 8 | grep height | head -1 | sed "s/\"//g" | sed "s/,//g" | awk -F': ' '{print $2}'`
remote_first_blocks=`curl https://bcapi.movapi.com/blockmeta/bytom2/v1/block-headers\?start\=0\&limit\=20 | jq | grep ${remote_host_first} -B 8 | grep height | head -1 | sed "s/\"//g" | sed "s/,//g" | awk -F': ' '{print $2}'`
remote_second_blocks=`curl https://bcapi.movapi.com/blockmeta/bytom2/v1/block-headers\?start\=0\&limit\=20 | jq | grep ${remote_host_second} -B 8 | grep height | head -1 | sed "s/\"//g" | sed "s/,//g" | awk -F': ' '{print $2}'`
log="`date '+%Y-%m-%d %H:%M:%S'` UTC `hostname` `whoami` INFO local_blocks: ${local_blocks}, remote_first_blocks: ${remote_first_blocks}, remote_second_blocks: ${remote_second_blocks}"
echo $log >> $log_file

local_first=$((local_blocks - remote_first_blocks))
local_second=$((local_blocks - remote_second_blocks))

if [ ${local_first#-} -gt ${abs_num} ] && [ ${local_second#-} -gt ${abs_num} ]
then
    log="时间: `date '+%Y-%m-%d %H:%M:%S'` UTC \n主机名: `hostname` \n节点: ${local_host}, ${local_blocks} \n远端节点 1: ${remote_host_first}, ${remote_first_blocks} \n远端节点 2: ${remote_host_second}, ${remote_second_blocks} \n状态: 区块数据不同步。"
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
else
    log="`date '+%Y-%m-%d %H:%M:%S'` UTC `hostname` `whoami` INFO ${service} ${local_host} status is normal."
    echo $log >> $log_file
fi