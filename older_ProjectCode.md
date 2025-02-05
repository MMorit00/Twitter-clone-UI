@_exported import Inject
import SwiftUI

@main
struct App: App {
  @StateObject private var injectionManager = InjectionManager.shared
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(AuthViewModel.shared)
        .injectableView()
      //          EditProfileView()
      //            .injectableView()
    }
  }
}

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        if viewModel.isAuthenticated {
            if viewModel.user != nil {
                MainView()
                    .injectableView()
            }
        } else {
            WelcomeView()
                .injectableView()
        }
    }
}

#Preview {
    ContentView()
}

// 创建一个环境对象来管理注入状态
final class InjectionManager: ObservableObject {
    @ObserveInjection var inject
    static let shared = InjectionManager()
}

// 简化的视图修饰符
extension View {
    func injectableView() -> some View {
        modifier(InjectableViewModifier())
    }
}

struct InjectableViewModifier: ViewModifier {
    @StateObject private var manager = InjectionManager.shared

    func body(content: Content) -> some View {
        content.enableInjection()
    }
}import Foundation
import SwiftUI
import Foundation
import SwiftUI

class AuthViewModel: ObservableObject {
    // 添加静态共享实例
    static let shared = AuthViewModel()

    @Published var isAuthenticated: Bool = false
    @Published var user: User?
    @Published var error: Error?

    // 用于存储用户凭证
    @AppStorage("jwt") var token: String = ""
    @AppStorage("userId") var userId: String = ""

    // 将 init() 改为私有,确保只能通过 shared 访问
    private init() {
        // 初始化时检查认证状态
        checkAuthStatus()
    }

    private func checkAuthStatus() {
        // 如果有token和userId,尝试获取用户信息
        if !token.isEmpty && !userId.isEmpty {
            fetchUser()
        }
    }

   // 在 AuthViewModel 的 login 方法中
func login(email: String, password: String) {
    AuthService.login(email: email, password: password) { [weak self] result in
        DispatchQueue.main.async {
            switch result {
            case let .success(response):
                // 保存 token 和 userId (如果 token 为 nil，则赋值为空字符串)
                self?.token = response.token ?? ""
                self?.userId = response.user.id
                // 保存用户信息
                self?.user = response.user
                // 更新认证状态
                self?.isAuthenticated = true
                print("Logged in successfully")

            case let .failure(error):
                // 处理错误
                self?.error = error
                print("Login error: \(error)")
            }
        }
    }
}

    // 注册方法
   func register(name: String, username: String, email: String, password: String) async throws {
     try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
        AuthService.register(
            email: email,
            username: username,
            password: password,
            name: name
        ) { [weak self] result in
            guard let self = self else {
                continuation.resume(throwing: AuthService.AuthenticationError.custom("Self is nil"))
                return
            }
            
            switch result {
            case let .success(user):
                // 更新用户信息（此时还没有 token, 所以接下来调用 login 获取 token）
                DispatchQueue.main.async {
                    self.user = user
                    // 进行登录来获取 token
                    self.login(email: email, password: password)
                    continuation.resume()
                }
                
            case let .failure(error):
                DispatchQueue.main.async {
                    self.error = error
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

    // 登出方法
    func signOut() {
        // 清除用户数据和token
        isAuthenticated = false
        user = nil
        token = ""
        userId = ""
    }

    // 验证token是否有效
    func validateToken() {
        // TODO: 实现token验证
    }

    private func fetchUser() {
        guard !token.isEmpty && !userId.isEmpty else { return }

        AuthService.fetchUser(userId: userId, token: token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(user): // 直接使用返回的 user 对象
                    self?.user = user
                    self?.isAuthenticated = true
                case let .failure(error):
                    self?.error = error
                    self?.signOut() // 如果获取用户信息失败,清除认证状态
                }
            }
        }
    }

    // 添加更新用户方法
    func updateUser(_ updatedUser: User) {
        DispatchQueue.main.async {
            self.user = updatedUser
            // 可以在这里添加持久化逻辑
        }
    }

    // 修改更新方法,添加 transaction 支持
    func updateCurrentUser(_ updatedUser: User, transaction: Transaction = .init()) {
        withTransaction(transaction) {
            // 只更新 following/followers 相关数据
            if let currentUser = self.user {
                var newUser = currentUser
                newUser.following = updatedUser.following
                newUser.followers = updatedUser.followers
                self.user = newUser
            }
        }
    }

    // 添加静默更新方法
    func silentlyUpdateFollowing(_ following: [String]) {
        if var currentUser = user {
            currentUser.following = following
            // 直接更新，不触发 objectWillChange
            user = currentUser
        }
    }
}



struct MainView: View {
    @State private var navigationPath = NavigationPath()
    @State private var showMenu = false
    @State private var showProfile = false // 新增状态控制导航
    @State private var offset: CGFloat = 0
    // @State private var selectedUser: User? = nil
    // let user: User
    @EnvironmentObject private var viewModel: AuthViewModel
    // 侧边菜单宽度（为了方便修改）
    private var menuWidth: CGFloat {
        UIScreen.main.bounds.width - 90
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .leading) {
                // 1. 主界面内容
                VStack(spacing: 0) {
                    // 顶部导航条，这里仅示例
                    TopBar(showMenu: $showMenu, offset: $offset)

                    // HomeView 里面有 TabView 等
                    HomeView()
                }
                // 根据 offset 偏移，用于把主界面往右推
                .offset(x: offset)
                // 当菜单展开时，若需要禁止主界面交互，可在此启用:
                // .disabled(showMenu)

                // 半透明蒙版，用于点击/拖拽关闭菜单
                Color.gray
                    .opacity(0.3 * min(offset / (UIScreen.main.bounds.width - 90), 1.0))
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showMenu = false
                            offset = 0
                        }
                    }
                    .allowsHitTesting(showMenu)

                // 2. 侧边菜单视图
                SlideMenu(onProfileTap: {
                    showProfile = true
                })
                .frame(width: menuWidth)
                .background(Color.white)
                .offset(x: offset - menuWidth)
                .zIndex(2) // 添加最高层级

                // 3. 用于菜单拖拽手势的透明层
                if showMenu {
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .gesture(dragGesture)
                        .frame(width: UIScreen.main.bounds.width - menuWidth)
                        .offset(x: menuWidth) // 只覆盖非菜单区域
                        .zIndex(1)
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .frame(width: 30)
                        .gesture(dragGesture)
                        .zIndex(1)
                }
            }
            .navigationDestination(isPresented: $showProfile) {
                ProfileView()
            }
            .toolbar(.hidden, for: .tabBar) // 只隐藏tabBar
        }
    }

    /// 将 DragGesture 封装，给上面透明视图使用
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                // 计算当前手指移动量（根据是否已经在菜单展开状态，做相对位移）
                let translation = gesture.translation.width

                if !showMenu {
                    // 菜单未展开时，手势从左向右拉出
                    // offset 最大只能到 menuWidth
                    offset = max(0, min(translation, menuWidth))
                } else {
                    // 菜单已展开，手势可能关闭菜单
                    // 基准点为展开状态下 offset=menuWidth，所以要加上 menuWidth
                    offset = max(0, min(menuWidth, translation + menuWidth))
                }
            }
            .onEnded { gesture in
                let translation = gesture.translation.width
                // 计算手指在结束时的速度或位置
                let predictedEnd = gesture.predictedEndLocation.x - gesture.startLocation.x
                let threshold = menuWidth / 2

                withAnimation(.easeInOut(duration: 0.3)) {
                    if !showMenu {
                        // 原来是关闭状态
                        // 判断是否要展开
                        if predictedEnd > 200 || offset > threshold {
                            openMenu()
                        } else {
                            closeMenu()
                        }
                    } else {
                        // 原来是打开状态
                        // 判断是否要关闭
                        if predictedEnd < -200 || offset < threshold {
                            closeMenu()
                        } else {
                            openMenu()
                        }
                    }
                }
            }
    }

    private func openMenu() {
        offset = menuWidth
        showMenu = true
    }

    private func closeMenu() {
        offset = 0
        showMenu = false
    }
}
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    @ObserveInjection var inject
    @State private var selectedTab = 0
    @State private var showCreateTweetView = false
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                FeedView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .tag(0)

                SearchView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                    .tag(1)

                NotificationsView()
                    .tabItem {
                        Image(systemName: "bell")
                        Text("Notifications")
                    }
                    .tag(2)

                MessagesView()
                    .tabItem {
                        Image(systemName: "envelope")
                        Text("Messages")
                    }
                    .tag(3)
            }
            .sheet(isPresented: $showCreateTweetView) {
                CreateTweetView()
            }
            .accentColor(Color("BG"))

            // 添加浮动发推按钮
            Button(action: {
                showCreateTweetView = true
            }) {
                Image(systemName: "plus")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color("BG"))
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding()
            .padding(.bottom, 60) // 调整按钮位置，避免与 TabBar 重叠
        }

        .enableInjection()
    }
}


