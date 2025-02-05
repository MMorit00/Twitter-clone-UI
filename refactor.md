以下是一份对该项目主要架构特点和潜在问题的较为全面的分析，以及由此可能带来的后果。内容涵盖了代码组织、数据流设计、网络层处理、依赖注入、单例使用、可测试性、可扩展性等方面。

一、项目整体架构特点
	1.	SwiftUI + MVVM-ish 架构
	•	项目大体上使用了 SwiftUI 的 View + ViewModel 形式来组织界面和业务逻辑，并在部分地方使用了 Combine/Async 等特性。
	•	ViewModel 负责从网络层获取数据并进行解析，然后通过 @Published 或 @StateObject 等方式驱动 SwiftUI 的视图更新。
	2.	单例 + EnvironmentObject 组合使用
	•	通过 AuthViewModel.shared（单例）来管理全局的用户登录状态（token、用户信息等），再在顶层使用 .environmentObject(AuthViewModel.shared) 使得所有子视图均可共享这份状态。
	•	这种“全局单例 + 环境对象”的模式在小规模项目中可以快速实现一个“全局状态管理”，但随着业务增长，可能会在可维护性与测试性上产生一些问题。
	3.	依赖注入（Inject 库）
	•	项目中使用了一个名为 Inject 的第三方库，通过 @ObserveInjection、enableInjection() 等方式来实现“热重载”或“依赖注入”等功能。
	•	这一部分代码对普通读者比较陌生，会带来一定的学习成本。尤其在正式生产环境中，这类热重载或特殊注入逻辑，需要仔细评估是否真的有必要。
	4.	基于 URLSession 的简单网络层
	•	项目里的网络请求方法多在 RequestServices / AuthService 静态类中实现，包含增删改查（CRUD）以及 “关注、点赞”等动作。
	•	逻辑上属于“轻量级的网络封装”：直接使用 URLSession，缺少更清晰的“客户端-仓库（Repository）-ViewModel”分层，但也算易于理解。
	5.	直接将 token 保存在 UserDefaults / @AppStorage 中
	•	利用 SwiftUI 的 @AppStorage 或 UserDefaults 来保存 jwt 和 userId，方便在应用重启时自动读取并进行“静默登录”或“自动获取用户信息”。
	•	这种做法在 Demo 或小型 App 中常见；在正式生产环境如果对安全性有更多要求，一般会考虑使用钥匙串（Keychain）或者更安全的存储方式，并对 token 进行必要的过期检测和刷新。
	6.	以“单个文件/单个大文件”为主的代码组织
	•	从以上贴出的代码量看，许多功能块都在同一个 Swift 文件或几个大文件中，这对快速迭代来说很方便，但会降低后期可维护性。
	•	随着业务增长，代码复杂度上升，如果继续将所有模型、网络请求、视图都糅合在一两个文件里，后期排查问题与扩展功能会越来越困难。

二、潜在缺点或问题
	1.	单例滥用与全局共享状态
	•	AuthViewModel.shared 作为全局单例，配合 .environmentObject，“任何地方都可随意访问和修改” 的特性，会导致业务逻辑的边界变得模糊。
	•	这在多人协同开发、模块化拆分、单元测试等方面，可能出现难以追踪的数据流、难以模拟不同场景（比如要模拟用户未登录的场景，往往需要“篡改”单例）。
	2.	数据和 UI 耦合度较高
	•	在部分 ViewModel（例如 TweetCellViewModel、ProfileViewModel）中，直接执行网络请求、处理响应，同时又持有 @Published 用来驱动 UI；
	•	在一些“事件”触发（如点赞、关注、注销登录等）时，也是在 ViewModel 内部直接调用 RequestServices。
	•	没有中间的“UseCase/Repository” 层来做业务逻辑或数据访问的抽象，意味着后续要更换网络层、改用离线缓存或添加更多操作逻辑时，需要改动多个 ViewModel，耦合度高。
	3.	错误处理较为简单，多处仅使用 print
	•	虽然有 error: Error? 的字段，但不少地方的错误只是在控制台打印，或简单地把错误赋值给 error，并没有统一的错误提示或上下文处理。
	•	对用户而言，如果网络出错或服务器返回异常，只能看到“什么也没发生”或一个简单的 print。
	•	长期来看，这会影响用户体验，也不利于收集并统计错误类型。
	4.	缺少对 Token 过期、刷新、失效的细节处理
	•	AuthViewModel 中虽然有 validateToken() 这种注释，但暂未实现。
	•	如果服务器端的 Token 有有效期，前端需要在 Token 过期前进行刷新，或在请求被拒绝后自动跳转登录，否则用户会一直处于“无效 Token”状态，导致网络请求不断失败。
	•	目前的写法只是在 init 时检查本地是否有 token 和 userId，并没有进一步的 Token 过期管理。
	5.	对网络层的封装较原始，缺少统一的拦截或中间件
	•	RequestServices / AuthService 中，大量地直接拼接 URL、组装 URLRequest、添加 Header、解析 JSON。
	•	如果将来要添加统一的请求重试、鉴权刷新、统计日志或通用异常处理，就需要手动修改每个接口方法或者另外建一个层。这加重了扩展成本。
	6.	部分异步/并发调用方式混杂
	•	部分地方使用 withCheckedThrowingContinuation、Task { ... } 等 Swift Concurrency 结构；
	•	也有不少地方使用 completion: @escaping (Result<...>) -> Void 的“闭包回调”写法；
	•	这种混合方式在小范围内可以忍受，但如果项目进一步变大，将来最好统一使用 Swift Concurrency（async/await），或统一使用 Combine Reactive 流等，以减少心智负担。
	7.	没有单元测试 / UI 测试
	•	代码里没有明显看到任何针对网络层、业务逻辑、ViewModel 的测试。
	•	单例、大量全局状态、直接依赖实网的请求，在编写测试时会遇到比较多的阻碍。若需求提出“希望保证主流程 95% 覆盖率”，那在现有架构下编写测试会非常困难。
	8.	整体可扩展性和模块化不足
	•	目前所有逻辑都集中在一个（或少数几个）大文件中，当需求越来越多时，项目将很难在结构上保持可控。
	•	比如评论功能、私信功能、通知系统、更多社交关系（粉丝分页、黑名单、拉黑等）都需要在现有 RequestServices 中新增大量接口，并在 ViewModel 里对应处理。
	9.	依赖注入（Inject 库）的额外复杂度
	•	@ObserveInjection、enableInjection() 等看似方便快速热重载，但在实际团队开发中，需要让所有人都熟悉这套机制；
	•	也可能会带来在发布到生产环境时不需要的额外代码，或引起一些因为“依赖注入失效”导致的奇怪问题。
	•	若团队对 SwiftUI 原生的 “环境对象 + ViewModel” 方式熟悉，这种第三方注入的收益与风险要仔细权衡。

三、可能导致的后果与风险
	1.	维护成本高、可读性下降
	•	随着项目功能增多，“单例 + 大文件 + 全局访问” 会导致逻辑散落各处，很难在一个地方清晰理解 “数据是如何流动的、状态是如何改变的”。
	•	新人或后来加入的开发者阅读代码时，会经常需要跳转到各种单例或静态方法中寻找业务逻辑，时间成本和出错率都会上升。
	2.	测试与迭代困难
	•	全局单例和闭包回调混合使用，使得对单个模块进行单元测试（Unit Test）或集成测试（Integration Test）变得复杂；
	•	要模拟用户未登录 / Token 失效 / 网络超时 等场景时，需要在测试套件中对单例进行人工注入或手动清空状态，很不直观也容易遗漏。
	•	频繁改动某个公共的请求方法或单例状态，可能导致完全意料之外的副作用。
	3.	安全性与容错性不足
	•	如果 Token 过期后没有相应的刷新策略，用户在使用中就会出现“不知道为什么所有请求都失败”，导致 UX（用户体验）下滑；
	•	直接把 Token 放在 UserDefaults，对于普通应用问题不大，但如果是对安全性要求更高的应用（例如金融、政务），就需要更多加密和保护手段。
	4.	耦合度高，难以替换或升级
	•	如果后端将来要把某些接口拆分到其他微服务、或者变更接口地址，前端需要大范围搜索替换；
	•	要实现离线模式、本地缓存、或者切换到 GraphQL / gRPC 时，也会发现所有与后端交互的逻辑都深度耦合在各个 ViewModel 中，需要大量改造。
	5.	潜在的性能和可扩展风险
	•	由于没有明显的分页、缓存、或本地存储策略，随着用户和数据量增大，应用拉取的内容越来越多，网络和界面性能可能下降；
	•	大量的 GeometryReader + offset 动画逻辑，也可能在极端情况下（例如同时加载很多图片、后台不断刷新）影响流畅度。

四、可能的改进建议（简要）
	1.	拆分模块、精简单例
	•	可以考虑把与认证相关的逻辑单独做成一个 AuthService 或 AuthRepository，再配合一个 AuthViewModel；
	•	使用环境对象或依赖注入时，尽量减少“所有地方都能访问、都能改”的全局共享，改为分场景或分功能组件化（例如 TweetFlow、ProfileFlow 等）。
	2.	统一网络请求与错误处理
	•	建立一个更“集中统一”的网络层，配合中间件或拦截器机制，来自动处理 Token 过期、刷新、统一的错误弹窗/提示等；
	•	使用 async/await 来简化回调逻辑，让请求逻辑更易读易测。
	3.	更明确的 MVVM / Clean Architecture 分层
	•	将最关键的业务用例（User 的关注 / 取消关注、Tweet 的点赞 / 取消点赞）抽象为 UseCase 或 Repository，ViewModel 只关心“调哪一个用例”，不关心底层是怎么实现；
	•	这样一来，如果将来要新增本地缓存或离线功能，只需要改 UseCase/Repository 层即可。
	4.	加强错误提示与 Token 失效处理
	•	在用户界面上对常见网络错误、登录过期、资源找不到等进行更友好的提示，而不是仅仅打印或简单地赋给某个 error 变量；
	•	考虑在 AuthViewModel 中统一监听所有请求返回的 HTTP Code，若检测到 401/403 等鉴权失败，自动弹出登录或刷新 Token。
	5.	模块化文件结构与多 Target
	•	参考模块化做法，将用户（Profile / Auth）功能、推文（Tweet / Feed）功能、消息/通知功能等，拆分到不同的模块或至少不同文件夹/Swift 文件中；
	•	对通用组件（如图片选择、通用的 Toast/Alert/Loading/自定义 Button 等）也可单独整理。
	6.	测试、日志与监控
	•	尝试为一些核心的逻辑编写单元测试或集成测试，例如登录逻辑、数据解析逻辑、关注/取消关注逻辑；
	•	引入简单的日志系统或 Crash 监控框架，以便在出现问题时能快速定位。

