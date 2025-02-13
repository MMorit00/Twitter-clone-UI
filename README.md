
# TwitterClone

一款基于SwiftUI的iOS应用程序，模拟了Twitter的核心功能——注册、登录、发布推文、点赞、关注、编辑个人资料、搜索、查看通知等。该应用程序使用Swift编写，采用MVVM架构，并使用**依赖注入（DI）**来管理其服务。

<div align="center">
<img src="https://user-images.githubusercontent.com/placeholder/your-app-screenshot.png" width="350" alt="App screenshot" />
</div>

## 目录
- [TwitterClone](#twitterclone)
  - [目录](#目录)
  - [功能](#功能)
  - [先决条件](#先决条件)
  - [运行项目](#运行项目)
  - [项目结构](#项目结构)
    - [重要文件](#重要文件)
  - [关键组件](#关键组件)
  - [依赖注入](#依赖注入)
  - [数据流](#数据流)
  - [核心服务](#核心服务)
    - [1. AuthService](#1-authservice)
    - [2. TweetService](#2-tweetservice)
    - [3. ProfileService](#3-profileservice)
    - [4. NotificationService](#4-notificationservice)
  - [用户故事](#用户故事)
  - [后端设置（可选）](#后端设置可选)
  - [许可证](#许可证)

## 功能
* 用户认证：使用电子邮件、用户名和密码注册和登录
* 个人资料管理：查看和编辑个人资料（头像、横幅、简介、位置、网站）
* 发布推文：创建推文并附加图片（可选）
* 点赞/取消点赞：点赞或取消点赞推文，并实时更新
* 通知：显示列表，列出他人点赞或关注的通知
* 搜索：按用户名或真实姓名搜索其他用户
* 消息（仅UI）：简单的UI占位符用于直接消息
* 注销：清除会话令牌并返回WelcomeView

## 先决条件
* Xcode 14+（或更新版本）
* iOS 16+ 部署目标
* Swift 5.7+
* 使用Swift包管理器（SPM）来获取诸如Kingfisher之类的依赖项

该应用程序配置为与位于 `http://localhost:3000` 的后端通信。您需要在该端口上运行一个本地服务器（或者您可以在 `APIConfig.swift` 中更改 URL）。

## 运行项目
1. 克隆代码库
```bash
git clone https://github.com/yourusername/TwitterClone.git
cd TwitterClone
```

2. 在Xcode中打开项目
   * 双击 TwitterClone.xcodeproj 或通过 Xcode → "打开一个项目或文件…" 来打开

3. 安装依赖项
   * 该项目使用Swift包管理器（SPM）。Xcode将在首次打开时自动解析包

4. 设置后端（可选）
   * 确保您的后端服务器正在 localhost:3000 上运行。请参阅 [后端设置](#后端设置可选) 获取更多详情

5. 运行
   * 选择一个iOS模拟器，然后按 Run（⌘+R）运行

您应该会看到 WelcomeView，提示您 登录 或 创建账户。

## 项目结构

代码库被组织成几个文件夹，每个文件夹包含特定领域的逻辑：

```
.
├─ App/                       # 应用程序入口点和主场景
│  ├─ TwitterCloneApp.swift   # 含 DIContainer 和 AuthState 的 App 结构体
│  └─ ContentView.swift       # ContentView 决定显示哪个屏幕（MainView 或 WelcomeView）
│
├─ Core/                      # 核心基础代码
│  ├─ Common/Extensions/      # 共享的扩展（例如：ImagePicker）
│  ├─ Legacy/                 # 较旧或后备代码（例如：ImageUploader）
│  ├─ Network/                # 网络层
│  │  ├─ Base/                # APIClient、APIEndpoint、NetworkError、HTTPMethod
│  │  └─ Config/              # APIConfig，baseURL 等
│  └─ Storage/                # （用于Keychain/UserDefaults逻辑的占位符）
│
├─ Features/                  # 基于功能的组织
│  ├─ Auth/                   # 所有与认证相关的（登录、注册、AuthState、视图）
│  ├─ Feed/                   # 推文创建、信息流展示、单元格UI等
│  ├─ Notifications/          # 通知列表和服务
│  ├─ Profile/                # 获取、编辑用户资料，上传头像/横幅
│  ├─ Messages/               # 简单的消息占位符
│  └─ Search/                 # 用户搜索屏幕和逻辑
│
├─ Main/Views/                # 侧滑菜单（抽屉），主标签视图，顶部条等
├─ DIContainer.swift          # 依赖注入容器
└─ ...
```

### 重要文件
* **TwitterCloneApp.swift**
  * 主要入口点，使用 `@main`。设置 `DIContainer` 和 `AuthState` 作为 `@StateObject`
* **DIContainer.swift**
  * 使用基于字典的方式实现依赖注入。每个服务都在 `ServiceType` 枚举键下注册（如 `.apiClient`、`.authService` 等）
* **AuthState.swift**
  * 一个 `@MainActor` 类，跟踪当前登录的用户，处理登录/登出，并发布认证状态
* **APIClient.swift**
  * 用于使用 async/await 进行HTTP请求的专门类。它可以发送JSON数据或多部分表单数据，处理重试、解码JSON等
* **ImageUploader.swift**
  * 一个遗留的代码片段，用于手动上传图像（多部分表单数据），使用 URLSession
* **ProfileViewModel.swift / ProfileView.swift**
  * 包含获取和编辑用户资料的逻辑，以及用户资料页面的UI

## 关键组件
1. **App**
   * `TwitterCloneApp.swift`: 设置 `DIContainer.defaultContainer()` 和 `AuthState(authService:)`
   * `ContentView.swift`: 决定显示 `MainView`（如果已认证）或 `WelcomeView`（否则）

2. **AuthState**
   * 被视图观察，用于确定用户是否已登录
   * 提供 `login()`、`register()`、`signOut()` 等方法，并更新全局 `currentUser`

3. **服务**
   * `AuthServiceProtocol + AuthService1`：注册、登录、获取当前用户
   * `TweetServiceProtocol + TweetService`：创建推文、点赞/取消点赞、上传图片
   * `ProfileServiceProtocol + ProfileService`：获取和编辑资料、上传头像/横幅
   * `NotificationServiceProtocol + NotificationService`：获取或创建通知

4. **ViewModels**
   * Auth: `AuthState`
   * Feed: `FeedViewModel`，`TweetCellViewModel`，`CreateTweetViewModel`
   * Profile: `ProfileViewModel`
   * Notifications: `NotificationsViewModel`
   * Search: `SearchViewModel`

5. **视图**
   * `WelcomeView`: 显示引导页面，提供"登录"和"创建账户"选项
   * `LoginView` 和 `RegisterView`: 处理用户凭据输入，并调用 `AuthState`
   * `MainView`: 包含标签视图（Feed、Search、Notifications、Messages）以及侧滑菜单（SlideMenu）
   * `ProfileView`: 显示用户资料信息、推文，并允许编辑（如果是当前用户）
   * `EditProfileView`: 允许编辑头像/横幅，修改名称、简介、位置、网站等
   * `SearchView`: 列出用户，并按搜索文本过滤
   * `NotificationsView`: 显示当前登录用户的通知

## 依赖注入

此应用程序使用自制的 `DIContainer` 类来注册和解析依赖项：

```swift
// 1. 注册 
container.register(APIClient(baseURL: ...), type: .apiClient)

// 2. 解析 
let apiClient: APIClientProtocol = container.resolve(.apiClient) ?? ...
```

每个 View 或 ViewModel 需要服务时可以通过两种方式访问它：
1. `@Environment(\.diContainer)`: 在SwiftUI视图中，检索容器并执行 `container.resolve(.authService)`
2. 状态或环境注入: 例如，`TwitterCloneApp` 在启动时设置容器

## 数据流
1. **用户启动应用程序**
   * `TwitterCloneApp` 检查 `UserDefaults` 中是否存储了JWT。如果存在，则调用 `authService.fetchCurrentUser()` 恢复会话

2. **认证**
   * 用户点击 登录 → `AuthState.login(email, password)`。成功后，接收 token，并将其存储在 `UserDefaults` 中
   * 如果是 注册，类似地设置当前用户在 `AuthState` 中

3. **MainView 和 Feed**
   * 显示 TabView（主页、搜索、通知、消息）
   * `FeedViewModel` 调用 `tweetService.fetchTweets()`
   * `TweetCellViewModel` 处理点赞/取消点赞

4. **个人资料**
   * `ProfileViewModel.fetchProfile()` + `fetchUserTweets()`
   * 编辑通过 `profileService.updateProfile()` 完成
   * 头像/横幅通过 `profileService.uploadAvatar()`/`uploadBanner()` 上传

5. **通知**
   * `NotificationsViewModel.fetchNotifications()` 使用 `notificationService` 显示新的点赞/关注
   * 点赞时：`tweetService` 还会调用 `notificationService.createNotification(...)`

6. **搜索**
   * `SearchViewModel` 加载所有用户，用户列表按 `searchText` 过滤

## 核心服务

### 1. AuthService
* `login(email:password:)` → `APIResponse`
* `register(...)` → `User`
* `fetchCurrentUser()` → `User`
* `updateProfile(data:)` → `User`

### 2. TweetService
* `fetchTweets()` → `[Tweet]`
* `createTweet(text:userId:)` → `Tweet`
* `likeTweet(tweetId:)` / `unlikeTweet(tweetId:)` → `Tweet`
* `uploadImage(tweetId:image:)` → `ImageUploadResponse`

### 3. ProfileService
* `fetchUserProfile(userId:)` → `User`
* `updateProfile(data:)` → `User`
* `fetchUserTweets(userId:)` → `[Tweet]`
* `uploadAvatar(imageData:)` / `uploadBanner(imageData:)` → `User`

### 4. NotificationService
* `fetchNotifications(userId:)` → `[Notification]`
* `createNotification(username:receiverId:type:postText:)` → `Notification`

## 用户故事
1. 作为一个新用户，我希望通过电子邮件、用户名和密码注册来创建一个账户
2. 作为一个返回用户，我希望能够登录，以便查看我的主页信息流
3. 作为一个认证用户，我希望发布新的推文（可附带图片）
4. 作为一个认证用户，我希望通过点击点赞来表达对推文的喜爱
5. 作为一个认证用户，我希望编辑我的个人资料（头像、横幅、姓名、简介、位置、网站）
6. 作为一个认证用户，我希望在通知中查看哪些用户喜欢了我的推文
7. 作为一个认证用户，我希望在搜索标签中看到其他用户的列表
8. 作为一个用户，我希望查看他人的个人资料页面和推文
9. 作为一个用户，我希望随时注销，以结束我的会话

## 后端设置（可选）

本项目引用了位于 `http://localhost:3000` 的API。您可以构建自己的 Node/Express 或其他服务器来实现这些端点：

* `POST /users` → 注册
* `POST /users/login` → 登录
* `GET /users/me` → 当前用户
* `PATCH /users/me` → 更新资料
* `POST /users/me/avatar` → 上传头像
* `POST /users/me/banner` → 上传横幅
* `GET /tweets` → 获取推文
* `POST /tweets` → 创建推文
* `PUT /tweets/:id/like` → 点赞推文
* `PUT /tweets/:id/unlike` → 取消点赞推文
* `POST /tweets/:id/image` → 上传推文图片
* `GET /notifications/:userId` → 获取通知
* `POST /notifications` → 创建通知

对于图像字段，API必须解析`multipart/form-data`。请参阅 `ImageUploader` 和 `APIClient.sendRequestWithoutDecoding(...)` 以获取示例。

## 许可证

本项目是"按原样"提供的，不附带任何类型的保证。您可以自由地派生、修改和重新分发。感激但不是必须的给出署名。

---

愉快编码！ 如果您有任何问题或需要进一步的帮助，请开设问题或提交拉取请求。
