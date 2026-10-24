#!/usr/bin/env bash
set -euo pipefail

echo '=== 1. mount data disk ==='
mkdir -p /data
if mountpoint -q /data; then
  echo '/data already mounted'
else
  mount /dev/sdb1 /data
fi
mkdir -p /data/lzh /data/lzh/installers /data/lzh/tmp /data/lzh/Xilinx /data/lzh/v7re
chown -R stschai:stschai /data/lzh

echo '=== 2. install packages ==='
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-11-jdk tmux curl python3-pip rsync

echo '=== 3. verify ==='
df -hT / /data
java -version 2>&1 | head -2
javac -version 2>&1
tmux -V
curl --version | head -1
ls -la /data
