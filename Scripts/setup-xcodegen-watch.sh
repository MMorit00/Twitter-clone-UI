#!/bin/bash

# 设置管道路径
PIPE_PATH="/tmp/xcodegen-pipe"

# 清理现有的监控
echo "🔄 清理现有的watches..."
watchman watch-del-all

# 开始监控项目目录
echo "👀 开始监控文件..."
watchman watch $PWD

# 设置触发器
echo "⚙️ 设置触发器..."
watchman -- trigger $PWD xcodegen-trigger \
    -p 'name' '*.yml' \
    -p 'name' 'Sources/**' \
    -- bash -c "echo '⚡️ 执行 XcodeGen' > $PIPE_PATH && \
                xcodegen generate >/dev/null 2>&1 && \
                echo '✅ 完成' > $PIPE_PATH || \
                echo '❌ 失败' > $PIPE_PATH"

echo "✅ 监控设置完成!"
echo "运行 './watch-xcodegen.sh' 开始监控"