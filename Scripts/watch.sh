#!/bin/bash

##
# 监控 Sources 目录的 .swift 文件和目录结构变化，一旦有变动就执行 xcodegen generate
# 并输出日志到 trigger.log / xcodegen-error.log
#
# 使用:
#   ./watch.sh     # 启动监控
#   ./watch.sh stop    # 停止监控
##

# 1. 依赖检查
command -v watchman >/dev/null 2>&1 || {
  echo >&2 "❌ 未安装 watchman，请先安装。"
  exit 1
}
command -v xcodegen >/dev/null 2>&1 || {
  echo >&2 "❌ 未安装 xcodegen，请先安装。"
  exit 1
}

# 2. 如果有参数 "stop"，则停止全部监控并退出
if [ "$1" = "stop" ]; then
    echo "🛑 停止所有监控..."
    watchman watch-del-all
    echo "✅ 监控已停止！"
    exit 0
fi

# 3. 清理之前可能存在的所有监控
echo "🔄 清理现有监控..."
watchman watch-del-all

# 4. 进入当前目录并设置 .watchmanconfig（保持纯 JSON）
CURRENT_DIR="$PWD"
cat <<EOF > "$CURRENT_DIR/.watchmanconfig"
{
  "ignore_dirs": [
    "DerivedData",
    ".git",
    ".github",
    ".idea"
  ]
}
EOF

# 5. 启动对当前目录的监控
echo "👀 启动文件监控（仅监听 Sources 目录下的 .swift 文件变化）..."
watchman watch "$CURRENT_DIR"

# 6. 设置 watchman 的触发器，只监听 swift 文件变化，同时加长延时
watchman -- trigger "$CURRENT_DIR" xcodegen-structure-trigger \
    --create \
    --delete \
    --defer 5 \
    --drop 'name' '*.xcodeproj' \
    --drop 'name' '*.xcworkspace' \
    --drop 'name' 'trigger.log' \
    --drop 'name' 'xcodegen-error.log' \
    --drop 'name' 'DerivedData/**' \
    --drop 'name' '*.swp' \
    -p 'name' 'Sources/**/*.swift' \
    -- sh -c "echo \"🔄 [\$(date +'%T')] 检测到项目结构变化，触发文件: \$@\" >> trigger.log && xcodegen generate 2>> xcodegen-error.log"

echo "✅ 监控设置完成！现在只会监听 Sources 目录下的 .swift 文件变化。"
exit 0