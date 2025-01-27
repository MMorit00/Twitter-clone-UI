#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_message() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# 检查依赖
check_dependencies() {
    print_message "检查依赖..."
    
    if ! command -v xcodegen &> /dev/null; then
        print_error "未找到 XcodeGen，请先安装：brew install xcodegen"
        exit 1
    fi
    
    if ! command -v watchman &> /dev/null; then
        print_error "未找到 Watchman，请先安装：brew install watchman"
        exit 1
    fi
    
    print_success "依赖检查完成"
}

# 获取项目信息
get_project_info() {
    print_message "配置项目信息..."
    
    # 获取项目名称
    read -p "请输入项目名称: " PROJECT_NAME
    while [[ -z "$PROJECT_NAME" ]]; do
        print_error "项目名称不能为空"
        read -p "请输入项目名称: " PROJECT_NAME
    done
    
    # 获取组织名称
    read -p "请输入组织名称 (例如: mycompany): " ORGANIZATION_NAME
    while [[ -z "$ORGANIZATION_NAME" ]]; do
        print_error "组织名称不能为空"
        read -p "请输入组织名称: " ORGANIZATION_NAME
    done
    
    # 转换项目名称为小写（用于 bundle identifier）
    PROJECT_NAME_LOWERCASE=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]')
}

# 重置项目配置
reset_project_config() {
    print_message "重置项目配置..."
    
    # 创建初始的 project.yml 内容
    cat > project.yml << EOF
name: \${PROJECT_NAME}
options:
  bundleIdPrefix: com.\${ORGANIZATION_NAME}
  deploymentTarget:
    iOS: 17.0
  xcodeVersion: "15.1"
  generateEmptyDirectories: true
  createIntermediateGroups: true

targets:
  \${PROJECT_NAME}:
    type: application
    platform: iOS
    sources: [Sources]
    dependencies:
      - package: Inject
    settings:
      base:
        SWIFT_VERSION: 5.9
        DEVELOPMENT_TEAM: 38XZHDQFX8
        ENABLE_TESTABILITY: YES
        GENERATE_INFOPLIST_FILE: YES
        MARKETING_VERSION: 1.0.0
        CURRENT_PROJECT_VERSION: 1
        INFOPLIST_KEY_CFBundleDisplayName: "\${PROJECT_NAME}"  
        INFOPLIST_KEY_UILaunchScreen_Generation: YES
        INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone: UIInterfaceOrientationPortrait
        PRODUCT_BUNDLE_IDENTIFIER: com.\${ORGANIZATION_NAME}.\${PROJECT_NAME_LOWERCASE}
        OTHER_LDFLAGS[config=Debug][sdk=iphonesimulator*]: \$(inherited) -Xlinker -interposable

packages:
  Inject:
    url: https://github.com/krzysztofzablocki/Inject.git
    from: 1.2.4
EOF
    
    print_success "项目配置已重置"
}

# 更新项目配置
update_project_config() {
    print_message "更新项目配置..."
    
    # 替换变量
    sed -i '' "s/\${PROJECT_NAME}/$PROJECT_NAME/g" project.yml
    sed -i '' "s/\${ORGANIZATION_NAME}/$ORGANIZATION_NAME/g" project.yml
    sed -i '' "s/\${PROJECT_NAME_LOWERCASE}/$PROJECT_NAME_LOWERCASE/g" project.yml
    
    print_success "项目配置更新完成"
}

# 生成 Xcode 项目
generate_xcode_project() {
    print_message "生成 Xcode 项目..."
    
    if xcodegen generate; then
        print_success "Xcode 项目生成成功！"
    else
        print_error "Xcode 项目生成失败"
        exit 1
    fi
}

# 主函数
main() {
    echo "🚀 开始初始化项目..."
    
    # 重置配置文件到初始状态
    reset_project_config
    
    check_dependencies
    get_project_info
    update_project_config
    generate_xcode_project
    
    print_success "项目初始化完成！"
    echo ""
    echo "下一步："
    echo "1. 安装 InjectionIII 应用到 /Applications 目录"
    echo "2. ./Scripts/watch.sh"
    echo "3. 开始开发！"
}

# 执行主函数
main