import SwiftUI

struct FeedView: View {
    // 添加热重载支持
    @ObserveInjection var inject
    @EnvironmentObject private var authViewModel: AuthViewModel
    // 添加 ViewModel
    @StateObject var viewModel = FeedViewModel()

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // 使用实际的tweets数据
                ForEach(viewModel.tweets) { tweet in
                    TweetCellView(viewModel: TweetCellViewModel(
                        tweet: tweet,
                        currentUser: authViewModel.user!
                    ))
                    .padding(.horizontal, 10)

                    Divider()
                        .padding()
                }
            } 
        }
        .refreshable { // 添加下拉刷新
            viewModel.refresh()
        }
        .enableInjection()
    }
}

import Combine
import Foundation

class FeedViewModel: ObservableObject {
    // 发布tweets数组属性
    @Published var tweets: [Tweet] = []
    @Published var user: User // 添加用户属性

    private var cancellables = Set<AnyCancellable>()
    private var refreshTimer: AnyCancellable? // 用于定时刷新

    init() {
        // 初始化用户
        user = AuthViewModel.shared.user!

        // 订阅用户变化
        AuthViewModel.shared.$user
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedUser in
                self?.user = updatedUser
                // 用户更新时刷新 tweets
                self?.fetchTweets()
            }
            .store(in: &cancellables)

        // // 设置定时刷新（例如每30秒）
        // setupRefreshTimer()

        // 初始获取tweets
        fetchTweets()
    }

    // private func setupRefreshTimer() {
    //     refreshTimer = Timer.publish(every: 30, on: .main, in: .common)
    //         .autoconnect()
    //         .sink { [weak self] _ in
    //             self?.fetchTweets()
    //         }
    // }

    func fetchTweets() {
        // 设置请求域名
        RequestServices.requestDomain = "http://localhost:3000/tweets"

        // 调用网络请求方法获取tweets
        RequestServices.fetchTweets { [weak self] result in
            switch result {
            case let .success(data):
                // 添加日志输出
                print("Received data: \(String(data: data, encoding: .utf8) ?? "")")

                do {
                    let tweets = try JSONDecoder().decode([Tweet].self, from: data)
                    print("Successfully decoded \(tweets.count) tweets")

                    DispatchQueue.main.async {
                        // 更新前比较，避免不必要的UI刷新
                        if self?.tweets != tweets {
                            self?.tweets = tweets
                        }
                    }
                } catch {
                    print("JSON Decoding error: \(error)")
                }

            case let .failure(error):
                print("Network error: \(error.localizedDescription)")
            }
        }
    }

    // 添加手动刷新方法
    func refresh() {
        fetchTweets()
    }

    // 清理资源
    deinit {
        refreshTimer?.cancel()
        cancellables.removeAll()
    }
}

import Kingfisher
import SwiftUI

struct TweetCellView: View {
    @ObserveInjection var inject
    @ObservedObject var viewModel: TweetCellViewModel

    // 添加计算属性
    private var didLike: Bool {
        viewModel.tweet.didLike ?? false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 点赞信息 - 如果有点赞则显示
            if let likes = viewModel.tweet.likes, !likes.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.gray)
                    Text("\(likes.count) likes")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 16)
            }

            // 主要内容
            HStack(alignment: .top, spacing: 12) {
                // 头像部分
                NavigationLink {
                    if let user = viewModel.user {
                        ProfileView(userId: user.id)
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(width: 44, height: 44)
                    } else {
                        KFImage(viewModel.getUserAvatarURL())
                            .placeholder {
                                Circle()
                                    .fill(.gray)
                                    .frame(width: 44, height: 44)
                            }
                            .resizable()
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                    }
                }

                // 推文内容
                VStack(alignment: .leading, spacing: 4) {
                    // 用户信息
                    HStack {
                        Text(viewModel.tweet.user)
                            .fontWeight(.semibold)
                        Text("@\(viewModel.tweet.username)")
                            .foregroundColor(.gray)
                        Text("·")
                            .foregroundColor(.gray)
                        // TODO: 添加时间格式化显示
                        Text("11h")
                            .foregroundColor(.gray)
                    }
                    .font(.system(size: 16))

                    // 推文文本
                    Text(viewModel.tweet.text)
                        .font(.system(size: 16))
                        .frame(maxHeight: 100)
                        .lineSpacing(4)

                    // Tweet Image (if exists)
                    if viewModel.tweet.image == true {
                        GeometryReader { proxy in
                            KFImage(URL(string: "http://localhost:3000/tweets/\(viewModel.tweet.id)/image"))
                                .resizable()
                                .scaledToFill()
                                .frame(width: proxy.size.width, height: 200)
                                .cornerRadius(15)
                        }
                        .frame(height: 200)
                        .zIndex(0)
                    }

                    // 互动按钮
                    HStack(spacing: 40) {
                        InteractionButton(image: "message", count: 0)
                        InteractionButton(image: "arrow.2.squarepath", count: 0)

                        Button(action: {
                            viewModel.likeTweet()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: didLike ? "heart.fill" : "heart")
                                    .foregroundColor(didLike ? .red : .gray)
                                if let likes = viewModel.tweet.likes {
                                    Text("\(likes.count)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .zIndex(1)
                        .padding(8)
                        .contentShape(Rectangle())
                     
                        InteractionButton(image: "square.and.arrow.up", count: nil)
                    }
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .contentShape(Rectangle())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
        .enableInjection()
    }
}

// MARK: - 子视图

private struct InteractionButton: View {
    let image: String
    let count: Int?

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: image)
                .foregroundColor(.gray)
            if let count = count {
                Text("\(count)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
    }
}

import SwiftUI

import SwiftUI

// import Kingfisher

class TweetCellViewModel: ObservableObject {
    @Published var tweet: Tweet
    @Published var user: User?
    @Published var isLoading = false
    let currentUser: User

    init(tweet: Tweet, currentUser: User = AuthViewModel.shared.user!) {
        self.tweet = tweet
        self.currentUser = currentUser
        checkIfUserLikedTweet()
        fetchUser()
    }

    private func fetchUser() {
        isLoading = true

        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            return
        }

        let urlString = "http://localhost:3000/users/\(tweet.userId)"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                guard let data = data else { return }

                do {
                    let user = try JSONDecoder().decode(User.self, from: data)
                    self?.user = user
                } catch {
                    print("Error decoding user: \(error)")
                }
            }
        }.resume()
    }

    func getUserAvatarURL() -> URL? {
        guard let userId = user?.id else { return nil }
        return URL(string: "http://localhost:3000/users/\(userId)/avatar")
    }

    var imageUrl: URL? {
        guard tweet.image == true else { return nil }
        return URL(string: "http://localhost:3000/tweets/\(tweet.id)/image")
    }

    func checkIfUserLikedTweet() {
        if let likes = tweet.likes {
            tweet.didLike = likes.contains(currentUser.id)
        }
    }

    func likeTweet() {
        let isLiked = tweet.didLike ?? false

        RequestServices.likeTweet(tweetId: tweet.id, isLiked: isLiked) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.tweet.didLike?.toggle()

                    if isLiked {
                        self?.tweet.likes?.removeAll(where: { $0 == self?.currentUser.id })

                    } else {
                        self?.tweet.likes = (self?.tweet.likes ?? []) + [self?.currentUser.id ?? ""]
                        RequestServices.requestDomain = "http://localhost:3000"
                        print("Sending notification: Username: \(self?.currentUser.username ?? ""), Sender ID: \(self?.currentUser.id ?? ""), Receiver ID: \(self?.tweet.userId ?? "")")
                        RequestServices.sendNotification(
                            username: self?.currentUser.username ?? "",
                            notSenderId: self?.currentUser.id ?? "",
                            notReceiverId: self?.tweet.userId ?? "",
                            notificationType: NotificationType.like.rawValue,
                            postText: self?.tweet.text ?? ""
                        ) { result in
                            print("Notification result: \(result)")
                        }
                    }

                case let .failure(error):
                    print("Error liking tweet: \(error)")
                }
            }
        }
    }
}


