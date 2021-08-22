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

BASE_DIR=/data/monitor/exinpool/Bytom/snapshots

# votes snapshots
curl https://bcapi.movapi.com/blockmeta/bytom2/v1/node/vote-transactions\?pub_key\=cc499725c708f272b3111c9e0694b66bba61f0321b14ee07b41cd677c9a633259bdbc96b9e67097d026dc9d4f859967194fd6e1770bf5cb6785c388d18486d80\&start\=0\&limit\=200 | jq > votes-`date '+%Y-%m-%d`.log

# balance snapshots
curl https://bcapi.movapi.com/blockmeta/bytom2/v1/address\?address\=bn1q3hqjn68pj9r5uhdwqsve3xwu6x2rlla2w8er0p | jq > balance-`date '+%Y-%m-%d`.log