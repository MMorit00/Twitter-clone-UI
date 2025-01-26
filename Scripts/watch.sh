#!/bin/bash

# 清理现有的监控
echo "🔄 Clearing existing watches..."
watchman watch-del-all

# 获取当前目录并用引号包裹以处理空格
CURRENT_DIR="$PWD"

# 开始监控项目目录
echo "👀 Starting file watch..."
watchman watch "$CURRENT_DIR"

# 设置触发器
echo "⚙️ Setting up trigger..."
watchman -- trigger "$CURRENT_DIR" xcodegen-trigger \
    -p 'name' 'Sources/**/*.swift' \
    -p 'name' 'Sources/**/*.xib' \
    -p 'name' 'Sources/**/*.storyboard' \
    -p 'name' 'Sources/**' \
    -p 'name' 'project.yml' \
     -- sh -c 'echo "🔄 Running XcodeGen..." && xcodegen generate && echo "✅ Done!"'

echo "✅ Watch setup complete! Changes will trigger XcodeGen automatically."
