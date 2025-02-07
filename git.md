--- a/CloneTwitter.xcodeproj/project.pbxproj
+++ b/CloneTwitter.xcodeproj/project.pbxproj
@@ -63,6 +63,8 @@
 		B609707D2D5385890032F4CF /* AuthState.swift in Sources */ = {isa = PBXBuildFile; fileRef = B609707C2D5385890032F4CF /* AuthState.swift */; };
 		B60970812D539DB20032F4CF /* AuthStateTests.swift in Sources */ = {isa = PBXBuildFile; fileRef = B609707F2D539D910032F4CF /* AuthStateTests.swift */; };
 		B60970832D53A03E0032F4CF /* TweetService.swift in Sources */ = {isa = PBXBuildFile; fileRef = B60970822D53A03E0032F4CF /* TweetService.swift */; };
+		B60970852D54514F0032F4CF /* ProfileEndpoint.swift in Sources */ = {isa = PBXBuildFile; fileRef = B60970842D54514F0032F4CF /* ProfileEndpoint.swift */; };
+		B60970872D5451E00032F4CF /* ProfileServiceProtocol..swift in Sources */ = {isa = PBXBuildFile; fileRef = B60970862D5451E00032F4CF /* ProfileServiceProtocol..swift */; };
 		B8A02EBDEE432D9F43AE0049 /* RegisterView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 7352DB6F1062A3887691EE77 /* RegisterView.swift */; };
 		B9ABDC386C8BDBE0CBBC9CED /* FeedViewModel.swift in Sources */ = {isa = PBXBuildFile; fileRef = 21E3914C4587AB9AE684B803 /* FeedViewModel.swift */; };
 		C68B29F427476AD1D169FD1C /* CreateTweetView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 3EEAC94C4DC0E8ECCA2BC71D /* CreateTweetView.swift */; };