五、总结

该项目目前的优点是：对新手而言，直观且上手快，基本功能（登录、发推、关注、点赞、查看个人资料）都可以用简单的单例和 EnvironmentObject 搞定；在小规模 Demo 阶段，“能跑能用”胜过一切。

但从长期可维护性和可扩展性角度，需要警惕单例滥用、全局状态难以管理、网络与业务逻辑缺少分层、错误处理不足等问题。在团队协作或业务复杂度继续上升时，这些问题可能会带来开发难度增大、测试困难、Bug 难排查以及用户体验不稳定等后果。

如果将来打算走向更健壮或商业化的 App，需要逐步对项目进行模块拆分、引入更清晰的网络层封装、加强错误处理与 Token 管理、完善测试，从而降低技术债务和潜在的维护成本。



# Model


## Tweet 


```javascript
Model: Tweet (Identifiable, Decodable, Equatable)
├── Properties
│   ├── _id: String          // MongoDB 文档唯一标识
│   ├── text: String         // 推文内容
│   ├── userId: String       // 用户ID
│   ├── username: String     // 用户名
│   ├── user: String         // 用户显示名称
│   ├── image: Bool?         // 可选，是否包含图片
│   ├── likes: [String]?     // 可选，点赞用户ID数组
│   └── didLike: Bool?       // 可选，当前用户是否点赞
│
├── Computed Property
│   └── id: String          // 实现 Identifiable 协议，返回 _id
│
├── CodingKeys (enum)       // JSON 解码键映射
│   ├── _id
│   ├── text
│   ├── userId
│   ├── username
│   ├── user
│   ├── image
│   └── likes
│
└── Custom Decoder
    └── init(from decoder:) // 自定义解码逻辑
        ├── 基础字段解码
        └── 用户信息解码处理
            ├── 支持嵌套字典格式
            └── 支持扁平字符串格式
```


关键点说明：


1. 这是一个推文数据模型，实现了三个协议：
	- Identifiable：提供唯一标识
	- Decodable：支持 JSON 解码
	- Equatable：支持相等性比较
2. 解码器支持两种格式的用户信息：
	- 嵌套字典格式：userId 是一个包含 _id、name、username 的字典
	- 扁平字符串格式：直接存储 userId、user、username
3. 点赞相关字段（likes、didLike）为可选类型，支持后续功能扩展

## User


```other
Model: User (Codable, Identifiable, Hashable)
├── 基础属性
│   ├── id: String          // MongoDB _id
│   ├── username: String    // 用户名
│   ├── name: String       // 显示名称
│   └── email: String      // 邮箱
│
├── 个人信息(可选)
│   ├── location: String?   // 位置
│   ├── bio: String?       // 个人简介
│   ├── website: String?   // 个人网站
│   └── avatarExists: Bool? // 是否有头像
│
├── 社交关系
│   ├── followers: [String] // 粉丝ID列表
│   ├── following: [String] // 关注ID列表
│   └── isFollowed: Bool   // 当前用户是否关注
│
├── CodingKeys (enum)      // JSON映射
│   └── MongoDB _id 映射到 id
│
├── 初始化方法
│   ├── 标准初始化器（带默认值）
│   └── Decodable 初始化器（JSON解码）
│
└── 协议实现
    ├── Hashable 实现
    │   └── hash(into:)    // 基于 id、username、email
    ├── Equatable 实现
    │   └── == 操作符      // 基于 id、username、email
    └── Codable 实现
        └── encode(to:)    // JSON编码
```


关键特点：


1. 完整的用户模型，支持基本信息、个人资料和社交关系
2. 实现多个协议：
	- Codable：JSON序列化
	- Identifiable：唯一标识
	- Hashable：支持作为字典键或集合元素
3. 灵活的初始化支持：
	- 支持默认值
	- 支持JSON解码
	- 处理可选字段
4. 社交功能支持：
	- 关注/粉丝系统
	- 关注状态追踪

# App


我来帮你分析这个应用的主要结构（忽略注入相关代码）：

```other
App结构
├── App (主入口 @main)
│   └── ContentView
│       ├── 依赖注入
│       │   └── AuthViewModel (环境对象) -> 单例
│       │
│       └── 视图逻辑
│           ├── 已认证 (isAuthenticated == true)
│           │   └── MainView (用户已登录界面)
│           └── 未认证
│               └── WelcomeView (欢迎/登录界面)
```


关键点说明：


1. 应用入口：
	- 使用 `@main` 标记的 `DemoApp` 作为应用程序入口
	- 通过 `.environmentObject` 注入全局的 `AuthViewModel`

## WelcomeView


我来分析这个 WelcomeView 的结构：

```other
View: WelcomeView
├── 视图结构
│   └── NavigationStack
│       └── GeometryReader
│           └── VStack (主容器，spacing: 0)
│               ├── 顶部区域
│               │   └── Logo (X图标)
│               │       └── 尺寸: 40x40
│               │
│               ├── 标题文本
│               │   └── "See what's happening..."
│               │
│               ├── 按钮组 (VStack, spacing: 16)
│               │   ├── Google登录按钮
│               │   │   └── 样式：白底+灰边框胶囊形
│               │   │
│               │   ├── Apple登录按钮
│               │   │   └── 样式：白底+灰边框胶囊形
│               │   │
│               │   ├── 分隔符
│               │   │   └── "Or" + 分割线
│               │   │
│               │   └── 创建账号按钮
│               │       └── NavigationLink -> RegisterView
│               │
│               └── 底部声明
│                   ├── 服务条款文本
│                   └── 登录入口
│                       └── NavigationLink -> LoginView
│
│

```


## LoginView


我来分析这个 LoginView 的结构：

```other
View: LoginView
├── 状态管理
│   ├── 输入状态
│   │   ├── @State email: String
│   │   └── @State password: String
│   │
│   ├── 视图状态
│   │   ├── @State emailDone: Bool      // 邮箱输入完成标志
│   │   ├── @State isLoading: Bool      // 加载状态
│   │   └── @State showError: Bool      // 错误显示
│   │
│   ├── 反馈状态
│   │   ├── @State loginStatus: String  // 登录状态信息
│   │   └── @State showSuccessMessage: Bool
│   │
│   └── 环境对象
│       ├── @Environment presentationMode
│       ├── @Environment dismiss
│       └── @EnvironmentObject viewModel: AuthViewModel
│
├── 视图结构
│   └── VStack (主容器)
│       ├── 头部

│       │
│       └── 条件渲染 (!emailDone ? 邮箱视图 : 密码视图)
│           ├── 邮箱输入页
│           │   ├── 标题文本
│           │   ├── CustomAuthTextField
│           │   └── 底部按钮组
│           │       ├── Next按钮
│           │       └── 忘记密码按钮
│           │
│           └── 密码输入页
│               ├── 标题文本
│               ├── SecureAuthTextField
│               └── 底部状态区
│                   ├── 登录按钮
│                   ├── 状态信息
│                   ├── 成功提示
│                   └── 错误提示
│
```


## RegisterView


我来分析这个 RegisterView 的结构：

```other
View: RegisterView
├── 状态管理
│   ├── 输入状态
│   │   ├── @State name: String
│   │   ├── @State username: String
│   │   ├── @State email: String
│   │   └── @State password: String
│   │
│   ├── 反馈状态
│   │   ├── @State showError: Bool
│   │   ├── @State errorMessage: String
│   │   └── @State showSuccess: Bool
│   │
│   └── 环境对象
│       ├── @Environment dismiss
│       └── @EnvironmentObject viewModel: AuthViewModel
│
├── 视图结构
│   └── VStack (主容器)
│       ├── 头部
│       │   ├── 取消按钮
│       │   └── X logo (24x24)
│       │
│       ├── 标题
│       │   └── "Create your account"
│       │
│       ├── 表单区域
│       │   ├── 姓名输入框
│       │   ├── 用户名输入框
│       │   ├── 邮箱输入框
│       │   └── 密码输入框
│       │
│       └── 底部区域
│           ├── 注册按钮
│           │   └── 异步注册逻辑
│           ├── 成功提示 (条件显示)
│           └── 错误提示 (条件显示)
│
└── 交互逻辑
    └── 注册流程
        ├── 异步任务处理
        ├── 错误捕获
        ├── 成功反馈
        └── 自动关闭（1.5秒延时）
```


# Service


## AuthService

- [ ] 需要考虑的是集中使用闭包 还是 withCheckedThrowingContinuation 等swift并发的方案 哪些更合适呢？ 

