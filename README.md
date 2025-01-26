
# Swift Xcode Project Template

快速创建 Swift 项目的模板，集成了自动化工具链。

## 特性
- ✨ 自动文件监控
- 🛠 XcodeGen 项目生成
- 📱 iOS 应用模板
- 🔄 实时项目更新

## 开始使用

### 1. 克隆模板
```bash
git clone https://github.com/MMorit00/swift-xcode-template.git your-project
cd your-project
```

### 2. 初始化项目
```bash
./Scripts/init.sh
```

### 3. 开始开发
```bash
./Scripts/watch.sh
```


## 监控脚本说明

### setup-xcodegen-watch.sh
设置文件监控，当检测到项目文件变化时自动运行 XcodeGen。

```bash
# 设置监控
./Scripts/setup-xcodegen-watch.sh
```

### watch-xcodegen.sh
实时显示 XcodeGen 的执行状态和结果。

```bash
# 启动监控
./Scripts/watch-xcodegen.sh
```



## 目录结构
```
your-project/
├── Sources/          # 源代码
│   ├── App.swift
│   ├── Views/ 
│   └── Models/
├── Scripts/         # 工具脚本
└── project.yml      # 项目配置
```

## 依赖
- XcodeGen (`brew install xcodegen`)
- Watchman (`brew install watchman`)

## 配置说明
- `project.yml`: XcodeGen 项目配置
- `Scripts/watch.sh`: 文件监控脚本
- `Scripts/init.sh`: 项目初始化脚本
```