import Kingfisher
import SwiftUI

struct SlideMenu: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileViewModel()
    var onProfileTap: () -> Void
    @State private var isExpanded = false
    @ObserveInjection var inject

    var body: some View {
        VStack(alignment: .leading) {
            // 顶部用户信息区域
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Button {
                        onProfileTap() // 触发导航回调
                    } label: {
                        HStack {
                            KFImage(viewModel.getAvatarURL())
                                .placeholder {
                                    Circle()
                                        .fill(.gray)
                                        .frame(width: 44, height: 44)
                                }
                                .resizable()
                                .scaledToFill()
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                                .padding(.bottom, 12)

                            VStack(alignment: .leading, spacing: 0) {
                                Text(viewModel.user.name)
                                    .font(.system(size: 14))
                                    .padding(.bottom, 4)
                                Text("@\(viewModel.user.username)")
                                    .font(.system(size: 12))
                                    .bold()
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .contentShape(Rectangle())
                }
                Spacer()

                Button(action: {
                    isExpanded.toggle()
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 16))
                }
                .padding(.top, 12)
            }

            // 关注信息区域
            HStack(spacing: 0) {
                Text("\(viewModel.user.following.count) ")
                    .font(.system(size: 14))
                    .bold()
                Text("Following")
                    .foregroundStyle(.gray)
                    .font(.system(size: 14))
                    .bold()
                    .padding(.trailing, 8)
                Text("\(viewModel.user.followers.count) ")
                    .font(.system(size: 14))
                    .bold()
                Text("Followers")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                    .bold()
            }

            .padding(.top, 4)

            // 主菜单列表区域
            VStack(alignment: .leading, spacing: 0) {
                ForEach([
                    ("person", "Profile"),
                    ("list.bullet", "Lists"),
                    ("number", "Topics"),
                    ("bookmark", "Bookmarks"),
                    ("sparkles", "Moments"),
                ], id: \.1) { icon, text in
                    HStack {
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .padding(16)
                            .padding(.leading, -16)

                        Text(text)
                            .font(.system(size: 18))
                            .bold()
                    }
                }
            }
            .padding(.vertical, 12)

            Divider()
                .padding(.bottom, 12 + 16)

            // 底部区域
            VStack(alignment: .leading, spacing: 12) {
                Text("Settings and privacy")
                    .font(.system(size: 14))
                    .bold()
                Text("Help Center")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)

                HStack {
                    Image(systemName: "lightbulb")
                    Spacer()
                    Image(systemName: "qrcode")
                }
                .font(.title3)
                .padding(.vertical, 12)
                .bold()
            }
        }
        .padding(.top, 12)
        .padding(.horizontal, 24)
        .frame(maxHeight: .infinity, alignment: .top)
        .enableInjection()
    }
}

import Kingfisher
import SwiftUI

// 添加在文件顶部
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// 添加在文件顶部
struct TabBarOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ProfileView: View {
    // MARK: - Properties

    @StateObject private var viewModel: ProfileViewModel
    @ObserveInjection var inject
    @State var offset: CGFloat = 0 // 监测最顶端 Banner 的滚动偏移
    @State var titleOffset: CGFloat = 0 // 监测 Profile Data 或标题区域的滚动偏移
    @State var tabBarOffset: CGFloat = 0 // 监测 TabBar 的滚动偏移
    @State private var showEditProfile = false // 添加导航状态
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State var currentTab = "Tweets"
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss

    // 初始化方法
    init(userId: String? = nil) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(userId: userId))
    }

    // MARK: - Body

    var body: some View {
        Group {
            if let error = viewModel.error {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text(error.localizedDescription)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 15) {
                        // MARK: - 1) Banner + Title

                        GeometryReader { proxy -> AnyView in
                            let minY = proxy.frame(in: .global).minY

                            return AnyView(
                                ZStack {
                                    // 背景 Banner
                                    Image("SC_banner")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(
                                            width: getRect().width,
                                            height: minY > 0 ? 180 + minY : 180
                                        )
                                        .cornerRadius(0)
                                        .offset(y: minY > 0 ? -minY : 0)

                                    // Blur
                                    BlurView()
                                        .opacity(blurViewOpacity())

                                    // Title
                                    VStack(spacing: 5) {
                                        Text(viewModel.user.name)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        Text("\(viewModel.user.followers.count) Followers")
                                            .foregroundColor(.white)
                                    }
                                    .offset(y: 120)
                                    .offset(y: titleOffset > 100 ? 0 : -getTitleTextOffset())
                                    .opacity(titleOffset < 100 ? 1 : 0)
                                }
                                .clipped()
                                .frame(height: minY > 0 ? 180 + minY : nil)
                                .offset(y: minY > 0 ? -minY : -minY < 80 ? 0 : -minY - 80)
                                .onAppear {
                                    DispatchQueue.main.async {
                                        offset = minY
                                    }
                                }
                            )
                        }

                        .frame(height: 180)
                        .zIndex(1)

                        // MARK: - 2) Profile Image + Profile Info

                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                KFImage(viewModel.getAvatarURL())
                                    .placeholder {
                                        Image("blankpp")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    }
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 75, height: 75)
                                    .clipShape(Circle())
                                    .padding(8)
                                    .background(.white)
                                    .clipShape(Circle())
                                    .offset(y: -20)

                                Spacer()

                                // 将按钮包装在 ZStack 中以确保它在最上层
                                ZStack {
                                    if viewModel.isCurrentUser {
                                        Button {
                                            showEditProfile.toggle()
                                        } label: {
                                            Text("Edit Profile")
                                                .font(.system(size: 14))
                                                .fontWeight(.semibold)
                                                .foregroundColor(.black)
                                                .padding(.vertical, 6)
                                                .padding(.horizontal, 12)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(Color.gray, lineWidth: 1)
                                                )
                                        }
                                        .zIndex(2) // 确保按钮在最上层
                                    } else {
                                        FollowButton()
                                            .zIndex(2)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .contentShape(Rectangle()) // 确保整个区域可以接收点击
                            .zIndex(2) // 给整个 HStack 一个较高的 zIndex

                            // User Info
                            VStack(alignment: .leading, spacing: 4) {
                                Text(viewModel.user.name)
                                    .font(.title2)
                                    .fontWeight(.bold)

                                Text("@\(viewModel.user.username)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)

                            // User Bio & Details
                            if let bio = viewModel.user.bio, !bio.isEmpty {
                                Text(bio)
                                    .font(.subheadline)
                                    .padding(.horizontal)
                                    .padding(.vertical, 4)
                            }

                            // Location & Website
                            HStack(spacing: 24) {
                                if let location = viewModel.user.location, !location.isEmpty {
                                    HStack(spacing: 4) {
                                        Image(systemName: "mappin.circle.fill")
                                        Text(location)
                                    }
                                }

                                if let website = viewModel.user.website, !website.isEmpty {
                                    HStack(spacing: 4) {
                                        Image(systemName: "link")
                                        Text(website)
                                    }
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal)

                            // Followers Count
                            HStack(spacing: 24) {
                                HStack(spacing: 4) {
                                    Text("\(viewModel.user.following.count)")
                                        .fontWeight(.bold)
                                    Text("Following")
                                        .foregroundColor(.gray)
                                }

                                HStack(spacing: 4) {
                                    Text("\(viewModel.user.followers.count)")
                                        .fontWeight(.bold)
                                    Text("Followers")
                                        .foregroundColor(.gray)
                                }
                            }
                            .font(.subheadline)
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                        }
                        .zIndex(2) // 确保整个 Profile Info 在正确的层级

                        // MARK: - 3) TabBar (自定义滚动菜单)

                        VStack(spacing: 0) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 0) {
                                    TabButton(title: "Tweets", currentTab: $currentTab)
                                    TabButton(title: "Replies", currentTab: $currentTab)
                                    TabButton(title: "Media", currentTab: $currentTab)
                                    TabButton(title: "Likes", currentTab: $currentTab)
                                }
                            }
                            Divider()
                        }
                        .padding(.top, 16)
                        .background(colorScheme == .dark ? Color.black : Color.white)
                        .offset(y: tabBarOffset < 90 ? -tabBarOffset + 90 : 0)
                        .overlay(
                            GeometryReader { proxy in
                                Color.clear
                                    .preference(key: TabBarOffsetPreferenceKey.self, value: proxy.frame(in: .global).minY)
                                    .allowsHitTesting(false)
                            }
                            .allowsHitTesting(false) // 也要给 GeometryReader 添加
                            .onPreferenceChange(TabBarOffsetPreferenceKey.self) { value in
                                self.tabBarOffset = value
                            }
                        )
                        .zIndex(1)

                        // MARK: - 4) Tweets 列表

                        VStack(spacing: 18) {
                            ForEach(viewModel.tweets) { tweet in
                                TweetCellView(viewModel: viewModel.getTweetCellViewModel(for: tweet))
                                Divider()
                            }
                        }
                        .padding(.top)
                        .zIndex(0)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.blue)
                            .padding(8)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .ignoresSafeArea(.all, edges: .top)
        .enableInjection()
        // 添加 sheet 导航
        .sheet(isPresented: $showEditProfile) {
            if viewModel.isCurrentUser {
                EditProfileView()
            }
        }
    }

    // MARK: - 逻辑与原 UserProfile 保持一致

    // 让 Title View 有一个滑动消失/收起的动画
    func getTitleTextOffset() -> CGFloat {
        let progress = 20 / titleOffset
        // 原逻辑：最多移动 60
        let offset = 60 * (progress > 0 && progress <= 1 ? progress : 1)
        return offset
    }

    // 头像向上移动
    func getOffset() -> CGFloat {
        let progress = (-offset / 80) * 20
        // 最大上移 20
        return progress <= 20 ? progress : 20
    }

    // 头像缩放
    func getScale() -> CGFloat {
        let progress = -offset / 80
        // 1.8 - 1 = 0.8 最小缩放 0.8
        let scale = 1.8 - (progress < 1.0 ? progress : 1)
        return scale < 1 ? scale : 1
    }

    // Banner Blur
    func blurViewOpacity() -> Double {
        let progress = -(offset + 80) / 150
        return Double(-offset > 80 ? progress : 0)
    }

    // 修改 FollowButton 视图
    @ViewBuilder
    private func FollowButton() -> some View {
        Button(action: {
            if viewModel.isFollowing {
                viewModel.unfollow()
            } else {
                viewModel.follow()
            }
        }) {
            Text(viewModel.isFollowing ? "Following" : "Follow")
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundColor(viewModel.isFollowing ? .gray : .white)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(
                    Capsule()
                        .fill(viewModel.isFollowing ? Color.clear : Color.blue)
                        .overlay(
                            Capsule()
                                .stroke(Color.gray, lineWidth: viewModel.isFollowing ? 1 : 0)
                        )
                )
        }
        .animation(.easeInOut, value: viewModel.isFollowing)
    }
}

struct TabButton: View {
    let title: String
    @Binding var currentTab: String

    var body: some View {
        Button {
            currentTab = title
        } label: {
            Text(title)
                .foregroundColor(currentTab == title ? .blue : .gray)
                .padding(.horizontal, 16)
                .frame(height: 44)

            // if currentTab == title {
            //     Rectangle()
            //         .fill(Color.blue)
            //         .frame(height: 2)
            //         .matchedGeometryEffect(id: "TAB", in: animation)
            // } else {
            //     Rectangle()
            //         .fill(Color.clear)
            //         .frame(height: 2)
            // }
        }
    }
}

// 获取屏幕大小
extension View {
    func getRect() -> CGRect {
        UIScreen.main.bounds
    }
}

import Kingfisher
import SwiftUI

struct EditProfileView: View {
    @Environment(\.presentationMode) var mode
    @ObserveInjection var inject
    @EnvironmentObject private var authViewModel: AuthViewModel

    // 移除 user binding
    // @Binding var user: User
    @StateObject private var viewModel: EditProfileViewModel

    // 用户输入的状态变量
    @State private var name: String = ""
    @State private var location: String = ""
    @State private var bio: String = ""
    @State private var website: String = ""

    // 图片相关状态
    @State private var profileImage: UIImage?
    @State private var bannerImage: UIImage?

    // 添加图片选择相关状态
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var imagePickerType: ImagePickerType = .profile

    // 定义图片选择类型
    enum ImagePickerType {
        case banner
        case profile
    }

    // 修改初始化方法
    init() {
        // 使用AuthViewModel.shared.user初始化
        let user = AuthViewModel.shared.user!
        _viewModel = StateObject(wrappedValue: EditProfileViewModel(user: user))
        // 初始化各个字段
        _name = State(initialValue: user.name)
        _location = State(initialValue: user.location ?? "")
        _bio = State(initialValue: user.bio ?? "")
        _website = State(initialValue: user.website ?? "")
    }