```other
AuthService (认证服务类)
├── 常量定义
│   ├── requestDomain: String    // 基础域名
│   ├── registerURL: String      // 注册接口 (localhost:3000/users)
│   ├── loginURL: String         // 登录接口 (localhost:3000/users/login)
│   └── userURL: String          // 用户信息接口 (localhost:3000/users/)
│
├── 错误类型
│   ├── NetworkError: Error, LocalizedError
│   │   ├── invalidURL          // URL无效
│   │   ├── noData             // 无数据
│   │   ├── decodingError      // 解码错误
│   │   └── custom(String)     // 自定义错误
│   │
│   └── AuthenticationError: Error, LocalizedError
│       ├── invalidCredentials  // 认证失败
│       └── custom(String)      // 自定义错误
│
├── 核心网络请求
│   └── makeRequest() -> Void
│       ├── 参数
│       │   ├── urlString: String
│       │   ├── requestBody: [String: Any]
│       │   └── completion: @escaping (Result<Data, NetworkError>) -> Void
│       ├── 请求配置
│       │   ├── HTTP方法: POST
│       │   └── Content-Type: application/json
│       └── 错误处理流程
│           ├── URL验证
│           ├── JSON序列化
│           ├── HTTP状态码检查 (200-299)
│           └── 数据存在性检查
│
├── 数据模型
│   └── APIResponse: Codable
│       ├── user: User
│       └── token: String?      // 可选token
│
└── 认证方法
    ├── register() -> Void
    │   ├── 参数
    │   │   ├── email, username, password, name: String
    │   │   └── completion: @escaping (Result<User, AuthenticationError>) -> Void
    │   └── 特点：异步，JSON解码为User对象
    │
    ├── login() -> Void
    │   ├── 参数
    │   │   ├── email, password: String
    │   │   └── completion: @escaping (Result<APIResponse, AuthenticationError>) -> Void
    │   └── 特点：异步，返回用户信息和token
    │
    ├── fetchUser() -> Void
    │   ├── 参数
    │   │   ├── userId, token: String
    │   │   └── completion: @escaping (Result<User, AuthenticationError>) -> Void
    │   ├── 特点
    │   │   ├── GET请求
    │   │   ├── Bearer Token认证
    │   │   └── 异步返回用户信息
    │   
    ├── makePatchRequestWithAuth() -> Void
    │   ├── 参数
    │   │   ├── urlString: String
    │   │   ├── requestBody: [String: Any]
    │   │   ├── token: String
    │   │   └── completion: @escaping (Result<Data, NetworkError>) -> Void
    │   ├── 特点
    │   │   ├── PATCH请求
    │   │   ├── Bearer Token认证
    │   │   └── 支持通用数据更新
    │
    └── fetchUsers() -> Void
        ├── 参数
        │   └── completion: @escaping (Result<Data?, AuthenticationError>) -> Void
        └── 特点
            ├── GET请求
            ├── 返回可选Data
            └── 基础错误处理
```


关键特点补充：


1. 所有网络请求方法都是异步的，使用 completion handler 回调
2. 统一使用 Result 类型处理成功/失败情况
3. 错误类型实现了 LocalizedError 协议，支持本地化错误描述
4. 认证相关方法都基于基础 makeRequest 封装，保持了代码的一致性
5. 支持 Bearer Token 认证机制
6. 完整的错误处理链，从网络到数据解析

## RequestService


让我帮你分析这个 RequestServices 类的结构：

```other
RequestServices (网络请求服务类)
├── 数据模型
│   ├── FollowResponse: Codable
│   │   └── message: String
│   ├── LikeResponse: Codable
│   │   └── message: String
│   └── ErrorResponse: Codable
│       └── message: String
│
├── 错误处理
│   └── NetworkError: LocalizedError
│       ├── 错误类型
│       │   ├── invalidURL
│       │   ├── noData
│       │   ├── noToken
│       │   └── custom(String)
│       └── errorDescription: String?
│
├── 配置
│   └── requestDomain: String (静态变量)
│
└── API方法
    ├── postTweet()
    │   ├── 参数：text, user, username, userId
    │   ├── 返回：@escaping (Result<[String: Any]?, Error>) -> Void
    │   └── HTTP：POST /tweets
    │
    ├── fetchTweets()
    │   ├── 参数：无
    │   ├── 返回：@escaping (Result<Data, Error>) -> Void
    │   └── HTTP：GET /
    │
    ├── followingProcess()
    │   ├── 参数：userId, isFollowing
    │   ├── 返回：@escaping (Result<FollowResponse, Error>) -> Void
    │   └── HTTP：PUT /users/{userId}/follow|unfollow
    │
    ├── likeTweet()
    │   ├── 参数：tweetId, isLiked
    │   ├── 返回：@escaping (Result<LikeResponse, Error>) -> Void
    │   └── HTTP：PUT /tweets/{tweetId}/like|unlike
    │
    ├── fetchData()
    │   ├── 参数：无
    │   ├── 返回：@escaping (Result<Data?, NetworkError>) -> Void
    │   └── HTTP：GET /notifications
    │
    └── sendNotification()
        ├── 参数：username, notSenderId, notReceiverId, notificationType, postText
        ├── 返回：@escaping ([String: Any]?) -> Void
        └── HTTP：POST /notifications
```


共同特点：


1. 所有方法都是静态方法
2. 统一的错误处理机制
3. 使用 Bearer Token 认证
4. JSON 数据交互
5. 异步回调处理（@escaping closure）
6. 完整的请求-响应周期处理

这个服务类实现了一个完整的社交媒体后端 API 交互层，包括发推、点赞、关注等核心功能。  
  
  
  


# Main


## MainView


让我帮你分析这个 MainView 的结构：

```other
MainView (主视图)
├── 状态管理
│   ├── @State
│   │   ├── navigationPath: NavigationPath   // 导航路径
│   │   ├── showMenu: Bool                  // 侧边栏显示状态
│   │   ├── showProfile: Bool               // 个人资料显示状态
│   │   ├── offset: CGFloat                 // 侧边栏偏移量
│   │   ├── selectedTab: Int                // 当前选中的标签页
│   │   ├── searchText: String              // 搜索文本
│   │   └── isSearching: Bool               // 搜索状态
│   │
│   └── @EnvironmentObject
│       └── viewModel: AuthViewModel         // 认证视图模型
│
├── 计算属性
│   └── menuWidth: CGFloat                   // 侧边栏宽度 (屏幕宽度-90)
│
├── 视图层次 (body)
│   └── NavigationStack
│       └── ZStack (alignment: .leading)
│           ├── 主内容区
│           │   └── VStack
│           │       ├── TopBar              // 顶部栏
│           │       └── HomeView            // 主页视图
│           │
│           ├── 灰色遮罩层
│           │   └── 点击关闭菜单功能
│           │
│           ├── 侧边菜单 (SlideMenu)
│           │   └── 点击显示个人资料
│           │
│           └── 拖拽手势区域
│               ├── 菜单展开状态
│               └── 菜单关闭状态
│
└── 手势处理
    ├── dragGesture
    │   ├── onChanged                       // 拖动时更新偏移量
    │   └── onEnded                         // 拖动结束时判断展开/收起
    │
    └── 辅助方法
        ├── openMenu()                      // 打开菜单
        └── closeMenu()                     // 关闭菜单
```


关键特点：


1. 使用 NavigationStack 管理导航
2. 实现了可拖拽的侧边菜单
3. 支持搜索功能
4. 多层状态管理
5. 复杂的手势处理逻辑
6. 动画过渡效果

这是一个典型的 Twitter 风格主界面实现，包含了侧边栏、顶部栏和主内容区域的布局结构。  
  
  
  


## HomeView


我来分析 HomeView 的结构：

```other
HomeView: View
├── 状态管理
│   ├── @EnvironmentObject viewModel: AuthViewModel  // 全局认证状态
│   ├── @ObserveInjection inject                    // 注入观察器
│   ├── @Binding selectedTab: Int                   // 选中标签页
│   ├── @State showCreateTweetView: Bool            // 发推窗口状态
│   ├── @Binding searchText: String                 // 搜索文本
│   └── @Binding isSearching: Bool                  // 搜索状态
│
└── 视图结构 (ZStack)
    ├── 主要内容 (TabView)
    │   ├── Tab 0: FeedView
    │   │   └── 图标: "house" + "Home"
    │   │
    │   ├── Tab 1: SearchView
    │   │   ├── 参数: searchText, isEditing
    │   │   └── 图标: "magnifyingglass" + "Search"
    │   │
    │   ├── Tab 2: NotificationsView
    │   │   ├── 参数: user (强制解包)
    │   │   └── 图标: "bell" + "Notifications"
    │   │
    │   ├── Tab 3: MessagesView
    │   │   └── 图标: "envelope" + "Messages"
    │   │
    │   └── 配置
    │       ├── sheet: CreateTweetView
    │       └── accentColor: Color("BG")
    │
    └── 浮动按钮 (Button)
        ├── 触发动作: showCreateTweetView = true

```


## AuthViewModel


```other
AuthViewModel (认证视图模型)
├── 类定义与协议
│   ├── class AuthViewModel: ObservableObject
│   └── 单例实现
│       └── static let shared = AuthViewModel()
│
├── 状态属性 (@Published)
│   ├── isAuthenticated: Bool     // 用户认证状态
│   ├── user: User?              // 当前用户信息
│   └── error: Error?            // 错误状态
│
├── 持久化存储 (@AppStorage)
│   ├── token: String            // JWT认证令牌
│   │   └── 存储键："jwt"
│   └── userId: String           // 用户唯一标识
│       └── 存储键："userId"
│
├── 初始化与状态检查
│   ├── private init()           
│   │   └── 特点：私有初始化确保单例模式
│   └── checkAuthStatus()
│       ├── 条件：token和userId非空
│       └── 行为：调用fetchUser()
│
├── 认证方法
│   ├── login(email:password:)
│   │   ├── 参数
│   │   │   ├── email: String
│   │   │   └── password: String
│   │   ├── 处理流程
│   │   │   ├── 调用AuthService.login
│   │   │   ├── 主线程更新UI
│   │   │   └── 错误处理
│   │   └── 状态更新
│   │       ├── token
│   │       ├── userId
│   │       ├── user
│   │       └── isAuthenticated
│   │
│   ├── register(name:username:email:password:) async throws
│   │   ├── 参数
│   │   │   ├── name: String
│   │   │   ├── username: String
│   │   │   ├── email: String
│   │   │   └── password: String
│   │   ├── 异步实现
│   │   │   └── withCheckedThrowingContinuation
│   │   ├── 处理流程
│   │   │   ├── 调用AuthService.register
│   │   │   ├── 主线程更新UI
│   │   │   └── 自动登录获取token
│   │   └── 错误处理
│   │       └── 传递AuthenticationError
│   │
│   └── signOut()
│       └── 状态清理
│           ├── isAuthenticated = false
│           ├── user = nil
│           ├── token = ""
│           └── userId = ""
│
├── 用户信息管理
│   ├── fetchUser()
│   │   ├── 前置条件
│   │   │   ├── token非空
│   │   │   └── userId非空
│   │   ├── 处理流程
│   │   │   ├── 调用AuthService.fetchUser
│   │   │   └── 主线程更新状态
│   │   └── 错误处理
│   │       └── 失败时调用signOut
│   │
│   ├── updateUser()
│   │   ├── 参数：updatedUser: User
│   │   └── 特点：主线程异步更新
│   │
│   ├── updateCurrentUser()
│   │   ├── 参数
│   │   │   ├── updatedUser: User
│   │   │   └── transaction: Transaction
│   │   └── 特点：仅更新关注数据
│   │
│   └── silentlyUpdateFollowing()
│       ├── 参数：following: [String]
│       └── 特点：静默更新不触发UI
│
└── 待实现功能
    └── validateToken()
        └── TODO: Token验证逻辑
```


