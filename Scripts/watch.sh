#!/bin/bash

if [ "$1" = "stop" ]; then
    echo "🛑 Stopping all watches..."
    watchman watch-del-all
    echo "✅ All watches stopped!"
    exit 0
fi

# 清理现有的监控
echo "🔄 Clearing existing watches..."
watchman watch-del-all

# 获取当前目录并用引号包裹以处理空格
CURRENT_DIR="$PWD"

# 开始监控项目目录
echo "👀 Starting file watch..."
watchman watch "$CURRENT_DIR"

# 设置文件/目录创建和删除的触发器
echo "⚙️ Setting up creation/deletion trigger..."
watchman -- trigger "$CURRENT_DIR" xcodegen-structure-trigger \
    --create \
    --delete \
    --defer 2 \
    --drop 'name' '*.xcodeproj/**/*' \
    -p 'name' 'Sources/**/*.swift' \
    -p 'name' 'Sources/**' \
    -- sh -c 'echo "🔄 Project structure changed, running XcodeGen..." && xcodegen generate && echo "✅ Done!"'

echo "✅ Watch setup complete! Changes will trigger XcodeGen only when files/directories are added or removed."