    var body: some View {
        ZStack(alignment: .top) {
            // 主内容区域
            ScrollView {
                VStack {
                    // 图片编辑区域
                    VStack {
                        // Banner图片区域
                        ZStack {
                            if let bannerImage = bannerImage {
                                Image(uiImage: bannerImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 180)
                                    .clipShape(Rectangle())
                            } else {
                                Rectangle()
                                    .fill(Color(.systemGray6))
                                    .frame(height: 180)
                            }

                            // Banner编辑按钮
                            Button(action: {
                                imagePickerType = .banner
                                showImagePicker = true
                            }) {
                                Image(systemName: "camera")
                                    .renderingMode(.template)
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.black.opacity(0.75))
                                    .clipShape(Circle())
                            }
                        }

                        // 头像编辑区域
                        HStack {
                            Button(action: {
                                imagePickerType = .profile
                                showImagePicker = true
                            }) {
                                if let profileImage = profileImage {
                                    Image(uiImage: profileImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 75, height: 75)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: 2)
                                        )
                                } else {
                                    Circle()
                                        .fill(Color(.systemGray6))
                                        .frame(width: 75, height: 75)
                                        .overlay(
                                            Image(systemName: "camera")
                                                .foregroundColor(.white)
                                                .padding(8)
                                                .background(Color.black.opacity(0.75))
                                                .clipShape(Circle())
                                        )
                                }
                            }
                            Spacer()
                        }
                        .padding(.top, -25)
                        .padding(.bottom, -10)
                        .padding(.leading)
                        .padding(.top, -12)
                        .padding(.bottom, 12)
                    }

                    // 个人信息编辑区域
                    VStack {
                        Divider()

                        // Name字段
                        HStack {
                            ZStack {
                                HStack {
                                    Text("Name")
                                        .foregroundColor(.black)
                                        .fontWeight(.heavy)
                                    Spacer()
                                }

                                CustomProfileTextField(
                                    message: $name,
                                    placeholder: "Add your name"
                                )
                                .padding(.leading, 90)
                            }
                        }
                        .padding(.horizontal)

                        Divider()

                        // Location字段
                        HStack {
                            ZStack {
                                HStack {
                                    Text("Location")
                                        .foregroundColor(.black)
                                        .fontWeight(.heavy)
                                    Spacer()
                                }

                                CustomProfileTextField(
                                    message: $location,
                                    placeholder: "Add your location"
                                )
                                .padding(.leading, 90)
                            }
                        }
                        .padding(.horizontal)

                        Divider()

                        // Bio字段
                        HStack {
                            ZStack(alignment: .topLeading) {
                                HStack {
                                    Text("Bio")
                                        .foregroundColor(.black)
                                        .fontWeight(.heavy)
                                    Spacer()
                                }

                                CustomProfileBioTextField(bio: $bio)
                                    .padding(.leading, 86)
                                    .padding(.top, -6)
                            }
                        }
                        .padding(.horizontal)

                        Divider()

                        // Website字段
                        HStack {
                            ZStack {
                                HStack {
                                    Text("Website")
                                        .foregroundColor(.black)
                                        .fontWeight(.heavy)
                                    Spacer()
                                }

                                CustomProfileTextField(
                                    message: $website,
                                    placeholder: "Add your website"
                                )
                                .padding(.leading, 90)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 50)
            }

            // 独立覆盖的导航栏
            VStack {
                HStack {
                    Button("Cancel") {
                        mode.wrappedValue.dismiss()
                    }
                    Spacer()
                    Button(action: {
                        viewModel.save(
                            name: name,
                            bio: bio,
                            website: website,
                            location: location
                        )
                    }) {
                        Text("Save")
                            .bold()
                            .disabled(viewModel.isSaving)
                    }
                }
                .padding()
                .background(Material.ultraThin)
                .compositingGroup()
                // .shadow(radius: 2)

                Spacer()
            }

            // ImagePicker 保持原样
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
                    .presentationDetents([.large])
                    .edgesIgnoringSafeArea(.all)
                    .onDisappear {
                        guard let image = selectedImage else { return }

                        switch imagePickerType {
                        case .profile:
                            viewModel.profileImage = image // 更新 ViewModel
                            profileImage = image // 更新 View 状态
                        case .banner:
                            viewModel.bannerImage = image // 更新 ViewModel
                            bannerImage = image // 更新 View 状态
                        }

                        // 清除选中的图片
                        selectedImage = nil
                    }
            }
        }
        .onAppear {
            // 清除 Kingfisher 缓存
            KingfisherManager.shared.cache.clearCache()
        }
        .onReceive(viewModel.$uploadComplete) { complete in
            if complete {
           
                // 确保在主线程中关闭视图
                DispatchQueue.main.async {
                    mode.wrappedValue.dismiss()
                }
            }
        }

        .enableInjection()
    }
}

import Combine
import Kingfisher
import SwiftUI

// 在 class EditProfileViewModel 之前添加 AuthenticationError 枚举
enum AuthenticationError: Error {
    case custom(String)
}

class EditProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var isSaving = false
    @Published var error: Error?
    @Published var uploadComplete = false

    // 图片相关状态
    @Published var profileImage: UIImage?
    @Published var bannerImage: UIImage?
    @Published var isUploadingImage = false

    private var cancellables = Set<AnyCancellable>()

    init(user: User) {
        self.user = user

        // 可以选择是否也订阅 AuthViewModel 的变化
        AuthViewModel.shared.$user
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedUser in
                self?.user = updatedUser
            }
            .store(in: &cancellables)
    }

    func save(name: String, bio: String, website: String, location: String) {
        guard !name.isEmpty else { return }

        isSaving = true
        uploadComplete = false // 重置状态

        Task {
            do {
                // 1. 如果有新的头像图片，先上传头像
                if let newProfileImage = profileImage {
                    try await uploadProfileImage(image: newProfileImage)
                    // 清除特定URL的缓存
                    if let avatarURL = URL(string: "http://localhost:3000/users/\(user.id)/avatar") {
                        try? await KingfisherManager.shared.cache.removeImage(forKey: avatarURL.absoluteString)
                    }
                }

                // 2. 如果有新的横幅图片，上传横幅
                if bannerImage != nil {
                    // TODO: 添加上传横幅的方法
                }

                // 3. 上传用户文本数据
                let updatedUser = try await uploadUserData(
                    name: name,
                    bio: bio.isEmpty ? nil : bio,
                    website: website.isEmpty ? nil : website,
                    location: location.isEmpty ? nil : location
                )

                // 4. 如果有图片更新，清除缓存
                if profileImage != nil || bannerImage != nil {
                    try? await KingfisherManager.shared.cache.clearCache()
                }

                // 5. 在主线程更新状态
                await MainActor.run {
                    // 更新用户数据
                    self.user = updatedUser
                    AuthViewModel.shared.updateUser(updatedUser)

                    // 清除已上传的图片状态
                    self.profileImage = nil
                    self.bannerImage = nil

                    // 最后更新完成状态
                    self.isSaving = false
                    self.uploadComplete = true
                }
            } catch {
                await MainActor.run {
                    print("Error saving profile: \(error)")
                    self.error = error
                    self.isSaving = false
                    self.uploadComplete = false
                }
            }
        }
    }