这个树结构更详细地展示了：


1. 每个方法的具体参数
2. 异步操作的实现细节
3. 状态管理的完整流程
4. 错误处理机制
5. 数据持久化策略
6. UI更新的线程处理

## SildeMenu


让我为 SlideMenu 创建一个详细的结构树：

```other
SlideMenu (侧边菜单视图)
├── 属性定义
│   ├── 状态管理
│   │   ├── @EnvironmentObject
│   │   │   └── authViewModel: AuthViewModel    // 用户认证状态
│   │   │
│   │   └── @State
│   │       ├── showSettings: Bool             // 设置页面显示状态
│   │       └── isExpanded: Bool              // 展开状态
│   │
│   ├── 回调属性
│   │   └── onProfileTap: () -> Void          // 个人资料点击回调
│   │
│   └── 计算属性
│       └── avatarURL: URL?                    // 头像URL构建
│           └── 基于用户ID构建完整头像地址
│
├── 视图结构 (body)
│   └── VStack (alignment: .leading)
│       ├── 顶部用户信息区域
│       │   └── HStack (alignment: .top)
│       │       ├── 用户信息按钮
│       │       │   ├── 头像显示
│       │       │   │   ├── KFImage (Kingfisher)
│       │       │   │   └── 占位图 (Circle)
│       │       │   └── 用户信息
│       │       │       ├── 用户名
│       │       │       └── @用户名
│       │       │
│       │       └── 展开按钮
│       │           └── chevron.down 图标
│       │
│       ├── 关注信息区域
│       │   └── HStack
│       │       ├── Following 计数
│       │       └── Followers 计数
│       │
│       ├── 主菜单列表
│       │   └── VStack
│       │       └── ForEach 循环
│       │           ├── Profile
│       │           ├── Lists
│       │           ├── Topics
│       │           ├── Bookmarks
│       │           └── Moments
│       │
│       └── 底部区域
│           └── VStack
│               ├── Settings and privacy 按钮
│               ├── Help Center 文本
│               └── 工具图标
│                   ├── lightbulb
│                   └── qrcode
│
└── 修饰器
    ├── .sheet                    // 设置页面模态展示
    ├── .padding                  // 内边距设置
    ├── .frame                    // 框架尺寸
  

特点：
1. 层级清晰的视图结构
2. 响应式状态管理
3. 外部数据依赖 (AuthViewModel)
4. 自定义导航回调
5. 第三方组件集成 (Kingfisher)
6. 统一的样式定义
7. 模态页面支持
```


这个视图实现了一个完整的 Twitter 风格侧边菜单，包含用户信息展示、导航功能和设置入口。

# Profile


## ProfileView


让我帮你分析 ProfileView 的结构和关键功能：

```other
ProfileView
├── 偏移量追踪 (PreferenceKey)
│   ├── ScrollOffsetPreferenceKey     // 通用滚动偏移
│   └── TabBarOffsetPreferenceKey     // TabBar 偏移
│
├── 状态管理
│   ├── @StateObject
│   │   └── viewModel: ProfileViewModel  // 用户资料数据
│   │
│   ├── @State
│   │   ├── offset: CGFloat          // Banner 滚动偏移
│   │   ├── titleOffset: CGFloat     // 标题区域偏移
│   │   ├── tabBarOffset: CGFloat    // TabBar 偏移
│   │   ├── showEditProfile: Bool    // 编辑页面展示状态 -> 回调触发profile
│   │   └── currentTab: String       // 当前选中标签
│   │
│   └── @Environment
│       ├── colorScheme              // 暗黑/明亮模式
│       └── dismiss                  // 返回操作
│
├── 视图层级
│   ├── 1. Banner + Title
│   │   ├── 背景图片（支持拉伸效果）
│   │   ├── 模糊效果层
│   │   └── 动态标题（滚动渐隐）
│   │
│   ├── 2. Profile Info
│   │   ├── 头像（支持缩放和位移）
│   │   ├── 编辑/关注按钮
│   │   ├── 用户信息（名称、用户名）
│   │   ├── 个人简介
│   │   ├── 位置和网站
│   │   └── 关注者统计
│   │
│   ├── 3. TabBar
│   │   └── 水平滚动菜单（Tweets/Replies/Media/Likes）
│   │
│   └── 4. Tweets List
│       └── 推文列表（使用 TweetCellView）
    --- 5. sheet -> 触发 Editprofileview()


│
└── 动画效果
    ├── getTitleTextOffset()    // 标题滑动消失动画
    ├── getOffset()            // 头像上移动画
    ├── getScale()            // 头像缩放动画
    └── blurViewOpacity()     // Banner 模糊渐变

特点：
1. 使用 zIndex 管理视图层级
2. 复杂的滚动交互效果
3. 响应式布局
4. 完整的用户资料展示
5. GeometryReader 实现的精确布局控制
```


这是一个复杂的个人资料页面实现，包含了多层次的视图结构和丰富的交互动画效果。使用了多个 PreferenceKey 来追踪滚动状态，并基于这些状态实现了流畅的动画效果。

### GeometryReader 的使用


让我详细解释一下这段代码中 GeometryReader 的使用：

在这个 ProfileView 中，GeometryReader 主要用于实现 Twitter 风格的个人资料页面动态效果，具体分析如下：


1. Banner 区域的动态效果：

```swift
GeometryReader { proxy -> AnyView in
    let minY = proxy.frame(in: .global).minY
    
    return AnyView(
        ZStack {
            // Banner 图片动态效果
            Image("SC_banner")
                .frame(
                    width: getRect().width,
                    height: minY > 0 ? 180 + minY : 180  // 关键点1：下拉拉伸
                )
                .offset(y: minY > 0 ? -minY : 0)        // 关键点2：保持顶部对齐
```


核心实现原理：


1. `proxy.frame(in: .global).minY` 获取当前视图相对于全局的 Y 轴偏移量：
	- 当下拉时，minY > 0
	- 当上滑时，minY < 0
2. Banner 高度动态调整：
	- 下拉时：`180 + minY` 使 Banner 高度增加
	- 上滑时：保持 180 基础高度
3. 位置补偿：
	- `.offset(y: minY > 0 ? -minY : 0)` 确保 Banner 始终贴合顶部
	- 下拉时通过负偏移抵消增加的高度的一半，产生视差效果
4. 滚动效果联动：

```swift
.offset(y: minY > 0 ? -minY : -minY < 80 ? 0 : -minY - 80)
.onAppear {
    DispatchQueue.main.async {
        offset = minY  // 保存偏移量用于其他动画
    }
}
```


这种实现方式的优点：


1. 实时响应滚动事件
2. 流畅的动画效果
3. 精确的布局控制
4. 多个视图元素的联动（Banner、标题、头像等）

通过 GeometryReader，我们可以：


- 获取精确的布局信息
- 实现复杂的滚动效果
- 控制视图的动态大小和位置
- 创建流畅的交互动画

这是实现类似 Twitter、Instagram 等应用中常见的视差滚动效果的关键技术。

## ProfileViewModel


让我帮你分析 ProfileViewModel 的结构和功能：

```other
ProfileViewModel (用户资料视图模型)
├── 状态属性 (@Published)
│   ├── tweets: [Tweet]           // 用户的推文列表
│   ├── user: User               // 当前显示的用户信息
│   ├── shouldRefreshImage: Bool  // 是否需要刷新头像
│   ├── error: Error?            // 错误信息
│   └── isFollowing: Bool        // 是否关注该用户
│
├── 私有属性
│   ├── tweetViewModels: [String: TweetCellViewModel]  // 推文视图模型缓存
│   ├── lastImageRefreshTime: TimeInterval            // 上次头像刷新时间
│   ├── cancellables: Set<AnyCancellable>            // Combine 订阅存储
│   └── userId: String?                               // 目标用户ID
│
├── 计算属性
│   └── isCurrentUser: Bool
        (使用 authViewModel单例来判断)      // 判断是否为当前登录用户
│
├── 初始化和数据加载
│   ├── init(userId: String?)    // 初始化方法
│   │   ├── 设置初始用户数据
│   │   └── 根据是否为当前用户决定数据加载方式
│   │
│   ├── fetchUserData()          // 获取用户数据
│   └── fetchTweets()           // 获取用户推文
│
├── 视图模型管理
│   ├── getTweetCellViewModel()  // 获取或创建推文单元视图模型
│   ├── cleanupTweetViewModels() // 清理未使用的视图模型
│   └── getAvatarURL()          // 获取带时间戳的头像URL
│
└── 社交功能
    ├── checkIfUserIsFollowed() // 检查关注状态
    ├── follow()               // 关注用户
    │   ├── 更新本地用户数据
    │   └── 更新全局用户状态
    │
    └── unfollow()            // 取消关注
        ├── 更新本地用户数据
        └── 更新全局用户状态
```