@@ -139,6 +141,8 @@
 		B609707C2D5385890032F4CF /* AuthState.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AuthState.swift; sourceTree = "<group>"; };
 		B609707F2D539D910032F4CF /* AuthStateTests.swift */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = AuthStateTests.swift; sourceTree = "<group>"; };
 		B60970822D53A03E0032F4CF /* TweetService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = TweetService.swift; sourceTree = "<group>"; };
+		B60970842D54514F0032F4CF /* ProfileEndpoint.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ProfileEndpoint.swift; sourceTree = "<group>"; };
+		B60970862D5451E00032F4CF /* ProfileServiceProtocol..swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ProfileServiceProtocol..swift; sourceTree = "<group>"; };
 		BBCC4AAE9275D72F7B097B96 /* AuthenticationView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AuthenticationView.swift; sourceTree = "<group>"; };
 		BCD7898679A5681A2D7F6645 /* NetworkMonitor.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = NetworkMonitor.swift; sourceTree = "<group>"; };
 		C2AECAD09846AD417141E19A /* NetworkTests.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = NetworkTests.swift; sourceTree = "<group>"; };
@@ -286,7 +290,6 @@
 		69E5350703375ED09FF8E340 /* Views */ = {
 			isa = PBXGroup;
 			children = (
 				E340CE3CF26FFEAB4FAEA1EF /* Home.swift */,
 				DFEE166D9407A99E451AF8FC /* MainView.swift */,
 				A2B85D4169C23AC0BD82EAF8 /* MultilineTextField.swift */,
@@ -355,6 +358,7 @@
 		8297CC9C54CEABE5708E57AC /* Views */ = {
 			isa = PBXGroup;
 			children = (
+				3EEAC94C4DC0E8ECCA2BC71D /* CreateTweetView.swift */,
 				948E51776C95105DFE7544F7 /* FeedView.swift */,
 				D1C453EC586A0665020D9A19 /* TweetCellView.swift */,
 			);
@@ -459,6 +463,7 @@
 		A8B99AEB44D1A840C970A053 /* Services */ = {
 			isa = PBXGroup;
 			children = (
+				B60970862D5451E00032F4CF /* ProfileServiceProtocol..swift */,
 			);
 			path = Services;
 			sourceTree = "<group>";
@@ -546,6 +551,7 @@
 			children = (
 				9EE7532C0F39B842F91C343E /* APIClient.swift */,
 				D056A8A38E30020CE919701F /* APIEndpoint.swift */,
+				B60970842D54514F0032F4CF /* ProfileEndpoint.swift */,
 				68D8F78BD2DBA4CEA50A7489 /* HTTPMethod.swift */,
 				26C46E8C249AAB8C57C0E9D0 /* NetworkError.swift */,
 			);
@@ -760,6 +766,7 @@
 				B60970832D53A03E0032F4CF /* TweetService.swift in Sources */,
 				5359609EC63BA2917D3F3721 /* ContentView.swift in Sources */,
 				C68B29F427476AD1D169FD1C /* CreateTweetView.swift in Sources */,
+				B60970872D5451E00032F4CF /* ProfileServiceProtocol..swift in Sources */,
 				B609707B2D53794B0032F4CF /* App.swift in Sources */,
 				691AB3F11ABBB35A7E8D6754 /* CreateTweetViewModel.swift in Sources */,
 				A5D0225C35E129B2A6A34178 /* CustomAuthTextField.swift in Sources */,
@@ -803,6 +810,7 @@
 				1D21FAB63AFC5E606C0C2A64 /* TweetCellView.swift in Sources */,
 				B42744FB6E3E6E8F74A13B88 /* TweetCellViewModel.swift in Sources */,
 				8E0A851518B6898ECB034D49 /* User.swift in Sources */,
+				B60970852D54514F0032F4CF /* ProfileEndpoint.swift in Sources */,
 				B37C4FECC45B4A754196001D /* UserDefaultsStore.swift in Sources */,
 				39E5589799AE479A0961C12E /* WelcomeView.swift in Sources */,
 				EAC89F42A818DC9B5A14490D /* authService.swift in Sources */,
--- a/Sources/App/App.swift
+++ b/Sources/App/App.swift
@@ -11,8 +11,7 @@ import SwiftUI
 
 @main
 struct TwitterCloneApp: App {
+    
     let container: DIContainer = {
         let container = DIContainer.defaultContainer()
         
@@ -43,4 +42,4 @@ struct TwitterCloneApp: App {
                 .environmentObject(authState)
         }
     }
\ No newline at end of file
+}
--- a/Sources/App/DIContainer.swift
+++ b/Sources/App/DIContainer.swift
@@ -1,5 +1,6 @@
 import Foundation
+import SwiftUI
+
 final class DIContainer {
     private var dependencies: [String: Any] = [:]
     
@@ -50,13 +51,17 @@ final class DIContainer {
         container.register(apiClient, type: .apiClient)
         
         // 配置 AuthService
+      let authService = AuthService1(apiClient: apiClient) // 示例调用，实际请使用正确构造函数
         container.register(authService, type: .authService)
         
         // 配置 TweetService
         let tweetService = TweetService(apiClient: apiClient)
         container.register(tweetService, type: .tweetService)
         
+        // 配置 ProfileService
+        let profileService = ProfileService(apiClient: apiClient)
+        container.register(profileService, type: .profileService)
+        
         return container
     }
 }
--- a/Sources/Core/Network/Base/ProfileEndpoint.swift
+++ b/Sources/Core/Network/Base/ProfileEndpoint.swift
@@ -6,3 +6,69 @@
 //
 
 import Foundation
+
+
+enum ProfileEndpoint: APIEndpoint {
+    case fetchUserProfile(userId: String)
+    case updateProfile(data: [String: Any])
+    case fetchUserTweets(userId: String)
+    case uploadAvatar(imageData: Data)
+    case uploadBanner(imageData: Data)
+    
+    var path: String {
+        switch self {
+        case .fetchUserProfile(let userId):
+            return "/users/\(userId)"
+        case .updateProfile:
+            return "/users/me"
+        case .fetchUserTweets(let userId):
+            return "/tweets/user/\(userId)"
+        case .uploadAvatar:
+            return "/users/me/avatar"
+        case .uploadBanner:
+            return "/users/me/banner"
+        }
+    }
+    
+    var method: HTTPMethod {
+        switch self {
+        case .fetchUserProfile, .fetchUserTweets:
+            return .get
+        case .updateProfile:
+            return .patch
+        case .uploadAvatar, .uploadBanner:
+            return .post
+        }
+    }
+    
+    var body: Data? {
+        switch self {
+        case .updateProfile(let data):
+            return try? JSONSerialization.data(withJSONObject: data)
+        case .uploadAvatar(let imageData), .uploadBanner(let imageData):
+            return imageData
+        default:
+            return nil
+        }
+    }
+    
+    var headers: [String: String]? {
+        var headers = ["Content-Type": "application/json"]
+        
+        switch self {
+        case .uploadAvatar, .uploadBanner:
+            headers["Content-Type"] = "image/jpeg"
+        default: break
+        }
+        
+        if let token = UserDefaults.standard.string(forKey: "jwt") {
+            headers["Authorization"] = "Bearer \(token)"
+        }
+        
+        return headers
+    }
+    
+    var queryItems: [URLQueryItem]? {
+        return nil
+    }
+}
--- a/Sources/Features/Auth/ViewModels/AuthViewModel.swift
+++ b/Sources/Features/Auth/ViewModels/AuthViewModel.swift
@@ -1,147 +1,147 @@
+// import Foundation
+// import SwiftUI
 
+// class AuthViewModel: ObservableObject {
+//     // 添加静态共享实例
+//     static let shared = AuthViewModel()
 
+//     @Published var isAuthenticated: Bool = false
+//     @Published var user: User?
+//     @Published var error: Error?
 
+//     // 用于存储用户凭证
+//     @AppStorage("jwt") var token: String = ""
+//     @AppStorage("userId") var userId: String = ""
 
+//     // 将 init() 改为私有,确保只能通过 shared 访问
+//     private init() {
+//         // 初始化时检查认证状态
+//         checkAuthStatus()
+//     }
 
+//     private func checkAuthStatus() {
+//         // 如果有token和userId,尝试获取用户信息
+//         if !token.isEmpty && !userId.isEmpty {
+//             fetchUser()
+//         }
+//     }
 
+//    // 在 AuthViewModel 的 login 方法中
+// func login(email: String, password: String) {
+//     AuthService.login(email: email, password: password) { [weak self] result in
+//         DispatchQueue.main.async {
+//             switch result {
+//             case let .success(response):
+//                 // 保存 token 和 userId (如果 token 为 nil，则赋值为空字符串)
+//                 self?.token = response.token ?? ""
+//                 self?.userId = response.user.id
+//                 // 保存用户信息
+//                 self?.user = response.user
+//                 // 更新认证状态
+//                 self?.isAuthenticated = true
+//                 print("Logged in successfully")
 
+//             case let .failure(error):
+//                 // 处理错误
+//                 self?.error = error
+//                 print("Login error: \(error)")
+//             }
+//         }
+//     }
+// }
 
+//     // 注册方法
+//    func register(name: String, username: String, email: String, password: String) async throws {
+//      try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
+//         AuthService.register(
+//             email: email,
+//             username: username,
+//             password: password,
+//             name: name
+//         ) { [weak self] result in
+//             guard let self = self else {
+//                 continuation.resume(throwing: AuthService.AuthenticationError.custom("Self is nil"))
+//                 return
+//             }
             
+//             switch result {
+//             case let .success(user):
+//                 // 更新用户信息（此时还没有 token, 所以接下来调用 login 获取 token）
+//                 DispatchQueue.main.async {
+//                     self.user = user
+//                     // 进行登录来获取 token
+//                     self.login(email: email, password: password)
+//                     continuation.resume()
+//                 }
                 
+//             case let .failure(error):
+//                 DispatchQueue.main.async {
+//                     self.error = error
+//                     continuation.resume(throwing: error)
+//                 }
+//             }
+//         }
+//     }
+// }
 
+//     // 登出方法
+//     func signOut() {
+//         // 清除用户数据和token
+//         isAuthenticated = false
+//         user = nil
+//         token = ""
+//         userId = ""
+//     }
 
+//     // 验证token是否有效
+//     func validateToken() {
+//         // TODO: 实现token验证
+//     }
 
+//     private func fetchUser() {
+//         guard !token.isEmpty && !userId.isEmpty else { return }
 
+//         AuthService.fetchUser(userId: userId, token: token) { [weak self] result in
+//             DispatchQueue.main.async {
+//                 switch result {
+//                 case let .success(user): // 直接使用返回的 user 对象
+//                     self?.user = user
+//                     self?.isAuthenticated = true
+//                 case let .failure(error):
+//                     self?.error = error
+//                     self?.signOut() // 如果获取用户信息失败,清除认证状态
+//                 }
+//             }
+//         }
+//     }
 
+//     // 添加更新用户方法
+//     func updateUser(_ updatedUser: User) {
+//         DispatchQueue.main.async {
+//             self.user = updatedUser
+//             // 可以在这里添加持久化逻辑
+//         }
+//     }
 
+//     // 修改更新方法,添加 transaction 支持
+//     func updateCurrentUser(_ updatedUser: User, transaction: Transaction = .init()) {
+//         withTransaction(transaction) {
+//             // 只更新 following/followers 相关数据
+//             if let currentUser = self.user {
+//                 var newUser = currentUser
+//                 newUser.following = updatedUser.following
+//                 newUser.followers = updatedUser.followers
+//                 self.user = newUser
+//             }
+//         }
+//     }
 
+//     // 添加静默更新方法
+//     func silentlyUpdateFollowing(_ following: [String]) {
+//         if var currentUser = user {
+//             currentUser.following = following
+//             // 直接更新，不触发 objectWillChange
+//             user = currentUser
+//         }
+//     }
+// }
--- a/Sources/Features/Feed/ViewModels/CreateTweetViewModel.swift
+++ b/Sources/Features/Feed/ViewModels/CreateTweetViewModel.swift
@@ -1,63 +1,52 @@
 
+import SwiftUI 
+
+@MainActor
+final class CreateTweetViewModel: ObservableObject {
+    @Published var isLoading = false
+    @Published var error: Error?
+    
+    private let tweetService: TweetServiceProtocol
+    
+    init(tweetService: TweetServiceProtocol) {
+        self.tweetService = tweetService
+    }
+    
+    func createTweet(text: String, image: UIImage? = nil, currentUser: User?) async {
+        guard let user = currentUser else {
+            error = NetworkError.custom("未登录用户")
             return
         }
+        
+        isLoading = true
+        error = nil
+        
+        do {
+            let tweet = try await tweetService.createTweet(
+                text: text,
+                userId: user.id
+            )
+            
+            if let image = image {
+                try await tweetService.uploadImage(
+                    tweetId: tweet.id,
+                    image: image
+                )
             }
+            
+            isLoading = false
+        } catch {
+            self.error = error
+            isLoading = false
+            print("发送推文失败: \(error)")
         }
     }
+}
 
+#if DEBUG
+extension CreateTweetViewModel {
+    static var preview: CreateTweetViewModel {
+        CreateTweetViewModel(tweetService: MockTweetService())
     }
 }
+#endif
\ No newline at end of file
--- a/Sources/Features/Feed/ViewModels/FeedViewModel.swift
+++ b/Sources/Features/Feed/ViewModels/FeedViewModel.swift
@@ -1,86 +1,4 @@
 
 
 import SwiftUI
 import Combine
--- a/Sources/Features/Feed/ViewModels/TweetCellViewModel.swift
+++ b/Sources/Features/Feed/ViewModels/TweetCellViewModel.swift
@@ -1,99 +1,3 @@
 
 
 import SwiftUI
@@ -151,10 +55,12 @@ final class TweetCellViewModel: ObservableObject {
         }
     }
     
+  // 新增获取用户头像 URL 的方法
+      func getUserAvatarURL() -> URL? {
+          // 构造头像 URL，这里使用 tweet.userId
+          return URL(string: "http://localhost:3000/users/\(tweet.userId)/avatar")
+      }
+      
     
     var isLiked: Bool {
         tweet.didLike ?? false
@@ -163,4 +69,4 @@ final class TweetCellViewModel: ObservableObject {
     var likesCount: Int {
         tweet.likes?.count ?? 0
     }
\ No newline at end of file
+}
--- a/Sources/Features/Feed/Views/CreateTweetView.swift
+++ b/Sources/Features/Feed/Views/CreateTweetView.swift
@@ -3,15 +3,31 @@ import SwiftUI
 struct CreateTweetView: View {
     @ObserveInjection var inject
     @Environment(\.dismiss) private var dismiss
+    @Environment(\.diContainer) private var container
+    @EnvironmentObject private var authState: AuthState
+    
     @State private var tweetText: String = ""
     @State private var imagePickerPresented = false
     @State private var selectedImage: UIImage?
     @State private var postImage: Image?
+    @State private var width = UIScreen.main.bounds.width
+    
+    // Move viewModel to a computed property
+    @StateObject private var viewModel: CreateTweetViewModel = {
+        let container = DIContainer.defaultContainer()
+        let tweetService: TweetServiceProtocol = container.resolve(.tweetService) ?? 
+            TweetService(apiClient: APIClient(baseURL: APIConfig.baseURL))
+        return CreateTweetViewModel(tweetService: tweetService)
+    }()
+    
+    init() {
+        let tweetService: TweetServiceProtocol = container.resolve(.tweetService) ?? 
+            TweetService(apiClient: APIClient(baseURL: APIConfig.baseURL))
+        _viewModel = StateObject(wrappedValue: CreateTweetViewModel(
+            tweetService: tweetService
+        ))
+    }
+    
     var body: some View {
         VStack(spacing: 0) {
             // 顶部操作栏
@@ -22,15 +38,17 @@ struct CreateTweetView: View {
                     Text("Cancel")
                         .foregroundColor(.gray)
                 }
+                
                 Spacer()
+                
                 Button(action: {
+                    guard !tweetText.isEmpty else { return }
+                    Task {
+                        await viewModel.createTweet(
+                            text: tweetText,
+                            image: selectedImage,
+                            currentUser: authState.currentUser
+                        )
                         dismiss()
                     }
                 }) {
@@ -38,25 +56,15 @@ struct CreateTweetView: View {
                 }
                 .buttonStyle(.borderedProminent)
                 .cornerRadius(40)
+                .disabled(tweetText.isEmpty || viewModel.isLoading)
             }
             .padding()
+            
             MultilineTextField(text: $tweetText, placeholder: "有什么新鲜事？")
                 .padding(.horizontal)
+            
+            // 图片预览
             if let image = postImage {
                 VStack {
                     HStack(alignment: .top) {
                         image
@@ -70,12 +78,11 @@ struct CreateTweetView: View {
                     Spacer()
                 }
             }
+            
             Spacer()
+            
             // 底部工具栏
             HStack(spacing: 20) {
                 Button(action: {
                     imagePickerPresented.toggle()
                 }) {
@@ -83,12 +90,10 @@ struct CreateTweetView: View {
                         .font(.system(size: 20))
                         .foregroundColor(.blue)
                 }
+                .disabled(viewModel.isLoading)
+                
                 Spacer()
+                
                 Text("\(tweetText.count)/280")
                     .font(.subheadline)
                     .foregroundColor(.gray)
@@ -97,19 +102,30 @@ struct CreateTweetView: View {
             .padding(.vertical, 10)
             .background(Color(.systemGray6))
         }
+        .overlay {
+            if viewModel.isLoading {
+                ProgressView()
+            }
+        }
+        .alert("发送失败", isPresented: .constant(viewModel.error != nil)) {
+            Button("确定") {
+                viewModel.error = nil
+            }
+        } message: {
+            Text(viewModel.error?.localizedDescription ?? "未知错误")
+        }
         .sheet(isPresented: $imagePickerPresented) {
             loadImage()
         } content: {
             ImagePicker(image: $selectedImage)
+                .presentationDetents([.large])
+                .edgesIgnoringSafeArea(.all)
         }
         .enableInjection()
     }
 }
 
+// 图片处理扩展
 extension CreateTweetView {
     func loadImage() {
         if let image = selectedImage {
@@ -118,6 +134,3 @@ extension CreateTweetView {
     }
 }
 
--- a/Sources/Features/Feed/Views/FeedView.swift
+++ b/Sources/Features/Feed/Views/FeedView.swift
@@ -1,16 +1,19 @@
 import SwiftUI
 
+
 struct FeedView: View {
     @ObserveInjection var inject
+    @Environment(\.diContainer) private var container
+    @StateObject private var viewModel: FeedViewModel
+
+    init(container: DIContainer) {
+        let tweetService: TweetServiceProtocol = container.resolve(.tweetService) ?? TweetService(apiClient: APIClient(baseURL: APIConfig.baseURL))
+        _viewModel = StateObject(wrappedValue: FeedViewModel(tweetService: tweetService))
+    }
 
     var body: some View {
         ScrollView {
+            LazyVStack(spacing: 16) {
                 ForEach(viewModel.tweets) { tweet in
                     TweetCellView(
                         viewModel: TweetCellViewModel(
@@ -24,10 +27,18 @@ struct FeedView: View {
                     .padding(.horizontal)
                     Divider()
                 }
+            }
+        }
+        .refreshable {
+            viewModel.fetchTweets()
+        }
+        .onAppear {
+            viewModel.fetchTweets()
         }
+        .overlay {
+            if viewModel.isLoading {
+                ProgressView()
+            }
         }
         .enableInjection()
     }
--- a/Sources/Features/Feed/Views/TweetCellView.swift
+++ b/Sources/Features/Feed/Views/TweetCellView.swift
@@ -1,10 +1,11 @@
 import SwiftUI
+import Kingfisher
 
 struct TweetCellView: View {
     @ObserveInjection var inject
     @ObservedObject var viewModel: TweetCellViewModel
+    @Environment(\.diContainer) private var container
+
     var body: some View {
         VStack(alignment: .leading, spacing: 12) {
             if viewModel.likesCount > 0 {
@@ -19,29 +20,13 @@ struct TweetCellView: View {
             }
             
             HStack(alignment: .top, spacing: 12) {
+                // 头像部分：点击头像跳转到对应用户的个人主页
+              NavigationLink {
+                  ProfileView(userId: viewModel.tweet.userId, diContainer: container)
+              } label: {
+                  avatarView
+              }
+                
                 // 推文内容
                 VStack(alignment: .leading, spacing: 4) {
                     // 用户信息
@@ -86,8 +71,8 @@ struct TweetCellView: View {
                             viewModel.likeTweet()
                         }) {
                             HStack(spacing: 4) {
+                                Image(systemName: viewModel.tweet.didLike! ? "heart.fill" : "heart")
+                                    .foregroundColor(viewModel.tweet.didLike! ? .red : .gray)
                                 if let likes = viewModel.tweet.likes {
                                     Text("\(likes.count)")
                                         .font(.system(size: 12))
@@ -111,6 +96,27 @@ struct TweetCellView: View {
         .contentShape(Rectangle())
         .enableInjection()
     }
+    
+    // 抽取的头像视图
+    private var avatarView: some View {
+        Group {
+            if viewModel.isLoading {
+                ProgressView()
+                    .frame(width: 44, height: 44)
+            } else {
+                KFImage(viewModel.getUserAvatarURL())
+                    .placeholder {
+                        Circle()
+                            .fill(Color.gray)
+                            .frame(width: 44, height: 44)
+                    }
+                    .resizable()
+                    .scaledToFill()
+                    .frame(width: 44, height: 44)
+                    .clipShape(Circle())
+            }
+        }
+    }
 }
 
 // MARK: - 子视图
@@ -131,5 +137,3 @@ private struct InteractionButton: View {
         }
     }
 }
--- a/Sources/Features/Main/Views/Home.swift
+++ b/Sources/Features/Main/Views/Home.swift
@@ -1,31 +1,33 @@
 import SwiftUI
 
 struct HomeView: View {
+    @EnvironmentObject private var viewModel: AuthState
     @ObserveInjection var inject
     @Binding var selectedTab: Int
     @State private var showCreateTweetView = false
   @Binding var searchText:String
   @Binding  var isSearching:Bool
+  @Environment(\.diContainer) private var container
     var body: some View {
         ZStack(alignment: .bottomTrailing) {
             TabView(selection: $selectedTab) {
+              FeedView(container: container)
                     .tabItem {
                         Image(systemName: "house")
                         Text("Home")
                     }
                     .tag(0)
 
+//                SearchView(searchText: $searchText, isEditing: $isSearching)
+              EmptyView()
                     .tabItem {
                         Image(systemName: "magnifyingglass")
                         Text("Search")
                     }
                     .tag(1)
                 
+//              NotificationsView(user: viewModel.user!)
+              EmptyView()
                     .tabItem {
                         Image(systemName: "bell")
                         Text("Notifications")
--- a/Sources/Features/Main/Views/MainView.swift
+++ b/Sources/Features/Main/Views/MainView.swift
@@ -6,7 +6,8 @@ struct MainView: View {
     @State private var showProfile = false
     @State private var offset: CGFloat = 0
     @State private var selectedTab = 0 // 添加这行
+    @EnvironmentObject private var viewModel: AuthState
+  @Environment(\.diContainer) private var diContainer: DIContainer 
 
     // 侧边菜单宽度（为了方便修改）
     private var menuWidth: CGFloat {
@@ -49,13 +50,13 @@ struct MainView: View {
                     .allowsHitTesting(showMenu)
 
                 // 2. 侧边菜单视图
+//                SlideMenu(onProfileTap: {
+//                    showProfile = true
+//                })
+//                .frame(width: menuWidth)
+//                .background(Color.white)
+//                .offset(x: offset - menuWidth)
+//                .zIndex(2) // 添加最高层级
 
                 // 3. 用于菜单拖拽手势的透明层
                 if showMenu {
@@ -77,7 +78,7 @@ struct MainView: View {
                 }
             }
             .navigationDestination(isPresented: $showProfile) {
+                ProfileView(userId: nil, diContainer: diContainer)
             }
             .toolbar(.hidden, for: .tabBar) // 只隐藏tabBar
         }
--- a/Sources/Features/Main/Views/SettingsView.swift
+++ b/Sources/Features/Main/Views/SettingsView.swift
@@ -1,31 +1,31 @@
\ No newline at end of file
+//import SwiftUI
+//
+//struct SettingsView: View {
+//    @Environment(\.dismiss) private var dismiss
+//    @EnvironmentObject private var authViewModel: AuthViewModel
+//    
+//    var body: some View {
+//        NavigationView {
+//            List {
+//                Section {
+//                    Button(action: {
+//                        authViewModel.signOut()
+//                        dismiss()
+//                    }) {
+//                        Text("Log Out")
+//                            .foregroundColor(.red)
+//                    }
+//                }
+//            }
+//            .navigationTitle("Settings and Privacy")
+//            .navigationBarTitleDisplayMode(.inline)
+//            .toolbar {
+//                ToolbarItem(placement: .navigationBarLeading) {
+//                    Button("Cancel") {
+//                        dismiss()
+//                    }
+//                }
+//            }
+//        }
+//    }
+//}
--- a/Sources/Features/Main/Views/SlideMenu.swift
+++ b/Sources/Features/Main/Views/SlideMenu.swift
@@ -1,142 +1,142 @@
+//import Kingfisher
+//import SwiftUI
+//
+//struct SlideMenu: View {
+//    @EnvironmentObject private var authViewModel: au
+//    @State private var showSettings = false  // 添加这一行
+//
+//    var onProfileTap: () -> Void
+//    @State private var isExpanded = false
+//    @ObserveInjection var inject
+//    private var avatarURL: URL? {
+//        guard let user = authViewModel.user else {
+//            return nil
+//        }
+//        return URL(string: "http://localhost:3000/users/\(user.id)/avatar")
+//    }
+//
+//    var body: some View {
+//        VStack(alignment: .leading) {
+//            // 顶部用户信息区域
+//            HStack(alignment: .top, spacing: 0) {
+//                VStack(alignment: .leading, spacing: 0) {
+//                    Button {
+//                        onProfileTap() // 触发导航回调
+//                    } label: {
+//                        HStack {
+//                            KFImage(avatarURL)
+//                                .placeholder {
+//                                    Circle()
+//                                        .fill(.gray)
+//                                        .frame(width: 44, height: 44)
+//                                }
+//                                .resizable()
+//                                .scaledToFill()
+//                                .frame(width: 44, height: 44)
+//                                .clipShape(Circle())
+//                                .padding(.bottom, 12)
+//
+//                            VStack(alignment: .leading, spacing: 0) {
+//                                Text(authViewModel.user!.name)
+//                                    .font(.system(size: 14))
+//                                    .padding(.bottom, 4)
+//                                Text("@\(authViewModel.user!.username)")
+//                                    .font(.system(size: 12))
+//                                    .bold()
+//                                    .foregroundColor(.gray)
+//                            }
+//                        }
+//                    }
+//                    .contentShape(Rectangle())
+//                }
+//                Spacer()
+//
+//                Button(action: {
+//                    isExpanded.toggle()
+//                }) {
+//                    Image(systemName: "chevron.down")
+//                        .font(.system(size: 16))
+//                }
+//                .padding(.top, 12)
+//            }
+//
+//            // 关注信息区域
+//            HStack(spacing: 0) {
+//                Text("\(authViewModel.user!.following.count) ")
+//                    .font(.system(size: 14))
+//                    .bold()
+//                Text("Following")
+//                    .foregroundStyle(.gray)
+//                    .font(.system(size: 14))
+//                    .bold()
+//                    .padding(.trailing, 8)
+//                Text("\(authViewModel.user!.followers.count) ")
+//                    .font(.system(size: 14))
+//                    .bold()
+//                Text("Followers")
+//                    .font(.system(size: 14))
+//                    .foregroundStyle(.gray)
+//                    .bold()
+//            }
+//
+//            .padding(.top, 4)
+//
+//            // 主菜单列表区域
+//            VStack(alignment: .leading, spacing: 0) {
+//                ForEach([
+//                    ("person", "Profile"),
+//                    ("list.bullet", "Lists"),
+//                    ("number", "Topics"),
+//                    ("bookmark", "Bookmarks"),
+//                    ("sparkles", "Moments"),
+//                ], id: \.1) { icon, text in
+//                    HStack {
+//                        Image(systemName: icon)
+//                            .font(.system(size: 20))
+//                            .padding(16)
+//                            .padding(.leading, -16)
+//
+//                        Text(text)
+//                            .font(.system(size: 18))
+//                            .bold()
+//                    }
+//                }
+//            }
+//            .padding(.vertical, 12)
+//
+//            Divider()
+//                .padding(.bottom, 12 + 16)
+//
+//            // 底部区域
+//            VStack(alignment: .leading, spacing: 12) {
+//                Button {
+//                    showSettings = true
+//                } label: {
+//                    Text("Settings and privacy")
+//                        .font(.system(size: 14))
+//                        .bold()
+//                }
+//                
+//                Text("Help Center")
+//                    .font(.system(size: 14))
+//                    .foregroundStyle(.gray)
+//
+//                HStack {
+//                    Image(systemName: "lightbulb")
+//                    Spacer()
+//                    Image(systemName: "qrcode")
+//                }
+//                .font(.title3)
+//                .padding(.vertical, 12)
+//                .bold()
+//            }
+//        }
+//        .sheet(isPresented: $showSettings) {
+//            SettingsView()
+//        }
+//        .padding(.top, 12)
+//        .padding(.horizontal, 24)
+//        .frame(maxHeight: .infinity, alignment: .top)
+//        .enableInjection()
+//    }
+//}
--- a/Sources/Features/Main/Views/TopBar.swift
+++ b/Sources/Features/Main/Views/TopBar.swift
@@ -7,11 +7,11 @@ struct TopBar: View {
     @Binding var showMenu: Bool
     @Binding var offset: CGFloat
     @Binding var selectedTab: Int // 添加这行
+    @EnvironmentObject private var authViewModel: AuthState
   @Binding var searchText: String
   @Binding var isSearching: Bool
     private var avatarURL: URL? {
+        guard let user = authViewModel.currentUser else {
             return nil
         }
         return URL(string: "http://localhost:3000/users/\(user.id)/avatar")
--- a/Sources/Features/Profile/Services/ProfileServiceProtocol..swift
+++ b/Sources/Features/Profile/Services/ProfileServiceProtocol..swift
@@ -6,3 +6,108 @@
 //
 
 import Foundation
+
+
+import Foundation
+
+protocol ProfileServiceProtocol {
+    func fetchUserProfile(userId: String) async throws -> User
+    func updateProfile(data: [String: Any]) async throws -> User
+    func fetchUserTweets(userId: String) async throws -> [Tweet]
+    func uploadAvatar(imageData: Data) async throws -> User
+    func uploadBanner(imageData: Data) async throws -> User
+}
+
+final class ProfileService: ProfileServiceProtocol {
+    private let apiClient: APIClientProtocol
+    
+    init(apiClient: APIClientProtocol) {
+        self.apiClient = apiClient
+    }
+    
+    func fetchUserProfile(userId: String) async throws -> User {
+        let endpoint = ProfileEndpoint.fetchUserProfile(userId: userId)
+        return try await apiClient.sendRequest(endpoint)
+    }
+    
+    func updateProfile(data: [String: Any]) async throws -> User {
+        let endpoint = ProfileEndpoint.updateProfile(data: data)
+        return try await apiClient.sendRequest(endpoint)
+    }
+    
+    func fetchUserTweets(userId: String) async throws -> [Tweet] {
+        let endpoint = ProfileEndpoint.fetchUserTweets(userId: userId)
+        return try await apiClient.sendRequest(endpoint)
+    }
+    
+    func uploadAvatar(imageData: Data) async throws -> User {
+        let endpoint = ProfileEndpoint.uploadAvatar(imageData: imageData)
+        return try await apiClient.sendRequest(endpoint)
+    }
+    
+    func uploadBanner(imageData: Data) async throws -> User {
+        let endpoint = ProfileEndpoint.uploadBanner(imageData: imageData)
+        return try await apiClient.sendRequest(endpoint)
+    }
+}
+
+
+
+
+#if DEBUG
+final class MockProfileService: ProfileServiceProtocol {
+    var shouldSucceed = true
+    
+    func fetchUserProfile(userId: String) async throws -> User {
+        if shouldSucceed {
+            return User.mock
+        } else {
+            throw NetworkError.unauthorized
+        }
+    }
+    
+    func updateProfile(data: [String: Any]) async throws -> User {
+        if shouldSucceed {
+            return User.mock
+        } else {
+            throw NetworkError.unauthorized
+        }
+    }
+    
+    func fetchUserTweets(userId: String) async throws -> [Tweet] {
+        if shouldSucceed {
+            return [.mock]
+        } else {
+            throw NetworkError.unauthorized
+        }
+    }
+    
+    func uploadAvatar(imageData: Data) async throws -> User {
+        if shouldSucceed {
+            return User.mock
+        } else {
+            throw NetworkError.unauthorized
+        }
+    }
+    
+    func uploadBanner(imageData: Data) async throws -> User {
+        if shouldSucceed {
+            return User.mock
+        } else {
+            throw NetworkError.unauthorized
+        }
+    }
+}
+
+//private extension Tweet {
+//    static var mock: Tweet {
+//        Tweet(
+//            _id: "mock_tweet_id",
+//            text: "This is a mock tweet",
+//            userId: "mock_user_id",
+//            username: "mock_user",
+//            user: "Mock User"
+//        )
+//    }
+//}
+#endif
--- a/Sources/Features/Profile/ViewModels/EditProfileViewModel.swift
+++ b/Sources/Features/Profile/ViewModels/EditProfileViewModel.swift
@@ -1,181 +1,181 @@
+// import Combine
+// import Kingfisher
+// import SwiftUI
+
+// // 在 class EditProfileViewModel 之前添加 AuthenticationError 枚举
+// enum AuthenticationError: Error {
+//     case custom(String)
+// }
+
+// class EditProfileViewModel: ObservableObject {
+//     @Published var user: User
+//     @Published var isSaving = false
+//     @Published var error: Error?
+//     @Published var uploadComplete = false
+
+//     // 图片相关状态
+//     @Published var profileImage: UIImage?
+//     @Published var bannerImage: UIImage?
+//     @Published var isUploadingImage = false
+
+//     private var cancellables = Set<AnyCancellable>()
+
+//     init(user: User) {
+//         self.user = user
+
+//         // 可以选择是否也订阅 AuthViewModel 的变化
+//         AuthViewModel.shared.$user
+//             .compactMap { $0 }
+//             .receive(on: DispatchQueue.main)
+//             .sink { [weak self] updatedUser in
+//                 self?.user = updatedUser
+//             }
+//             .store(in: &cancellables)
+//     }
+
+//     func save(name: String, bio: String, website: String, location: String) {
+//         guard !name.isEmpty else { return }
+
+//         isSaving = true
+//         uploadComplete = false // 重置状态
+
+//         Task {
+//             do {
+//                 // 1. 如果有新的头像图片，先上传头像
+//                 if let newProfileImage = profileImage {
+//                     try await uploadProfileImage(image: newProfileImage)
+//                     // 清除特定URL的缓存
+//                     if let avatarURL = URL(string: "http://localhost:3000/users/\(user.id)/avatar") {
+//                         try? await KingfisherManager.shared.cache.removeImage(forKey: avatarURL.absoluteString)
+//                     }
+//                 }
+
+//                 // 2. 如果有新的横幅图片，上传横幅
+//                 if bannerImage != nil {
+//                     // TODO: 添加上传横幅的方法
+//                 }
+
+//                 // 3. 上传用户文本数据
+//                 let updatedUser = try await uploadUserData(
+//                     name: name,
+//                     bio: bio.isEmpty ? nil : bio,
+//                     website: website.isEmpty ? nil : website,
+//                     location: location.isEmpty ? nil : location
+//                 )
+
+//                 // 4. 如果有图片更新，清除缓存
+//                 if profileImage != nil || bannerImage != nil {
+//                     try? await KingfisherManager.shared.cache.clearCache()
+//                 }
+
+//                 // 5. 在主线程更新状态
+//                 await MainActor.run {
+//                     // 更新用户数据
+//                     self.user = updatedUser
+//                     AuthViewModel.shared.updateUser(updatedUser)
+
+//                     // 清除已上传的图片状态
+//                     self.profileImage = nil
+//                     self.bannerImage = nil
+
+//                     // 最后更新完成状态
+//                     self.isSaving = false
+//                     self.uploadComplete = true
+//                 }
+//             } catch {
+//                 await MainActor.run {
+//                     print("Error saving profile: \(error)")
+//                     self.error = error
+//                     self.isSaving = false
+//                     self.uploadComplete = false
+//                 }
+//             }
+//         }
+//     }
+
+//     // MARK: - 上传用户信息 （真正使用 async/await，而不是在里面套闭包）
+
+//     func uploadUserData(
+//         name: String?,
+//         bio: String?,
+//         website: String?,
+//         location: String?
+//     ) async throws -> User {
+//         // 1. 获取 token
+//         guard let token = UserDefaults.standard.string(forKey: "jwt") else {
+//             throw AuthenticationError.custom("No token found")
+//         }
+
+//         // 2. 构建请求体 - 只包含非空值
+//         var requestBody: [String: Any] = [:]
+//         if let name = name { requestBody["name"] = name }
+//         if let bio = bio { requestBody["bio"] = bio }
+//         if let website = website { requestBody["website"] = website }
+//         if let location = location { requestBody["location"] = location }
+
+//         print("Uploading user data:", requestBody) // 添加日志
+
+//         // 3. 构建 URL
+//         let urlString = "http://localhost:3000/users/me"
+
+//         // 4. 发送请求
+//         return try await withCheckedThrowingContinuation { continuation in
+//             AuthService.makePatchRequestWithAuth(
+//                 urlString: urlString,
+//                 requestBody: requestBody,
+//                 token: token
+//             ) { result in
+//                 switch result {
+//                 case let .success(data):
+//                     do {
+//                         print("Received response data:", String(data: data, encoding: .utf8) ?? "") // 添加日志
+//                         let updatedUser = try JSONDecoder().decode(User.self, from: data)
+//                         continuation.resume(returning: updatedUser)
+//                     } catch {
+//                         print("Failed to decode user data:", error) // 添加日志
+//                         continuation.resume(throwing: error)
+//                     }
+
+//                 case let .failure(error):
+//                     print("Network request failed:", error) // 添加日志
+//                     continuation.resume(throwing: error)
+//                 }
+//             }
+//         }
+//     }
+
+//     // MARK: - 上传头像 (也改成 async)
+
+//     func uploadProfileImage(image: UIImage) async throws {
+//         // 1. 定义 URL 路径
+//         let urlPath = "/users/me/avatar"
+
+//         // 2. 用 continuation 等到上传结束
+//         try await withCheckedThrowingContinuation { continuation in
+//             ImageUploader.uploadImage(
+//                 paramName: "avatar",
+//                 fileName: "profile_image.jpeg",
+//                 image: image,
+//                 urlPath: urlPath
+//             ) { [weak self] result in
+//                 guard let self = self else { return }
+
+//                 switch result {
+//                 case let .success(json):
+//                     print("Profile image uploaded successfully: \(json)")
+//                     // 清除 Kingfisher 缓存以更新 UI
+//                     KingfisherManager.shared.cache.clearCache()
+//                     // 不要在这里 toggle self.uploadComplete，因为还要等文本信息一起更新
+//                     continuation.resume(returning: ())
+
+//                 case let .failure(error):
+//                     print("Failed to upload profile image: \(error)")
+//                     DispatchQueue.main.async {
+//                         self.error = error
+//                     }
+//                     continuation.resume(throwing: error)
+//                 }
+//             }
+//         }
+//     }
+// }
--- a/Sources/Features/Profile/ViewModels/ProfileViewModel.swift
+++ b/Sources/Features/Profile/ViewModels/ProfileViewModel.swift
@@ -1,254 +1,118 @@
 import SwiftUI
+import Foundation
 
+@MainActor
+final class ProfileViewModel: ObservableObject {
+    private let profileService: ProfileServiceProtocol
+    private let userId: String?  // 外部传入的目标用户ID；若为 nil，则表示显示当前用户
+    
+    @Published var user: User?
+    @Published var tweets: [Tweet] = []
+    @Published var isLoading = false
+    @Published var errorMessage: String?  // 重命名为 errorMessage
     @Published var shouldRefreshImage = false
+    
     private var lastImageRefreshTime: TimeInterval = 0
+    
+    // 如果 userId 为 nil，则表示显示当前用户的资料
     var isCurrentUser: Bool {
+        guard let profileUserId = user?.id else { return false }
+        return userId == nil || userId == profileUserId
     }
+    
+    init(profileService: ProfileServiceProtocol, userId: String? = nil) {
+        self.profileService = profileService
         self.userId = userId
+        
+        Task {
+            await fetchProfile()
         }
     }
     
+    func fetchProfile() async {
+        isLoading = true
+        errorMessage = nil
+        defer { isLoading = false }
+        
+        do {
+            // 如果 userId 为 nil，则使用当前已加载的 user 的 id（或者你可以通过父视图传入当前用户ID）
+            let targetUserId = userId ?? self.user?.id
+            guard let targetUserId = targetUserId else {
+                throw NetworkError.custom("No user ID available")
             }
+            
+            async let profile = self.profileService.fetchUserProfile(userId: targetUserId)
+            async let userTweets = self.profileService.fetchUserTweets(userId: targetUserId)
+           
+            let (fetchedProfile, fetchedTweets) = try await (profile, userTweets)
+          
+     
+            self.user = fetchedProfile
+            self.tweets = fetchedTweets
+            
+        } catch let networkError as NetworkError {
+            errorMessage = networkError.errorDescription
+        } catch {
+            errorMessage = error.localizedDescription
         }
     }
+    
+    func updateProfile(data: [String: Any]) async {
+        isLoading = true
+        errorMessage = nil
+        defer { isLoading = false }
+        
+        do {
+            let updatedUser = try await self.profileService.updateProfile(data: data)
+            self.user = updatedUser
+        } catch let networkError as NetworkError {
+            errorMessage = networkError.errorDescription
+        } catch {
+            errorMessage = error.localizedDescription
         }
     }
+    
+    func uploadAvatar(imageData: Data) async {
+        await performImageUpload {
+            try await self.profileService.uploadAvatar(imageData: imageData)
         }
     }
     
+    // 如果后端不支持上传 Banner，建议移除此方法或返回错误
+    func uploadBanner(imageData: Data) async {
+        await performImageUpload {
+            try await self.profileService.uploadBanner(imageData: imageData)
         }
     }
     
+    private func performImageUpload(_ upload: @escaping () async throws -> User) async {
+        isLoading = true
+        errorMessage = nil
+        defer { isLoading = false }
+        
         do {
+            let updatedUser = try await upload()
+            self.user = updatedUser
+            self.lastImageRefreshTime = Date().timeIntervalSince1970
+            self.shouldRefreshImage.toggle()
+        } catch let networkError as NetworkError {
+            errorMessage = networkError.errorDescription
         } catch {
+            errorMessage = error.localizedDescription
         }
     }
     
+    func getAvatarURL() -> URL? {
+        guard let userId = user?.id else { return nil }
+        let baseURL = "\(APIConfig.baseURL)/users/\(userId)/avatar"
+        return URL(string: "\(baseURL)?t=\(Int(lastImageRefreshTime))")
     }
 }
+
+#if DEBUG
+extension ProfileViewModel {
+    static var preview: ProfileViewModel {
+        ProfileViewModel(profileService: MockProfileService())
+    }
 }
+#endif
--- a/Sources/Features/Profile/Views/BlurView.swift
+++ b/Sources/Features/Profile/Views/BlurView.swift
@@ -1,17 +1,17 @@
+// import SwiftUI
+// import UIKit 
 
 
+// struct BlurView: UIViewRepresentable {
+//     func makeUIView(context: Context) -> UIVisualEffectView {
+//         let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
+//         return view
+//     }
     
+//     func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
+//         // No update needed
+//     }
 
 
 
\ No newline at end of file
+// }
--- a/Sources/Features/Profile/Views/EditProfileView.swift
+++ b/Sources/Features/Profile/Views/EditProfileView.swift
@@ -3,12 +3,8 @@ import SwiftUI
 
 struct EditProfileView: View {
     @Environment(\.presentationMode) var mode
+    @EnvironmentObject private var authState: AuthState // 若需要访问全局登录状态
+    @ObservedObject var viewModel: ProfileViewModel // 使用同一个 ProfileViewModel
 
     // 用户输入的状态变量
     @State private var name: String = ""
@@ -20,27 +16,27 @@ struct EditProfileView: View {
     @State private var profileImage: UIImage?
     @State private var bannerImage: UIImage?
 
+    // 图片选择器相关状态
     @State private var showImagePicker = false
     @State private var selectedImage: UIImage?
     @State private var imagePickerType: ImagePickerType = .profile
 
     enum ImagePickerType {
         case banner
         case profile
     }
 
+    // 初始化，从 ProfileViewModel.user 中读取现有数据
+    init(viewModel: ProfileViewModel) {
+        _viewModel = ObservedObject(wrappedValue: viewModel)
+
+        // 若 user 还没加载成功，可以在这里做安全处理
+        if let user = viewModel.user {
+            _name = State(initialValue: user.name)
+            _location = State(initialValue: user.location ?? "")
+            _bio = State(initialValue: user.bio ?? "")
+            _website = State(initialValue: user.website ?? "")
+        }
     }
 
     var body: some View {
@@ -204,7 +200,7 @@ struct EditProfileView: View {
                 .padding(.top, 50)
             }
 
+            // 顶部导航栏
             VStack {
                 HStack {
                     Button("Cancel") {
@@ -212,27 +208,28 @@ struct EditProfileView: View {
                     }
                     Spacer()
                     Button(action: {
+                        Task {
+                            await viewModel.updateProfile(data: [
+                                "name": name,
+                                "bio": bio,
+                                "website": website,
+                                "location": location,
+                            ])
+                        }
                     }) {
                         Text("Save")
                             .bold()
+                            .disabled(viewModel.isLoading) // or some other condition
                     }
                 }
                 .padding()
                 .background(Material.ultraThin)
                 .compositingGroup()
 
                 Spacer()
             }
 
+            // ImagePicker 弹窗
             .sheet(isPresented: $showImagePicker) {
                 ImagePicker(image: $selectedImage)
                     .presentationDetents([.large])
@@ -240,34 +237,42 @@ struct EditProfileView: View {
                     .onDisappear {
                         guard let image = selectedImage else { return }
 
+                        // 将选中的 UIImage 转成 jpegData
+                        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
+
                         switch imagePickerType {
                         case .profile:
+                            // 上传头像
+                            Task {
+                                await viewModel.uploadAvatar(imageData: data)
+                            }
+                            profileImage = image // 更新界面预览
+
                         case .banner:
+                            // 上传 banner
+                            Task {
+                                await viewModel.uploadBanner(imageData: data)
+                            }
+                            bannerImage = image // 更新界面预览
                         }
 
                         selectedImage = nil
                     }
             }
         }
+        // 当上传或更新完成后，自动关闭
+        .onReceive(viewModel.$shouldRefreshImage) { _ in
+            // 如果需要在图片上传完立即退出，可在这里进行 dismiss
+//            mode.dismss()
+        }
+        // 如果希望等待一切保存都完成再退出，可另加逻辑
+        .onReceive(viewModel.$user) { updatedUser in
+            // 可选：若 updatedUser != nil，说明资料更新完毕
+//            updatedUser != nil
+        }
         .onAppear {
+            // 可选：清除缓存或其他逻辑
             KingfisherManager.shared.cache.clearCache()
         }
     }
 }
--- a/Sources/Features/Profile/Views/ProfileView.swift
+++ b/Sources/Features/Profile/Views/ProfileView.swift
@@ -1,381 +1,384 @@
+//
+//  ProfileView.swift
+//  twitter-clone (iOS)
+//  Created by cem on 7/31/21.
+//
+
+import SwiftUI
+import Kingfisher
+
+// MARK: - BlurView 实现
+struct BlurView: UIViewRepresentable {
+    var style: UIBlurEffect.Style = .light
+    func makeUIView(context: Context) -> UIVisualEffectView {
+        UIVisualEffectView(effect: UIBlurEffect(style: style))
     }
+    func updateUIView(_ uiView: UIVisualEffectView, context: Context) { }
 }
 
+// MARK: - PreferenceKey 用于传递滚动偏移
+struct ScrollOffsetPreferenceKey: PreferenceKey {
     static var defaultValue: CGFloat = 0
     static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
         value = nextValue()
     }
 }
 
+// MARK: - ProfileView 主界面
 struct ProfileView: View {
     @StateObject private var viewModel: ProfileViewModel
+    var isCurrentUser: Bool { viewModel.isCurrentUser }
+    
+    // For Dark Mode Adoption
     @Environment(\.colorScheme) var colorScheme
+    @Environment(\.diContainer) private var diContainer: DIContainer
 
+    @State var currentTab = "Tweets"
+    
+    // For Smooth Slide Animation...
+    @Namespace var animation
+    @State var offset: CGFloat = 0            // 记录 Header 的滚动偏移（由 PreferenceKey 更新）
+    @State var titleOffset: CGFloat = 0         // 用于计算标题上移量
+    @State var tabBarOffset: CGFloat = 0
+
+    // 头像及其它状态
+    @State private var selectedImage: UIImage?
+    @State var profileImage: Image?
+    @State var imagePickerRepresented = false
+    @State var editProfileShow = false
+
+    @State var width = UIScreen.main.bounds.width
+    
+    // 初始化：若 userId 为 nil，则显示当前用户；否则显示指定用户的信息
+    init(userId: String? = nil, diContainer: DIContainer) {
+        guard let service: ProfileServiceProtocol = diContainer.resolve(.profileService) else {
+            fatalError("ProfileService 未在 DIContainer 中注册")
+        }
+        _viewModel = StateObject(wrappedValue: ProfileViewModel(profileService: service, userId: userId))
     }
+    
     var body: some View {
+        ScrollView(.vertical, showsIndicators: false) {
+            VStack(spacing: 15) {
+                // Header (Banner) View
+                GeometryReader { proxy -> AnyView in
+                    // 使用命名坐标空间 "scroll" 得到准确的偏移
+                    let minY = proxy.frame(in: .named("scroll")).minY
+                    return AnyView(
+                        ZStack {
+                            // Banner 图片：高度为 180，下拉时高度增加
+                            Image("SSC_banner")
+                                .resizable()
+                                .aspectRatio(contentMode: .fill)
+                                .frame(width: getRect().width, height: minY > 0 ? 180 + minY : 180)
+                                .clipped()
+                            
+                            // 模糊效果：从 20 点开始逐渐出现，到 80 点全模糊
+                            BlurView(style: .light)
+                                .opacity(blurViewOpacity())
+                            
+                            // 标题文本：显示用户名和 "150 Tweets"
+                            VStack(spacing: 5) {
+                                Text(viewModel.user?.name ?? "")
+                                    .fontWeight(.bold)
+                                    .foregroundColor(.white)
+                                Text("150 Tweets")
+                                    .foregroundColor(.white)
+                            }
+                            // 初始偏移为 120，向上滚动时上移一定距离（使用 textOffset）
+                            .offset(y: 120 - getTitleTextOffset())
+                            // 当向上滚动超过 80 点时，文本开始淡出
+                            .opacity(max(1 - ((max(-offset, 0) - 80) / 70), 0))
+                        }
+                        .frame(height: minY > 0 ? 180 + minY : 180)
+                        // Sticky & Stretchy 效果
+                        .offset(y: minY > 0 ? -minY : (-minY < 80 ? 0 : -minY - 80))
+                        // 通过 Preference 将 minY 传递出去
+                        .background(Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: minY))
+                    )
                 }
+                .frame(height: 180)
+                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
+                    self.offset = value
+                    // 这里直接使用 -value 作为向上滚动距离（正值）
+                    self.titleOffset = max(-value, 0)
+                }
+                .zIndex(1)
+                
+                // Profile Image 及其它信息部分
+                VStack {
+                    HStack {
+                        VStack {
+                            if profileImage == nil {
+                                Button {
+                                    self.imagePickerRepresented.toggle()
+                                } label: {
+                                    KFImage(viewModel.getAvatarURL())
+                                        .placeholder {
+                                            Image("blankpp")
+                                                .resizable()
+                                                .aspectRatio(contentMode: .fill)
+                                                .frame(width: 75, height: 75)
+                                                .clipShape(Circle())
+                                        }
                                         .resizable()
                                         .aspectRatio(contentMode: .fill)
+                                        .frame(width: 75, height: 75)
+                                        .clipShape(Circle())
+                                        .padding(8)
+                                        .background(colorScheme == .dark ? Color.black : Color.white)
+                                        .clipShape(Circle())
+                                        // 根据滚动偏移调整头像垂直位置与缩放
+                                        .offset(y: offset < 0 ? getAvatarOffset() : -20)
+                                        .scaleEffect(getAvatarScale())
                                 }
+                            } else if let image = profileImage {
+                                VStack {
+                                    HStack(alignment: .top) {
+                                        image
                                             .resizable()
                                             .aspectRatio(contentMode: .fill)
+                                            .frame(width: 75, height: 75)
+                                            .clipShape(Circle())
+                                            .padding(8)
+                                            .background(colorScheme == .dark ? Color.black : Color.white)
+                                            .clipShape(Circle())
+                                            .offset(y: offset < 0 ? getAvatarOffset() : -20)
                                     }
+                                    .padding()
+                                    Spacer()
                                 }
                             }
+                        }
+                        Spacer()
+                        if self.isCurrentUser {
+                            Button(action: {
+                                editProfileShow.toggle()
+                            }, label: {
+                                Text("Edit Profile")
+                                    .foregroundColor(.blue)
+                                    .padding(.vertical, 10)
                                     .padding(.horizontal)
+                                    .background(
+                                        Capsule().stroke(Color.blue, lineWidth: 1.5)
+                                    )
+                            })
+                            .onAppear {
+                                KingfisherManager.shared.cache.clearCache()
                             }
+                            .sheet(isPresented: $editProfileShow, onDismiss: {
+                                KingfisherManager.shared.cache.clearCache()
+                            }, content: {
+                                // EditProfileView(user: $viewModel.user)
+                            })
+                        }
+                    }
+                    .padding(.top, -25)
+                    .padding(.bottom, -10)
+                    
+                    // Profile Data 区域
+                    HStack {
+                        VStack(alignment: .leading, spacing: 8) {
+                            Text(viewModel.user?.name ?? "")
+                                .font(.title2)
+                                .fontWeight(.bold)
+                                .foregroundColor(.primary)
+                            Text("@\(viewModel.user?.username ?? "")")
+                                .foregroundColor(.gray)
+                            Text(viewModel.user?.bio ?? "Make education not fail! 4️⃣2️⃣ Founder @TurmaApp soon.. @ProbableApp")
+                            HStack(spacing: 8) {
+                                if let userLocation = viewModel.user?.location, !userLocation.isEmpty {
+                                    HStack(spacing: 2) {
                                         Image(systemName: "mappin.circle.fill")
+                                            .frame(width: 24, height: 24)
+                                            .foregroundColor(.gray)
+                                        Text(userLocation)
+                                            .foregroundColor(.gray)
+                                            .font(.system(size: 14))
                                     }
                                 }
+                                if let userWebsite = viewModel.user?.website, !userWebsite.isEmpty {
+                                    HStack(spacing: 2) {
                                         Image(systemName: "link")
+                                            .frame(width: 24, height: 24)
+                                            .foregroundColor(.gray)
+                                        Text(userWebsite)
+                                            .foregroundColor(Color("twitter"))
+                                            .font(.system(size: 14))
                                     }
                                 }
                             }
+                            HStack(spacing: 5) {
+                                Text("4,560")
+                                    .foregroundColor(.primary)
+                                    .fontWeight(.semibold)
+                                Text("Followers")
+                                    .foregroundColor(.gray)
+                                Text("680")
+                                    .foregroundColor(.primary)
+                                    .fontWeight(.semibold)
+                                    .padding(.leading, 10)
+                                Text("Following")
+                                    .foregroundColor(.gray)
                             }
+                            .padding(.top, 8)
                         }
+                        .padding(.leading, 8)
                         .overlay(
+                            GeometryReader { proxy -> Color in
+                                let minY = proxy.frame(in: .global).minY
+                                // 此处可以根据需要更新 titleOffset（或其他状态）
+                                DispatchQueue.main.async {
+                                    self.titleOffset = max(-minY, 0)
+                                }
+                                return Color.clear
                             }
+                            .frame(width: 0, height: 0),
+                            alignment: .top
                         )
+                        Spacer()
+                    }
+                    
+                    // 分段菜单
+                    VStack(spacing: 0) {
+                        ScrollView(.horizontal, showsIndicators: false) {
+                            HStack(spacing: 0) {
+                                TabButton(title: "Tweets", currentTab: $currentTab, animation: animation)
+                                TabButton(title: "Tweets & Likes", currentTab: $currentTab, animation: animation)
+                                TabButton(title: "Media", currentTab: $currentTab, animation: animation)
+                                TabButton(title: "Likes", currentTab: $currentTab, animation: animation)
                             }
                         }
+                        Divider()
                     }
+                    .padding(.top, 30)
+                    .background(colorScheme == .dark ? Color.black : Color.white)
+                    .offset(y: tabBarOffset < 90 ? -tabBarOffset + 90 : 0)
+                    .overlay(
+                        GeometryReader { reader -> Color in
+                            let minY = reader.frame(in: .global).minY
+                            DispatchQueue.main.async {
+                                self.tabBarOffset = minY
+                            }
+                            return Color.clear
+                        }
+                        .frame(width: 0, height: 0),
+                        alignment: .top
+                    )
+                    .zIndex(1)
+                    
+                    // 推文列表
+                    TweetListView(tweets: viewModel.tweets, viewModel: viewModel)
+                        .zIndex(0)
                 }
+                .padding(.horizontal)
+                .zIndex(-offset > 80 ? 0 : 1)
             }
         }
+        .coordinateSpace(name: "scroll")
+        // .toolbarBackground(.hidden, for: .navigationBar)
         .ignoresSafeArea(.all, edges: .top)
     }
+    
+    // MARK: - 辅助函数
+    
+    func getRect() -> CGRect {
+        UIScreen.main.bounds
     }
+    
+    // 头像缩放效果：向上滚动时从 1.0 缩放到 0.8
+    func getAvatarScale() -> CGFloat {
+        let currentOffset = max(-offset, 0)
+        let maxOffset: CGFloat = 80
+        let minScale: CGFloat = 0.8
+        let progress = min(currentOffset / maxOffset, 1)
+        return 1.0 - progress * (1.0 - minScale)
     }
+    
+    // 头像垂直偏移：向上滚动时最多平移 20 点
+    func getAvatarOffset() -> CGFloat {
+        let currentOffset = max(-offset, 0)
+        let maxOffset: CGFloat = 20
+        let progress = min(currentOffset / 80, 1)
+        return progress * maxOffset
     }
+    
+    // 标题文本上移：这里采用简单公式：上移量 = (-offset) * 0.5
+    func getTitleTextOffset() -> CGFloat {
+        return max(-offset, 0) * 0.5
+    }
+    
+    // 模糊透明度：初始完全清晰，当向上滚动超过 20 点后开始模糊，到 80 点时全模糊
     func blurViewOpacity() -> Double {
+        let currentOffset = max(-offset, 0)
+        let startBlur: CGFloat = 20
+        let fullBlur: CGFloat = 80
+        if currentOffset < startBlur {
+            return 0
+        } else {
+            let progress = min((currentOffset - startBlur) / (fullBlur - startBlur), 1)
+            return Double(progress)
+        }
     }
+}
 
+extension View {
+    func getRect() -> CGRect {
+        UIScreen.main.bounds
     }
 }
 
+// MARK: - TabButton
 struct TabButton: View {
+    var title: String
     @Binding var currentTab: String
+    var animation: Namespace.ID
+    
     var body: some View {
+        Button(action: {
+            withAnimation {
+                currentTab = title
+            }
+        }, label: {
+            LazyVStack(spacing: 12) {
+                Text(title)
+                    .fontWeight(.semibold)
+                    .foregroundColor(currentTab == title ? .blue : .gray)
+                    .padding(.horizontal)
+                if currentTab == title {
+                    Capsule()
+                        .fill(Color.blue)
+                        .frame(height: 1.2)
+                        .matchedGeometryEffect(id: "TAB", in: animation)
+                } else {
+                    Capsule()
+                        .fill(Color.clear)
+                        .frame(height: 1.2)
+                }
+            }
+        })
     }
 }
 
+// MARK: - TweetListView
+struct TweetListView: View {
+    var tweets: [Tweet]
+    var viewModel: ProfileViewModel
+    @Environment(\.diContainer) private var container
+    
+    var body: some View {
+        VStack(spacing: 18) {
+            ForEach(tweets) { tweet in
+                TweetCellView(
+                    viewModel: TweetCellViewModel(
+                        tweet: tweet,
+                        tweetService: container.resolve(.tweetService) ?? TweetService(apiClient: APIClient(baseURL: APIConfig.baseURL))
+                    )
+                )
+                Divider()
+            }
+        }
+        .padding(.top)
+        .zIndex(0)
     }
+}
\ No newline at end of file
--- a/Sources/Features/Search/Views/SearchView.swift
+++ b/Sources/Features/Search/Views/SearchView.swift
@@ -1,46 +1,46 @@
+//import Kingfisher
+//import SwiftUI
+//
+//struct SearchView: View {
+//    @EnvironmentObject private var authViewModel: AuthViewModel
+//    @ObservedObject var viewModel = SearchViewModel()
+//    @ObserveInjection var inject
+//    
+//    // 从 TopBar 传入的搜索状态
+//    @Binding var searchText: String
+//    @Binding var isEditing: Bool
+//    
+//    var users: [User] {
+//        return searchText.isEmpty ? viewModel.users : viewModel.filteredUsers(searchText)
+//    }
+//
+//    var body: some View {
+//        ScrollView {
+//            VStack {
+//                LazyVStack {
+//                    ForEach(users) { user in
+//                        NavigationLink(destination: ProfileView(userId: user.id)) {
+//                            SearchUserCell(user: user)
+//                                .padding(.leading)
+//                        }
+//                    }
+//                }
+//                .transition(
+//                    .asymmetric(
+//                        insertion: .move(edge: .trailing).combined(with: .opacity),
+//                        removal: .move(edge: .leading).combined(with: .opacity)
+//                    )
+//                )
+//            }
+//            .animation(
+//                .spring(
+//                    response: 0.4,
+//                    dampingFraction: 0.7,
+//                    blendDuration: 0.2
+//                ),
+//                value: isEditing
+//            )
+//        }
+//        .enableInjection()
+//    }
+//}