import Combine
import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var tweets = [Tweet]()
    @Published var user: User
    @Published var shouldRefreshImage = false
    @Published var error: Error?
    @Published var isFollowing = false

    // 添加TweetCellViewModel缓存
    private var tweetViewModels: [String: TweetCellViewModel] = [:]
    private var lastImageRefreshTime: TimeInterval = 0
    private var cancellables = Set<AnyCancellable>()
    private var userId: String?

    var isCurrentUser: Bool {
        // 如果 userId 为空或者等于当前用户ID，则说明是查看自己
        userId == nil || userId == AuthViewModel.shared.user?.id
    }

    init(userId: String? = nil) {
        self.userId = userId

        // 先给 user 赋一个当前用户或空 user 的初始值
        if let currentUser = AuthViewModel.shared.user {
            user = currentUser
        } else {
            user = User(username: "", name: "", email: "")
        }

        // 如果是查看其他用户的profile，就调用 fetchUserData
        if let userId = userId,
           userId != AuthViewModel.shared.user?.id
        {
            fetchUserData(userId: userId)
        } else {
            // 如果是当前用户，则订阅 AuthViewModel.shared.$user
            AuthViewModel.shared.$user
                .compactMap { $0 }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] updatedUser in
                    self?.user = updatedUser
                    // 确保正确设置关注状态
                    self?.checkIfUserIsFollowed()
                    let currentTime = Date().timeIntervalSince1970
                    if currentTime - (self?.lastImageRefreshTime ?? 0) > 1.0 {
                        self?.shouldRefreshImage.toggle()
                        self?.lastImageRefreshTime = currentTime
                    }
                }
                .store(in: &cancellables)

            // 加载当前用户自己的推文
            fetchTweets()
        }
    }

    private func fetchUserData(userId: String) {
        error = nil

        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            error = AuthenticationError.custom("No token found")
            return
        }

        AuthService.fetchUser(userId: userId, token: token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(fetchedUser):
                    self?.user = fetchedUser
                    // 获取用户数据后立即检查关注状态
                    self?.checkIfUserIsFollowed()
                    self?.fetchTweets()
                case let .failure(error):
                    self?.error = error
                }
            }
        }
    }

    // 获取带时间戳的头像URL
    func getAvatarURL() -> URL? {
        let baseURL = "http://localhost:3000/users/\(user.id)/avatar"
        return URL(string: "\(baseURL)?t=\(Int(lastImageRefreshTime))")
    }

    // 获取或创建TweetCellViewModel
    func getTweetCellViewModel(for tweet: Tweet) -> TweetCellViewModel {
        if let existing = tweetViewModels[tweet.id] {
            return existing
        }

        guard let currentUser = AuthViewModel.shared.user else {
            fatalError("Current user should not be nil when creating TweetCellViewModel")
        }

        let viewModel = TweetCellViewModel(tweet: tweet, currentUser: currentUser)
        tweetViewModels[tweet.id] = viewModel
        return viewModel
    }

    // 加载推文
    func fetchTweets() {
        // 确定要请求的用户ID
        let targetUserId: String
        if let userId = userId {
            targetUserId = userId
        } else if let currentUserId = AuthViewModel.shared.user?.id {
            targetUserId = currentUserId
        } else {
            return
        }

        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            return
        }

        let urlString = "http://localhost:3000/tweets/user/\(targetUserId)"
        guard let url = URL(string: urlString) else {
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let data = data else { return }

                do {
                    let tweets = try JSONDecoder().decode([Tweet].self, from: data)
                    self?.tweets = tweets
                    self?.cleanupTweetViewModels(currentTweets: tweets)
                } catch {
                    print("Error decoding tweets: \(error)")
                }
            }
        }.resume()
    }

    // 清理不再使用的viewModel
    private func cleanupTweetViewModels(currentTweets: [Tweet]) {
        let currentIds = Set(currentTweets.map { $0.id })
        tweetViewModels = tweetViewModels.filter { currentIds.contains($0.key) }
    }

    // 在 user 里检查是否关注
    func checkIfUserIsFollowed() {
        guard let currentUserId = AuthViewModel.shared.user?.id else { return }

        // 检查目标用户的followers数组里是否包含当前用户ID
        let isFollowed = user.followers.contains(currentUserId)
        user.isFollowed = isFollowed
        isFollowing = isFollowed
    }

    func follow() {
        guard let currentUser = AuthViewModel.shared.user else { return }
        RequestServices.followingProcess(userId: user.id, isFollowing: false) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(response):
                    if response.message.contains("已经关注") {
                        self?.user.isFollowed = true
                        self?.isFollowing = true
                    } else {
                        // 修改本地目标用户数据：整体更新 followers
                        var updatedUser = self?.user ?? User(username: "", name: "", email: "")
                        updatedUser.followers.append(currentUser.id)
                        updatedUser.isFollowed = true
                        self?.user = updatedUser
                        self?.isFollowing = true
                    }

                    // 同时更新全局当前登录用户（如果本次操作涉及更新我的 following 数组）
                    if currentUser.id == AuthViewModel.shared.user?.id {
                        var globalUser = AuthViewModel.shared.user!
                        // 若全局 following 中尚未包含目标用户 ID，则追加
                        if !globalUser.following.contains(self?.user.id ?? "") {
                            globalUser.following.append(self?.user.id ?? "")
                        }
                        // 重新整体赋值全局对象，触发更新
                        AuthViewModel.shared.user = globalUser
                    }

                    RequestServices.requestDomain = "http://localhost:3000/notifications"
//                    RequestServices.sendNotification(username: currentUser.username, notSenderId: currentUser.id, notReceiverId: self?.user.id ?? "", notificationType: NotificationType.follow.rawValue, postText: "") { result in
//                        print("FOLLOWED")
//                      print(result as Any)
//                    }
                    print("Follow response: \(response.message)")
                case let .failure(error):
                    print("Follow error: \(error.localizedDescription)")
                }
            }
        }
    }

    func unfollow() {
        guard let currentUser = AuthViewModel.shared.user else { return }
        RequestServices.followingProcess(userId: user.id, isFollowing: true) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(response):
                    // 修改本地目标用户数据：整体更新 followers
                    var updatedUser = self?.user ?? User(username: "", name: "", email: "")
                    updatedUser.followers.removeAll(where: { $0 == currentUser.id })
                    updatedUser.isFollowed = false
                    self?.user = updatedUser
                    self?.isFollowing = false

                    // 同步更新全局当前登录用户的 following 列表
                    if currentUser.id == AuthViewModel.shared.user?.id {
                        var globalUser = AuthViewModel.shared.user!
                        globalUser.following.removeAll(where: { $0 == self?.user.id })
                        AuthViewModel.shared.user = globalUser
                    }
                    print("Unfollow success: \(response.message)")
                case let .failure(error):
                    print("Unfollow error: \(error.localizedDescription)")
                }
            }
        }
    }
}
import Foundation

public class AuthService {
    // 静态域名变量
    public static var requestDomain: String = ""

    // 注册API的静态URL
    private static let registerURL = "http://localhost:3000/users"

    // 添加登录URL常量
    private static let loginURL = "http://localhost:3000/users/login"

    // 添加获取用户信息的URL
    private static let userURL = "http://localhost:3000/users/"

    // MARK: - Error Types

  enum NetworkError: Error {
        case invalidURL
        case noData
        case decodingError
        case custom(String)
    }
    