# EditProfile


## EditProfileView


让我帮你分析 EditProfileView 的结构和关键实现：

```other
EditProfileView
├── 状态管理
│   ├── 环境变量
│   │   ├── @Environment(\.presentationMode)  // 控制视图展示状态
│   │   └── @EnvironmentObject authViewModel  // 全局认证状态
│   │
│   ├── 视图模型
│   │   └── @StateObject viewModel: EditProfileViewModel
│   │
│   ├── 用户输入状态 (@State)
│   │   ├── name, location, bio, website     // 文本输入
│   │   ├── profileImage, bannerImage        // 已选择的图片
│   │   ├── showImagePicker                  // 图片选择器显示状态
│   │   ├── selectedImage                    // 临时选中的图片
│   │   └── imagePickerType                  // 当前编辑的图片类型
│   │
│   └── 图片选择类型
│       └── enum ImagePickerType { banner, profile }
│
├── 视图层级 (ZStack)
│   ├── 1. 滚动内容区域
│   │   ├── Banner图片编辑
│   │   │   ├── 图片预览/占位
│   │   │   └── 编辑按钮
│   │   │
│   │   ├── 头像编辑
│   │   │   ├── 图片预览/占位
│   │   │   └── 编辑按钮
│   │   │
│   │   └── 个人信息表单
│   │       ├── Name
│   │       ├── Location
│   │       ├── Bio
│   │       └── Website
│   │
│   ├── 2. 顶部导航栏
│   │   ├── Cancel按钮
│   │   └── Save按钮
│   │
│   └── 3. 图片选择器(.sheet)
│       └── ImagePicker
│
└── 生命周期处理
    ├── onAppear: 清除图片缓存
    └── onReceive: 处理保存完成事件

特点：
1. 复杂的状态管理
2. 多层嵌套的视图结构
3. 自定义输入组件
4. 图片处理功能
5. 实时预览效果
```


关键实现细节：


1. 使用 ZStack 实现导航栏覆盖效果
2. 通过 GeometryReader 实现精确的布局控制
3. 使用 sheet 模态展示图片选择器
4. 实现了图片缓存清理机制
5. 统一的表单样式和布局

这是一个典型的个人资料编辑页面实现，包含了完整的表单处理和图片编辑功能。

## EditProfileViewModel

- [ ] 哪些是可选的哪些是不可选
- [ ] authviewModel 到底在哪里注入 合适还是从根本上断绝
- [ ] 现在出现的问题是 UI更新的问题 要么数据无法更新时全局相关数据都更新 要不就是 更新导致的多视图刷新导致一种闪屏（尤其是authviewModel的user 改变因为 authviewModel全局注入导致了很多视图都有其属性 就很麻烦）

让我帮你分析 EditProfileView 的结构和关键实现：

```other
EditProfileView
├── 状态管理
│   ├── 环境变量
│   │   ├── @Environment(\.presentationMode)  // 控制视图展示状态
│   │   └── @EnvironmentObject authViewModel  // 全局认证状态
│   │
│   ├── 视图模型
│   │   └── @StateObject viewModel: EditProfileViewModel
│   │
│   ├── 用户输入状态 (@State)
│   │   ├── name, location, bio, website     // 文本输入
│   │   ├── profileImage, bannerImage        // 已选择的图片
│   │   ├── showImagePicker                  // 图片选择器显示状态
│   │   ├── selectedImage                    // 临时选中的图片
│   │   └── imagePickerType                  // 当前编辑的图片类型
│   │
│   └── 图片选择类型
│       └── enum ImagePickerType { banner, profile }
│
├── 视图层级 (ZStack)
│   ├── 1. 滚动内容区域
│   │   ├── Banner图片编辑
│   │   │   ├── 图片预览/占位
│   │   │   └── 编辑按钮
│   │   │
│   │   ├── 头像编辑
│   │   │   ├── 图片预览/占位
│   │   │   └── 编辑按钮
│   │   │
│   │   └── 个人信息表单
│   │       ├── Name
│   │       ├── Location
│   │       ├── Bio
│   │       └── Website
│   │
│   ├── 2. 顶部导航栏
│   │   ├── Cancel按钮
│   │   └── Save按钮
│   │
│   └── 3. 图片选择器(.sheet)
│       └── ImagePicker
│
└── 生命周期处理
    ├── onAppear: 清除图片缓存
    └── onReceive: 处理保存完成事件

特点：
1. 复杂的状态管理
2. 多层嵌套的视图结构
3. 自定义输入组件
4. 图片处理功能
5. 实时预览效果
```


# CreateTweet


## CreateTweetView


我来分析 CreateTweetView 的结构：

```other
CreateTweetView: View
├── 状态管理
│   ├── @ObserveInjection inject              // 注入观察
│   ├── @Environment(\.dismiss) dismiss        // 视图关闭控制
│   ├── @State tweetText: String              // 推文内容
│   ├── @StateObject viewModel                // 发推视图模型
│   │
│   └── 图片相关状态
│       ├── @State imagePickerPresented: Bool  // 图片选择器显示控制
│       ├── @State selectedImage: UIImage?     // 选中的原始图片
│       ├── @State postImage: Image?          // 用于显示的SwiftUI图片
│       └── @State width: CGFloat             // 屏幕宽度缓存
│
└── 视图结构 (VStack)
    ├── 顶部栏 (HStack)
    │   ├── 取消按钮
    │   └── 发送按钮
    │       └── 条件：tweetText非空时启用
    │
    ├── 文本输入区
    │   └── MultilineTextField
    │       ├── 双向绑定：$tweetText
    │       └── 占位文本："有什么新鲜事？"
    │
    ├── 图片预览区 (条件显示)
    │   └── 图片视图
    │       ├── 宽度：屏幕90%
    │       └── 圆角和裁剪处理
    │
    ├── 底部工具栏 (HStack)
    │   ├── 图片选择按钮
    │   └── 字数统计 (280字限制)
    │
    └── 图片选择器 (Sheet)
        ├── ImagePicker
        └── 选择后处理：loadImage()

扩展功能：
└── loadImage()
    └── 将UIImage转换为SwiftUI的Image
```


## CreateTweetViewModel


我来分析 CreateTweetViewModel 的结构：

```other
CreateTweetViewModel: ObservableObject
├── 主要方法
│   └── uploadPost(text: String, image: UIImage?)
│       ├── 参数
│       │   ├── text: 推文内容
│       │   └── image: 可选图片
│       │
│       ├── 执行流程
│       │   ├── 1. 用户验证
│       │   │   └── 通过 AuthViewModel.shared.user 获取
│       │   │
│       │   ├── 2. 配置请求
│       │   │   └── 设置域名为 localhost:3000
│       │   │
│       │   ├── 3. 发送推文
│       │   │   ├── 调用 RequestServices.postTweet
│       │   │   └── 参数：text, user, username, userId
│       │   │
│       │   └── 4. 异步处理响应（主线程）
│       │       ├── 成功：检查并处理图片上传
│       │       └── 失败：打印错误信息
│
└── 私有辅助方法
    └── uploadTweetImage(image: UIImage, tweetId: String)
        ├── 参数
        │   ├── image: 要上传的图片
        │   └── tweetId: 关联的推文ID
        │
        ├── 实现细节
        │   ├── 使用 ImageUploader.uploadImage
        │   ├── 固定文件名：tweet.png
        │   └── URL路径：/tweets/{tweetId}/image
        │
        └── 响应处理（主线程）
            ├── 成功：打印上传成功信息
            └── 失败：打印错误信息
```


关键特点：


1. 异步操作处理：
	- 所有网络请求回调都在主线程处理
	- 使用 completion handlers 处理异步结果
2. 依赖关系：
	- 依赖 AuthViewModel 获取用户信息
	- 依赖 RequestServices 发送推文
	- 依赖 ImageUploader 处理图片上传
3. 错误处理：
	- 用户验证失败保护
	- 网络请求错误处理
	- 图片上传错误处理
4. 业务流程：
	- 先发送文本内容
	- 成功后再处理图片上传
	- 两步操作解耦
5. 注意事项：
	- 硬编码的服务器地址
	- 固定的图片文件名
	- 缺少上传状态的外部通知机制

# Feed


## FeedView

- [ ] 全局的用户认证非常重要，几乎你与任何用户的交互都基于自己的身份，但是如何避免这个变量的污染呢，如何掌握到一个度呢？？ 

```other
FeedView: View
├── 状态管理
│   ├── @EnvironmentObject authViewModel: AuthViewModel  // 全局认证状态
│   └── @StateObject viewModel: FeedViewModel           // 视图本地状态
│
└── 视图结构
    └── ScrollView
        └── LazyVStack (spacing: 0)                     // 懒加载列表容器
            └── ForEach(viewModel.tweets)               // 推文列表循环
                ├── TweetCellView                       // 单条推文视图
                │   └── 参数
                │       ├── tweet: Tweet                // 推文数据
                │       └── currentUser: User           // 当前用户
                │
                ├── 样式
                │   └── padding(.horizontal, 10)        // 水平内边距
                │
                └── Divider                            // 分隔线
                    └── padding()                      // 四周内边距

    特性：
    1. refreshable      // 支持下拉刷新
    2. LazyVStack      // 优化性能，按需加载
```


关键点说明：


1. 视图状态管理：
	- 使用 `@StateObject` 管理本地推文列表状态
	- 通过 `@EnvironmentObject` 访问全局用户认证状态
2. 性能优化：
	- 使用 `LazyVStack` 实现列表懒加载
	- 通过 `ForEach` 高效渲染推文列表
3. 用户体验：
	- 实现下拉刷新功能
	- 统一的推文卡片样式和间距
