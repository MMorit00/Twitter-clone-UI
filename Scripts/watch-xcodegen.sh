#!/bin/bash

# 设置管道路径
PIPE_PATH="/tmp/xcodegen-pipe"

# 清理函数
cleanup() {
    echo "清理管道..."
    rm -f $PIPE_PATH
    exit 0
}

# 捕获退出信号
trap cleanup EXIT

# 如果管道已存在，先删除
[ -p $PIPE_PATH ] && rm $PIPE_PATH

# 创建新管道
mkfifo $PIPE_PATH
chmod 644 $PIPE_PATH

echo "开始监听XcodeGen输出..."
echo "按 Ctrl+C 停止监听"

# 持续读取管道内容
while true; do
    cat < $PIPE_PATH
done