    enum AuthenticationError: Error {
        case invalidCredentials
        case custom(String)
    }


 static func makeRequest(
    urlString: String,
    requestBody: [String: Any],
    completion: @escaping (Result<Data, NetworkError>) -> Void
) {
    // 1. 创建 URL
    guard let url = URL(string: urlString) else {
        completion(.failure(.invalidURL))
        return
    }

    // 2. 创建请求
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    // 3. 设置请求体
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        request.httpBody = jsonData
    } catch {
        completion(.failure(.custom("JSON序列化失败：\(error.localizedDescription)")))
        return
    }

    // 4. 创建数据任务
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        // 检查是否有错误
        if let error = error {
            completion(.failure(.custom("网络请求错误：\(error.localizedDescription)")))
            return
        }
        // 检查 HTTP 状态码
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            var errMsg = "服务器返回状态码 \(httpResponse.statusCode)"
            // 如有返回数据，尝试转换为字符串
            if let data = data, let serverMessage = String(data: data, encoding: .utf8) {
                errMsg += "，详情：\(serverMessage)"
            }
            completion(.failure(.custom(errMsg)))
            return
        }
        // 检查是否有数据
        guard let data = data else {
            completion(.failure(.noData))
            return
        }
        // 返回成功结果
        completion(.success(data))
    }

    // 5. 开始任务
    task.resume()
}
    // MARK: - Response Type

struct APIResponse: Codable {
    let user: User
    let token: String?   // 修改为可选类型
}

    // MARK: - Authentication Methods

  static func register(
    email: String,
    username: String,
    password: String,
    name: String,
    completion: @escaping (Result<User, AuthenticationError>) -> Void
) {
    // 构建请求体
    let requestBody: [String: Any] = [
        "email": email,
        "username": username,
        "password": password,
        "name": name,
    ]

    // 调用 makeRequest
    makeRequest(urlString: registerURL, requestBody: requestBody) { result in
        switch result {
        case let .success(data):
            // 尝试解码前先打印返回的字符串（便于调试）
            if let dataString = String(data: data, encoding: .utf8) {
                print("注册返回数据：\(dataString)")
            }
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                completion(.success(user))
            } catch {
                print("解码失败：\(error.localizedDescription)")
                completion(.failure(.custom("解析用户数据失败")))
            }

        case let .failure(error):
            completion(.failure(.custom(error.localizedDescription)))
        }
    }
}

    // 登录方法
    static func login(
        email: String,
        password: String,
        completion: @escaping (Result<APIResponse, AuthenticationError>) -> Void
    ) {
        // 构建请求体
        let requestBody: [String: Any] = [
            "email": email,
            "password": password,
        ]

        // 调用makeRequest
        makeRequest(urlString: loginURL, requestBody: requestBody) { result in
            switch result {
            case let .success(data):
                do {
                    let response = try JSONDecoder().decode(APIResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(.custom("Failed to decode response")))
                }

            case let .failure(error):
                switch error {
                case .noData:
                    completion(.failure(.custom("No data received")))
                case .invalidURL:
                    completion(.failure(.custom("Invalid URL")))
                case .decodingError:
                    completion(.failure(.custom("Failed to decode response")))
                  case .custom(_):
                    completion(.failure(.custom(error.localizedDescription)))
                }
            }
        }
    }

    // 获取用户信息方法
    static func fetchUser(
        userId: String,
        token: String,
        completion: @escaping (Result<User, AuthenticationError>) -> Void
    ) {
        // 构建完整的URL
        let urlString = userURL + userId

        guard let url = URL(string: urlString) else {
            completion(.failure(.custom("Invalid URL")))
            return
        }

        // 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = "GET" // 明确指定GET方法
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // 发送请求
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(.custom(error.localizedDescription)))
                return
            }

            guard let data = data else {
                completion(.failure(.custom("No data received")))
                return
            }

            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                completion(.success(user))
            } catch {
                completion(.failure(.custom("Failed to decode user data")))
            }
        }

        task.resume()
    }

    // 添加 PATCH 请求方法
    static func makePatchRequestWithAuth(
        urlString: String,
        requestBody: [String: Any],
        token: String,
        completion: @escaping (Result<Data, NetworkError>) -> Void
    ) {
        // 1. 创建 URL
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }

        // 2. 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // 3. 设置请求体
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            request.httpBody = jsonData
        } catch {
            completion(.failure(.invalidURL))
            return
        }

        // 4. 创建数据任务
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            // 检查是否有错误
            if let error = error {
                completion(.failure(.noData))
                return
            }

            // 检查是否有数据
            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            // 返回成功结果
            completion(.success(data))
        }

        // 5. 开始任务
        task.resume()
    }



    static func fetchUsers(completion: @escaping (_ result: Result<Data?, AuthenticationError>) -> Void) {
        
        let urlString = URL(string: "http://localhost:3000/users")!
        
        let urlRequest = URLRequest(url: urlString)
        
        let url = URL(string: requestDomain)!
        
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
            
        request.httpMethod = "GET"
        
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: reqBody, options: .prettyPrinted)
//        }
//        catch let error {
//            print(error)
//        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = session.dataTask(with: request) { data, res, err in
            guard err == nil else {
                
                return
                
            }
            
            guard let data = data else {
                completion(.failure(.invalidCredentials))
                return
                
            }
            
            completion(.success(data))
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    
                    
                }
                
            }
            catch let error {
                completion(.failure(.invalidCredentials))
                print(error)
            }
        }
        
        task.resume()
    }
}
// 为 NetworkError 添加 LocalizedError 支持
extension AuthService.NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的 URL。"
        case .noData:
            return "没有接收到服务器数据。"
        case .decodingError:
            return "数据解析失败。"
        case .custom(let message):
            return message
        }
    }
}

// 为 AuthenticationError 添加 LocalizedError 支持
extension AuthService.AuthenticationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "用户名或密码不正确。"
        case .custom(let message):
            return message
        }
    }
}


import Foundation

// 添加响应模型
struct FollowResponse: Codable {
    let message: String
}

// 添加点赞响应模型
struct LikeResponse: Codable {
    let message: String
}

// 添加自定义错误类型
enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case noToken
    case custom(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .noToken:
            return "No authentication token"
        case let .custom(message):
            return message
        }
    }
}

// 添加点赞响应模型
struct ErrorResponse: Codable {
    let message: String
}

public class RequestServices {
    // 修改 requestDomain 的默认值和访问级别
    public static var requestDomain: String = "http://localhost:3000"