4. 数据流：
	- ViewModel 管理推文数据
	- 当前用户信息从 AuthViewModel 获取

这是一个典型的 SwiftUI 列表视图实现，采用了 MVVM 架构模式。

## FeedViewModel


我来分析 FeedViewModel 的详细结构：

```other
FeedViewModel: ObservableObject
├── 属性
│   ├── 发布属性 (@Published)
│   │   ├── tweets: [Tweet]     // 推文列表
│   │   └── user: User         // 当前用户
│   │
│   └── 私有属性
│       ├── cancellables: Set<AnyCancellable>  // Combine订阅存储
│       └── refreshTimer: AnyCancellable?      // 定时刷新计时器
│
├── 初始化器 (init)
│   ├── 用户初始化
│   │   └── 从 AuthViewModel.shared 获取用户
│   │
│   ├── 用户更新订阅
│   │   └── Combine 处理流程
│   │       ├── compactMap     // 过滤空值
│   │       ├── receive       // 主线程处理
│   │       ├── sink          // 处理更新
│   │       └── store         // 存储订阅
│   │
│   └── 初始数据获取
│       └── fetchTweets()    // 获取推文列表
│
├── 网络请求 (fetchTweets)
│   ├── 配置
│   │   └── 设置请求域名
│   │
│   ├── 数据处理
│   │   ├── 成功情况
│   │   │   ├── JSON解码
│   │   │   └── UI更新 (主线程)
│   │   │       └── 优化：比较后更新
│   │   └── 错误处理
│   │       ├── 网络错误
│   │       └── 解码错误
│   │
├── 用户交互
│   └── refresh()           // 手动刷新方法
│
└── 资源管理
    └── deinit             // 清理订阅和计时器

特点：
1. 响应式编程
   - 使用 Combine 框架
   - 支持数据流的响应式更新

2. 内存管理
   - 使用 weak self 避免循环引用
   - deinit 中清理资源

3. 线程处理
   - 网络请求异步处理
   - UI更新确保在主线程

4. 性能优化
   - 数据比较后更新
   - 取消订阅避免内存泄露
```


关键实现细节：


1. 采用 MVVM 架构模式
2. 使用 Combine 实现响应式数据流
3. 完整的错误处理和日志记录
4. 支持手动刷新和自动刷新（已注释的定时器功能）
5. 线程安全的数据更新机制

# Tweet


## Tweet 


```javascript
Model: Tweet (Identifiable, Decodable, Equatable)
├── Properties
│   ├── _id: String          // MongoDB 文档唯一标识
│   ├── text: String         // 推文内容
│   ├── userId: String       // 用户ID
│   ├── username: String     // 用户名
│   ├── user: String         // 用户显示名称
│   ├── image: Bool?         // 可选，是否包含图片
│   ├── likes: [String]?     // 可选，点赞用户ID数组
│   └── didLike: Bool?       // 可选，当前用户是否点赞
│
├── Computed Property
│   └── id: String          // 实现 Identifiable 协议，返回 _id
│
├── CodingKeys (enum)       // JSON 解码键映射
│   ├── _id
│   ├── text
│   ├── userId
│   ├── username
│   ├── user
│   ├── image
│   └── likes
│
└── Custom Decoder
    └── init(from decoder:) // 自定义解码逻辑
        ├── 基础字段解码
        └── 用户信息解码处理
            ├── 支持嵌套字典格式
            └── 支持扁平字符串格式
```


关键点说明：


1. 这是一个推文数据模型，实现了三个协议：
	- Identifiable：提供唯一标识
	- Decodable：支持 JSON 解码
	- Equatable：支持相等性比较
2. 解码器支持两种格式的用户信息：
	- 嵌套字典格式：userId 是一个包含 _id、name、username 的字典
	- 扁平字符串格式：直接存储 userId、user、username
3. 点赞相关字段（likes、didLike）为可选类型，支持后续功能扩展

## TweetCellView


我来分析 TweetCellView 的详细结构：

```other
TweetCellView: View
├── 状态管理
│   └── @ObservedObject viewModel: TweetCellViewModel  // 视图模型
│
├── 计算属性
│   └── didLike: Bool  // 点赞状态
│
├── 主视图结构 (VStack)
│   ├── 点赞信息条 (条件显示)
│   │   └── HStack
│   │       ├── 心形图标
│   │       └── 点赞数量
│   │
│   └── 主要内容 (HStack)
│       ├── 左侧头像区域
│       │   └── NavigationLink -> ProfileView
│       │       └── 条件渲染
│       │           ├── 加载中：ProgressView
│       │           └── 加载完成：KFImage (Kingfisher)
│       │
│       └── 右侧内容区域 (VStack)
│           ├── 用户信息栏
│           │   ├── 用户名
│           │   ├── @用户名
│           │   ├── 分隔点
│           │   └── 时间
│           │
│           ├── 推文文本
│           │   └── 最大高度限制：100
│           │
│           ├── 图片区域 (条件显示)
│           │   └── GeometryReader
│           │       └── KFImage
│           │
│           └── 互动按钮栏
│               ├── 评论按钮
│               ├── 转发按钮
│               ├── 点赞按钮 (可交互)
│               └── 分享按钮
│
└── 子视图
    └── InteractionButton
        ├── 属性
        │   ├── image: String
        │   └── count: Int?
        └── 布局
            └── HStack
                ├── 图标
                └── 数量 (可选)

特点：
1. 布局优化
   - 使用 GeometryReader 处理图片
   - zIndex 控制层级
   - contentShape 优化点击区域

2. 性能考虑
   - 懒加载图片 (Kingfisher)
   - 条件渲染
   - 最大高度限制

3. 用户体验
   - 加载状态显示
   - 交互反馈
   - 统一的视觉风格
```


关键实现细节：


1. 使用 Kingfisher 处理图片加载和缓存
2. 完整的推文卡片布局，包含用户信息、内容、图片和互动按钮
3. 响应式设计，支持动态内容
4. 统一的样式和间距处理
5. 可复用的交互按钮组件

## TweetCellViewModel

- [ ] 不要让viewModel 涉及 后端逻辑层的东西

我来分析 TweetCellViewModel 的详细结构：

```other
TweetCellViewModel: ObservableObject
├── 发布属性
│   ├── @Published tweet: Tweet      // 推文数据
│   ├── @Published user: User?       // 用户数据（可选）
│   ├── @Published isLoading: Bool   // 加载状态
│   └── currentUser: User           // 当前用户（常量）
│
├── 初始化
│   └── init(tweet:currentUser:)
│       ├── 属性设置
│       ├── 检查点赞状态
│       └── 获取用户信息
│
├── 网络请求
│   └── fetchUser()  -> 很明显这里的请求配置应该集成到服务层
│       ├── 加载状态管理
│       ├── Token 验证
│       ├── 请求配置
│       │   ├── URL 构建
│       │   └── Bearer Token
│       └── 异步数据处理
│           ├── 主线程更新 UI
│           └── 用户数据解码
│
├── URL 构建方法
│   ├── getUserAvatarURL() -> URL?
│   │   └── 构建用户头像URL
│   │
│   └── imageUrl -> URL?
│       └── 构建推文图片URL
│
└── 交互功能
    ├── checkIfUserLikedTweet()
    │   └── 检查当前用户是否点赞
    │
    └── likeTweet()
        ├── 点赞状态切换
        ├── 本地数据更新
        │   ├── 添加/移除点赞
        │   └── 更新点赞列表
        └── 发送通知
            └── 点赞时发送通知

特点：
1. 内存管理
   - 使用 weak self 避免循环引用
   - 可选值安全解包

2. 线程处理
   - 网络请求异步执行
   - UI 更新在主线程

3. 错误处理
   - URL 验证
   - 数据解码错误处理
   - 网络请求错误处理

4. 状态管理
   - 加载状态追踪
   - 点赞状态实时更新
```


# Notification  



我来分析这个 Notification Model 的结构：

```other
Model: Notification (Decodable, Identifiable)
├── 基础属性
│   ├── _id: String          // 数据库ID
│   ├── username: String     // 用户名
│   ├── notSenderId: String  // 通知发送者ID
│   ├── notReceiverId: String // 通知接收者ID
│   ├── postText: String?    // 可选，相关推文内容
│   └── notificationType: NotificationType // 通知类型
│
├── 计算属性
│   └── id: String          // 实现 Identifiable 协议，返回 _id
│
└── NotificationType (enum: String, Decodable)
    ├── 枚举值
    │   ├── like           // 点赞通知
    │   └── follow         // 关注通知
    │
    └── notificationMessage: String  // 计算属性
        ├── like -> "liked your Tweet"
        └── follow -> "followed you"
```


关键特点：


1. 通知模型支持两种主要交互：
	- 点赞通知
	- 关注通知
2. 实现的协议：
	- Decodable：支持从JSON解码
	- Identifiable：提供唯一标识
3. 灵活的设计：
	- 支持可选的推文内容（postText）
	- 通过枚举类型管理不同类型的通知
	- 通知消息文本的本地化处理
4. 完整的通知追踪：
	- 记录发送者ID
	- 记录接收者ID
	- 包含相关用户名

这个模型设计简洁但完整，能够支持基本的社交互动通知功能。

## NotificationsView