    // 发推文的网络请求方法
    public static func postTweet(
        text: String,
        user: String,
        username: String,
        userId: String,
        completion: @escaping (Result<[String: Any]?, Error>) -> Void
    ) {
        // 构建请求URL
        guard let url = URL(string: requestDomain + "/tweets") else { return }

        // 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // 添加认证token
        guard let token = UserDefaults.standard.string(forKey: "jwt") else { return }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // 设置JSON请求头
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        // 构建请求参数
        let params: [String: Any] = [
            "text": text,
            "user": user,
            "username": username,
            "userId": userId,
        ]

        // JSON序列化
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            request.httpBody = jsonData

            // 创建数据任务
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                // 错误处理
                if let error = error {
                    completion(.failure(error))
                    return
                }

                // 解析响应数据
                guard let data = data else { return }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        completion(.success(json))
                    }
                } catch {
                    completion(.failure(error))
                }
            }

            // 开始请求
            task.resume()

        } catch {
            completion(.failure(error))
        }
    }

    // 获取推文列表的网络请求方法
    static func fetchTweets(completion: @escaping (Result<Data, Error>) -> Void) {
        // 构建请求URL
        guard let url = URL(string: requestDomain) else { return }

        // 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // 添加认证token
        guard let token = UserDefaults.standard.string(forKey: "jwt") else { return }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // 设置JSON请求头
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        // 创建数据任务
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            // 错误处理
            if let error = error {
                completion(.failure(error))
                return
            }

            // 检查并返回数据
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            completion(.success(data))
        }

        // 开始请求
        task.resume()
    }

    // 修改 followingProcess 方法
    static func followingProcess(
        userId: String,
        isFollowing: Bool,
        completion: @escaping (Result<FollowResponse, Error>) -> Void
    ) {
        // 打印当前的 requestDomain 用于调试
        print("Current requestDomain: \(requestDomain)")

        let endpoint = isFollowing ? "/unfollow" : "/follow"

        // 确保 requestDomain 末尾没有 "/"，也没有 "/tweets"
        var baseURL = requestDomain
        if baseURL.hasSuffix("/") {
            baseURL = String(baseURL.dropLast())
        }
        if baseURL.hasSuffix("/tweets") {
            baseURL = String(baseURL.dropLast(7)) // 移除 "/tweets"
        }

        // 构建完整的URL
        let urlString = "\(baseURL)/users/\(userId)\(endpoint)"
        print("Request URL: \(urlString)") // 调试日志

        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            completion(.failure(NetworkError.noToken))
            return
        }

        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        // 添加调试日志
        print("Sending \(isFollowing ? "unfollow" : "follow") request for user: \(userId)")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // 打印 HTTP 响应状态码
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            // 打印原始响应数据用于调试
            if let responseString = String(data: data, encoding: .utf8) {
                print("Server response: \(responseString)")
            }

            do {
                let response = try JSONDecoder().decode(FollowResponse.self, from: data)
                completion(.success(response))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(error))
            }
        }

        task.resume()
    }

    // 修改 likeTweet 方法
    static func likeTweet(
        tweetId: String,
        isLiked: Bool,
        completion: @escaping (Result<LikeResponse, Error>) -> Void
    ) {
        // 构建URL
        let endpoint = isLiked ? "/unlike" : "/like"
        let urlString = "http://localhost:3000/tweets/\(tweetId)\(endpoint)"

        print("Request URL: \(urlString)") // 调试日志

        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        // 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        // 添加认证
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            completion(.failure(NetworkError.noToken))
            return
        }

        // 设置请求头
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // 发送请求
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // 打印 HTTP 响应状态码和原始响应数据（用于调试）
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }

            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Raw response: \(responseString)")
            }

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            do {
                let response = try JSONDecoder().decode(LikeResponse.self, from: data)
                completion(.success(response))
            } catch {
                // 尝试解码错误响应
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    completion(.failure(NetworkError.custom(errorResponse.message)))
                } else {
                    completion(.failure(error))
                }
            }
        }

        task.resume()
    }

 static func fetchData(completion: @escaping (_ result: Result<Data?, NetworkError>) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "jwt") else {
        completion(.failure(.noToken))
        return
    }
    
    // 确保URL正确拼接
    guard let url = URL(string: requestDomain + "/notifications") else {
        completion(.failure(.invalidURL))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    // 添加认证 token
    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Status Code: \(httpResponse.statusCode)")  // 输出响应的 HTTP 状态码
        }
        
        if let error = error {
            print("Error fetching data: \(error.localizedDescription)")  // 打印请求错误
            completion(.failure(.custom(error.localizedDescription)))
            return
        }
        
        guard let data = data else {
            print("No data received")  // 没有接收到数据时的错误提示
            completion(.failure(.noData))
            return
        }
        
        // 打印返回的原始数据
        if let responseString = String(data: data, encoding: .utf8) {
            print("Raw response: \(responseString)")
        }
        
        // 验证返回的数据是否为有效的 JSON
        do {
            _ = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            completion(.success(data))
        } catch {
            print("Invalid JSON response: \(error)")  // 解析JSON失败
            completion(.failure(.custom("Invalid JSON response")))
        }
    }
    
    task.resume()
}

    public static func sendNotification(username: String, notSenderId: String, notReceiverId: String, notificationType: String, postText: String, completion: @escaping (_ result: [String: Any]?) -> Void) {
        // 确保 notificationReceiverId 是有效的字符串，并符合 MongoDB ObjectId 格式
        guard !notReceiverId.isEmpty else {
            print("Error: notificationReceiverId is empty.")
            return
        }


        // 构建请求参数
        var params: [String: Any] {
            return postText.isEmpty ? [
                "username": username,
                "notSenderId": notSenderId,
                "notReceiverId": notReceiverId, // 确保传递的是字符串
                "notificationType": notificationType
            ] : [
                "username": username,
                "notSenderId": notSenderId,
                "notReceiverId": notReceiverId, // 确保传递的是字符串
                "notificationType": notificationType,
                "postText": postText,
            ]
        }

        // 打印请求参数，调试请求
        print("Sending notification with params: \(params)") // Debugging the params being sent

        // 确保正确的请求URL
        guard let url = URL(string: requestDomain + "/notifications") else {
            print("Invalid URL for sending notification.")
            return
        }

        let session = URLSession.shared
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        } catch {
            print("Error serializing JSON: \(error)")
            return
        }

        let token = UserDefaults.standard.string(forKey: "jwt")!
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = session.dataTask(with: request) { data, _, err in
            // 打印请求错误
            if let err = err {
                print("Error sending notification: \(err.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received.")
                return
            }

            // 打印原始响应数据
            print("Raw response: \(String(data: data, encoding: .utf8) ?? "No data")")

            // 尝试解析响应
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print("Notification sent successfully: \(json)") // Debugging successful response
                    completion(json)
                }
            } catch {
                print("Error decoding response: \(error)") // Debugging response decoding error
            }
        }
        task.resume()
    }
}




    // MARK: - 上传用户信息 （真正使用 async/await，而不是在里面套闭包）

    func uploadUserData(
        name: String?,
        bio: String?,
        website: String?,
        location: String?
    ) async throws -> User {
        // 1. 获取 token
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            throw AuthenticationError.custom("No token found")
        }

        // 2. 构建请求体 - 只包含非空值
        var requestBody: [String: Any] = [:]
        if let name = name { requestBody["name"] = name }
        if let bio = bio { requestBody["bio"] = bio }
        if let website = website { requestBody["website"] = website }
        if let location = location { requestBody["location"] = location }

        print("Uploading user data:", requestBody) // 添加日志

        // 3. 构建 URL
        let urlString = "http://localhost:3000/users/me"

        // 4. 发送请求
        return try await withCheckedThrowingContinuation { continuation in
            AuthService.makePatchRequestWithAuth(
                urlString: urlString,
                requestBody: requestBody,
                token: token
            ) { result in
                switch result {
                case let .success(data):
                    do {
                        print("Received response data:", String(data: data, encoding: .utf8) ?? "") // 添加日志
                        let updatedUser = try JSONDecoder().decode(User.self, from: data)
                        continuation.resume(returning: updatedUser)
                    } catch {
                        print("Failed to decode user data:", error) // 添加日志
                        continuation.resume(throwing: error)
                    }

                case let .failure(error):
                    print("Network request failed:", error) // 添加日志
                    continuation.resume(throwing: error)
                }
            }
        }
    }