```other
View: NotificationsView
├── 属性
│   ├── user: User                              // 当前用户
│   ├── @ObservedObject viewModel: NotificationsViewModel  // 视图模型
│   ├── @State isLoading: Bool                 // 加载状态
│   └── @State errorMessage: String?           // 错误信息
│
└── 视图层次 (VStack)
    ├── 加载状态 (isLoading == true)
    │   └── ProgressView
    │       └── 超时处理 (5秒)
    │           └── 显示错误信息
    │
    ├── 错误状态 (errorMessage != nil)
    │   └── VStack
    │       ├── 错误文本
    │       └── 重试按钮
    │           └── 重置状态并重新加载
    │
    └── 内容状态
        └── ScrollView
            ├── 空状态显示
            │   └── VStack
            │       ├── "暂无通知"
            │       └── "新的通知将会显示在这里"
            │
            └── 通知列表
                └── LazyVStack
                    └── ForEach(notifications)
                        └── NotificationCell

特点：
1. 状态管理
   - 使用 MVVM 架构
   - 完整的加载状态处理
   - 错误处理机制

2. 用户体验
   - 加载超时检测 (5秒)
   - 下拉刷新功能
   - 懒加载列表 (LazyVStack)

3. 生命周期处理
   - onAppear 自动加载数据
   - 2秒后自动关闭加载状态

4. 错误处理流程
   - 显示错误信息
   - 提供重试机制
   - 优雅的空状态处理
```


## NotificationCellView


我来分析这个 NotificationCell 视图的结构：

```other
View: NotificationCell
├── 状态属性
│   └── @State width: CGFloat  // 屏幕宽度
│
├── 传入参数
│   └── notification: Notification  // 通知数据模型
│
└── 视图层次
    └── VStack
        ├── 分隔线
        │  
        │
        └── HStack (顶部对齐)
            ├── 左侧图标
            │   └── Image(person.fill)
            │ 
            │
            ├── 内容区 (VStack)
            │   ├── 用户头像
            │   │   └── 
            │   │
            │   └── 通知文本
            │       └── Text组合
            │           ├── 用户名 (粗体)
            │           └── 通知消息 (根据类型显示)
            │
            └── Spacer
```


## NotificationViewModel


我来分析这个 NotificationsViewModel 的结构：

```other
ViewModel: NotificationsViewModel (ObservableObject)
├── 属性
│   ├── @Published notifications: [Notification]  // 通知数组，支持视图更新
│   └── user: User                               // 当前用户
│
├── 初始化
│   └── init(user: User)
│       ├── 保存用户信息
│       └── 自动调用 fetchNotifications()
│
└── 方法: fetchNotifications() -> 很明显这是viewModel 层不应该有这样的后端传输逻辑
    ├── URL构建
    │   └── "http://localhost:3000/notifications/{userId}"
    │
    ├── 请求配置
    │   ├── Method: GET
    │   └── Headers
    │       ├── Authorization: Bearer token
    │       ├── Content-Type: application/json
    │       └── Accept: application/json
    │
    ├── 认证处理
    │   └── JWT Token (从 UserDefaults 获取)
    │
    ├── 网络请求 (URLSession.dataTask)
    │   └── 使用 [weak self] 避免循环引用
    │
    └── 响应处理
        ├── 错误处理
        │   ├── 网络错误
        │   ├── 数据缺失
        │   └── 解码失败
        │
        ├── 调试信息
        │   ├── HTTP状态码
        │   ├── 原始响应数据
        │   └── 解码结果数量
        │
        └── 数据更新
            └── DispatchQueue.main.async
                └── 更新 @Published notifications
```





下面的答复将基于你已经提出的模块化、网络层重构、状态管理优化、依赖注入等重构思路进行全面分析，并在此基础上对不合理或需要斟酌的部分提出改正建议。同时，会针对你想要的详细实施步骤进行一个尽可能清晰的规划。

一、整体评价

从你提供的方案来看，重构思路总体是合理且可行的。你规划了以下核心目标：
	1.	项目结构重组：拆分成更清晰的功能模块（Auth、Feed、Profile、Notifications、Common）。
	2.	网络层彻底重构：打造一个统一的 APIClient（或类似）的抽象层，避免在视图或 ViewModel 中手动拼装 URL、header 等。
	3.	状态管理优化：替换目前的单例式 AuthViewModel.shared，改用更清晰的依赖注入 + ObservableObject 结构；减少“全局大对象”在各层之间的耦合。
	4.	依赖注入：使用 DIContainer（或其他 DI 方案）来统一管理服务实例，以实现可测试和可替换性（mock 测试、生产依赖分离）。
	5.	分阶段渐进式重构：确保旧代码能继续工作，逐步迁移关键模块到新架构，降低大规模一次性重构的风险。

在现代 Swift 开发中，这些都是符合最佳实践且广受欢迎的思路。

二、可能的不合理之处或需要改进的细节
	1.	DIContainer 仍然是一个单例
	•	你在 DIContainer 中使用了 static let shared = DIContainer() 并在内部维护一个字典来注册/解析服务。
	•	虽然可以快速实现注入，但依旧有“一切都要找这个单例 DI 容器” 的味道。
	•	在单元测试环境下，这样做依然可能导致依赖相互污染、或者测试 teardown 时难以清理。
	•	如果要更彻底地避免单例，可以考虑在 App 启动时创建一个 DIContainer 实例（不以静态属性的方式），然后在顶层 @main 的 App 里将容器注入到 SwiftUI 环境（或通过构造函数传递给各个模块）。
	•	当然，这并不一定是必须的，你可以根据团队习惯和项目规模决定保留“DIContainer 单例”，但要留意可能的测试隔离问题。
	2.	过度依赖协议和枚举时，需要确保灵活性
	•	当你使用 APIEndpoint 枚举来管理路径时，要确保后续添加/修改接口时不会导致庞大的枚举变得拥挤。
	•	如果接口数量非常多（比如 50+），将它们全部放到一个大枚举中可读性可能会下降；可以考虑按照业务模块（AuthEndpoint、UserEndpoint 等）来拆分。
	•	在 Swift Concurrency (async/await) 下使用协议对 APIClientProtocol 进行抽象是可行的，但注意异常处理、token 刷新、通用错误解析等功能都需要在这里实现或扩展，以避免分散到各个 Service 中。
	3.	模块之间的依赖关系依然需要梳理
	•	你在拆分 AuthServiceProtocol、FeedServiceProtocol 等时，需要确保不会出现循环依赖（例如 Auth 模块又要依赖 Feed 模块的一些方法，Feed 模块也要依赖 Auth 的 token），或者把公共部分抽到 Common/Networking 层。
	•	如果 AuthService 需要调用某些通用通知发送功能，那么“通知发送”要么放到 Notifications 模块，要么放到更通用的 Common/Networking 层里，避免模块之间交叉。
	•	一定要有明确的模块边界：Auth 只关心用户登录注册、Token 管理，Feed 只关心推文相关的 CRUD，Profile 只关心用户资料显示及编辑等等。
	4.	使用 EnvironmentObject 还是在 ViewModel 中直接注入 AuthState
	•	你在示例中依然保留了在 App 中 @StateObject var authState = AuthState() 并 .environmentObject(authState) 的用法。这在 SwiftUI 中非常常见（类似 Redux store），但要注意范围：
	•	如果 AuthState 本身只在极少数界面用到，那么无需把它放到整个 App 的环境对象中，可以在需要的视图直接注入或通过构造函数传递。
	•	如果你真的需要全局各层都获取到 currentUser，那保持 EnvironmentObject 方式也合理。但要注意越高层级的 environment object，影响范围越广。
	5.	并发与主线程更新
	•	你在示例里提到 @MainActor 或在异步方法里 await MainActor.run { ... } 来更新 UI。
	•	这种方式非常好，可以避免使用 DispatchQueue.main.async 的老式写法。
	•	但是要确保所有跟 UI 绑定的 @Published 属性，都在主线程，避免同时存在多个 actor 导致“跨线程更新视图”的报错。
	6.	改造过程中的兼容问题
	•	由于你计划分阶段进行重构，需要考虑在过渡期内，有些部分还是老代码（例如使用闭包回调的 AuthService.login(...) { }），有些部分已经改造成了 async/await。
	•	这在短期内会造成一些混乱，需要在架构上小心管理，不要让“老服务”和“新服务”都在调用同一个方法却产生冲突。
	•	可以通过分支管理、特性开关 (Feature Flags)，或者先将新模块标记为 _Beta，确定功能稳定后再彻底移除旧模块。
	7.	Mock 与测试策略
	•	“DI 容器 + 协议 + async/await” 可以让你轻松注入 Mock 服务，比如 MockAuthService。
	•	但是要确保测试环境下，不要无意使用到了生产的 APIClient 或生产的 AuthService。
	•	这通常需要在 AppDelegate 或 SwiftUI App 初始化时根据 Scheme/编译配置/测试标记来决定 DIContainer.setupMockDependencies() 还是 DIContainer.setupProductionDependencies()。
	•	另外还需留意Keychain 或 UserDefaults 中的 Token 并非在单元测试下能自动隔离，最好给测试环境开不同的 suite name 或者 mock Keychain。

三、针对你的“重构步骤”再做更细化的规划

以下是一个更详细的多阶段实施方案（可根据项目规模和优先级做微调）：

阶段 0：分析和准备
	1.	梳理现有功能点：明确哪些模块最核心（例如 Auth + Feed），哪些模块可以稍后处理（如 Notifications）。
	2.	确定数据结构及接口稳定性：和后端对齐接口文档，确定不会大规模频繁变动；如果后端也在改，会导致你重构的边界不断变动。
	3.	搭建测试基础：至少准备好部分单元测试、UI 测试的工程设置，让后续模块完成后能快速写测试验证。

阶段 1：网络层搭建与 DI 容器实现
	1.	创建 APIClient
	•	编写 sendRequest<T: Decodable>(endpoint: APIEndpoint, ...) async throws -> T 的核心逻辑。
	•	处理通用的错误解析、HTTP 状态码判断、token 注入（如果需要自动在 header 中塞 token）。
	2.	定义 APIEndpoint
	•	先只实现一小部分（例如 Auth 和 Tweet 两个 endpoint），确保跑通流程。
	•	后续再扩展其他模块（Profile、Notifications 等）的 endpoint。
	3.	实现 DIContainer
	•	提供最基础的“生产环境”注册：container.register(AuthService(...) as AuthServiceProtocol), container.register(APIClient(...) as APIClientProtocol), etc.
	•	在单元测试或 UI 测试时，可以 setupMockDependencies() 改用 MockAuthService(...) 和 MockAPIClient(...)。

	注意：此时先不大规模替换旧的 RequestServices / AuthService，而是并行地建立新网络层及 DI 机制。

阶段 2：认证模块重构
	1.	创建新的 AuthServiceProtocol + AuthService（基于 APIClientProtocol）
	•	实现 login, register, fetchUser 等核心方法。使用 async/await 接口。
	2.	创建新的 AuthState（或 AuthViewModel）
	•	移除旧的单例 AuthViewModel.shared 中的大量逻辑，精简为：

class AuthState: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    ...
    // 只保留必须的方法 login(), register(), fetchCurrentUser() ...
}


	•	在内部调用新的 AuthServiceProtocol（使用 DIContainer 或构造函数注入）。
	•	处理 Token 的存储/刷新（可以先简单保存在 UserDefaults，后续再改进为 Keychain）。

	3.	在 App 入口替换
	•	@StateObject var authState = AuthState() 代替以前的 AuthViewModel.shared。
	•	全局 .environmentObject(authState)（如果确实需要全局访问）。
	4.	替换旧的登录/注册视图
	•	将 LoginView / RegisterView 中的闭包请求逻辑改成：

Button("Login") {
  Task {
    await authState.login(email: email, password: password)
  }
}


	•	UI 更新直接依赖 authState.isAuthenticated。

	此时，你已经完成认证模块的主要迁移，旧代码中跟 Auth 相关的内容基本可以弃用。
如果旧的部分还在被其他模块（比如 FeedViewModel）调用，也能并存一段时间，等后面统一替换。

阶段 3：Feed / Tweet 模块重构
	1.	定义 TweetServiceProtocol：包含获取推文列表、发推文、点赞/取消点赞等方法。
	2.	实现 TweetService：
	•	使用 APIClient 构建请求。
	•	提供 async/await 方法：func fetchTweets() async throws -> [Tweet], func createTweet(...), func likeTweet(...), etc.
	3.	创建 FeedViewModel (新的)
	•	拆分原先 FeedViewModel 中的网络请求到 TweetServiceProtocol。
	•	只负责 @Published var tweets: [Tweet]，在合适的时机（onAppear、下拉刷新）调用 tweetService.fetchTweets()。
	4.	删除或废弃旧的 RequestServices.fetchTweets
	•	统一切换到新的 TweetService。
	5.	推文创建：如果你有 CreateTweetViewModel，就注入 TweetServiceProtocol，调用 createTweet(text: String, image: UIImage)。
	•	之前 CreateTweetViewModel 里直接调 RequestServices.postTweet + ImageUploader；现在都改成调用 TweetService 内部做真正的发送逻辑。

阶段 4：Profile / Notifications 等其他模块
	•	按照同样的模式，创建对应的 Service Protocol / ViewModel / SwiftUI Views。
	•	让这些功能也用 async/await + DIContainer + APIClient。
	•	注意要把公共逻辑（例如上传图片）抽取到公共的 ImageUploadService 或 FileService。
	•	如果有关注 / 取消关注接口，也可以做成 UserServiceProtocol 或 ProfileServiceProtocol。

阶段 5：清理旧代码、统一风格
	1.	删除 RequestServices.swift、AuthService(老版本)、AuthViewModel.shared(老版本)** 等不再需要的文件。
	2.	在新代码中保持统一的错误处理：
	•	定义 AppError 或类似更完善的错误枚举；
	•	在 APIClient.parseError 中返回 AppError 相关信息；
	•	在 ViewModel 中 catch 这个 error 并赋值给 @Published var errorMessage，或通过 SwiftUI .alert 统一提示。
	3.	统一测试
	•	写单元测试：对 AuthService、TweetService 等进行功能级测试；对 FeedViewModel, AuthState 做状态逻辑测试；
	•	写 UI 测试：尤其是登录、切换账号、发推文流程是否正确；
	•	利用 DIContainer 注入 MockAPIClient/MockService 来模拟后端响应。

阶段 6：性能与监控
	1.	在 APIClient 中埋点：统计请求耗时，或结合第三方监控平台 (Sentry, Firebase Crashlytics, New Relic 等)。
	2.	缓存策略：如果你想做离线功能或避免频繁请求，可以在每个 Service 中集成本地缓存（CoreData/Realm/SQLite 等），也可以利用 Swift Cache 机制。
	3.	可视化日志：为调试目的，开发时可在 APIClient 的 sendRequest 中打印请求信息、响应体节选，或仅在 Debug 配置下打印。

四、总结与建议
	•	你的整体重构计划非常符合现代 SwiftUI + MVVM + 依赖注入 + async/await 的最佳实践。
	•	主要改进点：
	1.	进一步考虑 DIContainer 的实例化方式，以确保测试环境不被“单例”污染；
	2.	确保网络层的 Token 注入、错误处理、刷新逻辑集中在 APIClient 或者中间件里；
	3.	模块之间减少交叉依赖，对公共功能（如 Notifications、Image Upload）做好抽象；
	4.	在渐进式迁移过程中，用 Feature Flag 或分支管理减少冲突；
	5.	保证每个阶段完成后都可编译可运行，不要破坏已有功能。
	•	在你最后的提问中：
	•	关于 “如果合理，为我制定详细的重构策略”，已经在上文给出了详细分阶段（1-6）的落地步骤；
	•	“并且给我规划，实施步骤”，对应上文阶段 1 ~ 6，每个阶段的目标、动作、以及对可能的陷阱都作了阐述。

最后的提示

在实际落地时，一定要结合你所在团队的人数、现有项目的规模和紧迫度，以及后端 API 是否稳定等因素来决定改造的深度和排期。如果需求压力很大、迭代频繁，可以先挑选最痛点的部分（Auth 或 Feed）做局部试点，再逐渐扩散到全项目，避免一次性“大爆炸”式重构导致难以调试和维护。

祝你重构顺利，完成后你的项目将拥有更清晰的结构、易测性和可维护性!








├── App
│   ├── App.swift
│   └── DIContainer.swift
├── Core
│   ├── Common
│   │   └── Extensions
│   │       └── ImagePicker.swift
│   ├── Legacy
│   │   ├── AuthService.swift
│   │   ├── ImageUploader.swift
│   │   └── RequestServices.swift
│   ├── Network
│   │   ├── Base
│   │   │   ├── APIClient.swift
│   │   │   ├── APIEndpoint.swift
│   │   │   ├── HTTPMethod.swift
│   │   │   └── NetworkError.swift
│   │   └── Config
│   │       ├── APIConfig.swift
│   │       └── NetworkMonitor.swift
│   └── Storage
│       ├── Keychain
│       │   └── KeychainStore.swift
│       └── UserDefaults
│           └── UserDefaultsStore.swift
├── Features
│   ├── Auth
│   │   ├── Models
│   │   │   └── User.swift
│   │   ├── Services
│   │   ├── ViewModels
│   │   │   └── AuthViewModel.swift
│   │   └── Views
│   │       ├── AuthenticationView.swift
│   │       ├── CustomAuthTextField.swift
│   │       ├── LoginView.swift
│   │       ├── RegisterView.swift
│   │       ├── SecureAuthTextField.swift
│   │       └── WelcomeView.swift
│   ├── Feed
│   │   ├── Models
│   │   │   └── Tweet.swift
│   │   ├── Services
│   │   ├── ViewModels
│   │   │   ├── CreateTweetViewModel.swift
│   │   │   ├── FeedViewModel.swift
│   │   │   └── TweetCellViewModel.swift
│   │   └── Views
│   │       ├── FeedView.swift
│   │       └── TweetCellView.swift
│   ├── Main
│   │   └── Views
│   │       ├── CreateTweetView.swift
│   │       ├── Home.swift
│   │       ├── MainView.swift
│   │       ├── MultilineTextField.swift
│   │       ├── SettingsView.swift
│   │       ├── SlideMenu.swift
│   │       └── TopBar.swift
│   ├── Messages
│   │   ├── MessageCell.swift
│   │   └── MessagesView.swift
│   ├── Notifications
│   │   ├── Models
│   │   │   └── Notification.swift
│   │   ├── Services
│   │   ├── ViewModels
│   │   │   └── NotificationsViewModel.swift
│   │   └── Views
│   │       ├── NotificationCell.swift
│   │       └── NotificationsView.swift
│   ├── Profile
│   │   ├── Services
│   │   ├── ViewModels
│   │   │   ├── EditProfileViewModel.swift
│   │   │   └── ProfileViewModel.swift
│   │   └── Views
│   │       ├── BlurView.swift
│   │       ├── CustomProfileTextField.swift
│   │       ├── EditProfileView.swift
│   │       └── ProfileView.swift
│   └── Search
│       ├── Services
│       ├── ViewModels
│       │   └── SearchViewModel.swift
│       └── Views
│           ├── SearchBar.swift
│           ├── SearchCell.swift
│           └── SearchView.swift
├── Resources
│   ├── File.midi
│   ├── File.xml
│   ├── Localization
│   │   ├── Chinese.strings
│   │   └── English.strings
│   ├── Media.xcassets
│   │   ├── AppIcon.appiconset
│   │   │   └── Contents.json
│   │   ├── BG.colorset
│   │   │   └── Contents.json
│   │   ├── Contents.json
│   │   ├── GoogleLogo.imageset
│   │   │   ├── Contents.json
│   │   │   └── GoogleLogo.svg
│   │   ├── SSC_banner.imageset
│   │   │   ├── Contents.json
│   │   │   └── SSC_banner.jpg
│   │   ├── TweetImage.imageset
│   │   │   ├── Contents.json
│   │   │   └── Rectangle.png
│   │   └── X.imageset
│   │       ├── Contents.json
│   │       └── X.svg
│   └── Resources.swift
└── Tests
    ├── UITests
    │   └── AuthUITests.swift
    └── UnitTests
        ├── AuthTests.swift
        └── NetworkTests.swift