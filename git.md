--- a/CloneTwitter.xcodeproj/project.pbxproj
+++ b/CloneTwitter.xcodeproj/project.pbxproj
@@ -65,6 +65,8 @@
 		B60970832D53A03E0032F4CF /* TweetService.swift in Sources */ = {isa = PBXBuildFile; fileRef = B60970822D53A03E0032F4CF /* TweetService.swift */; };
 		B60970852D54514F0032F4CF /* ProfileEndpoint.swift in Sources */ = {isa = PBXBuildFile; fileRef = B60970842D54514F0032F4CF /* ProfileEndpoint.swift */; };
 		B60970872D5451E00032F4CF /* ProfileServiceProtocol..swift in Sources */ = {isa = PBXBuildFile; fileRef = B60970862D5451E00032F4CF /* ProfileServiceProtocol..swift */; };
+		B609708A2D5644520032F4CF /* NotificationService.swift in Sources */ = {isa = PBXBuildFile; fileRef = B60970882D5644520032F4CF /* NotificationService.swift */; };
+		B609708B2D5644520032F4CF /* NotificationEndpoint.swift in Sources */ = {isa = PBXBuildFile; fileRef = B60970892D5644520032F4CF /* NotificationEndpoint.swift */; };
 		B8A02EBDEE432D9F43AE0049 /* RegisterView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 7352DB6F1062A3887691EE77 /* RegisterView.swift */; };
 		B9ABDC386C8BDBE0CBBC9CED /* FeedViewModel.swift in Sources */ = {isa = PBXBuildFile; fileRef = 21E3914C4587AB9AE684B803 /* FeedViewModel.swift */; };
 		C68B29F427476AD1D169FD1C /* CreateTweetView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 3EEAC94C4DC0E8ECCA2BC71D /* CreateTweetView.swift */; };
@@ -143,6 +145,8 @@
 		B60970822D53A03E0032F4CF /* TweetService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = TweetService.swift; sourceTree = "<group>"; };
 		B60970842D54514F0032F4CF /* ProfileEndpoint.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ProfileEndpoint.swift; sourceTree = "<group>"; };
 		B60970862D5451E00032F4CF /* ProfileServiceProtocol..swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ProfileServiceProtocol..swift; sourceTree = "<group>"; };
+		B60970882D5644520032F4CF /* NotificationService.swift */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = NotificationService.swift; sourceTree = "<group>"; };
+		B60970892D5644520032F4CF /* NotificationEndpoint.swift */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = NotificationEndpoint.swift; sourceTree = "<group>"; };
 		BBCC4AAE9275D72F7B097B96 /* AuthenticationView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AuthenticationView.swift; sourceTree = "<group>"; };
 		BCD7898679A5681A2D7F6645 /* NetworkMonitor.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = NetworkMonitor.swift; sourceTree = "<group>"; };
 		C2AECAD09846AD417141E19A /* NetworkTests.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = NetworkTests.swift; sourceTree = "<group>"; };
@@ -513,6 +517,8 @@
 		CF2DB1EF382F817FCB28EE29 /* Services */ = {
 			isa = PBXGroup;
 			children = (
+				B60970892D5644520032F4CF /* NotificationEndpoint.swift */,
+				B60970882D5644520032F4CF /* NotificationService.swift */,
 			);
 			path = Services;
 			sourceTree = "<group>";
@@ -773,12 +779,14 @@
 				740E038E9254CE9DF52E8663 /* CustomProfileTextField.swift in Sources */,
 				6FDB19B7ED93FC0A6126E7A2 /* DIContainer.swift in Sources */,
 				575D3F3D92D7F56AA224A523 /* EditProfileView.swift in Sources */,
+				B609708B2D5644520032F4CF /* NotificationEndpoint.swift in Sources */,
 				F110EC05AA0342C62CE0B4FD /* EditProfileViewModel.swift in Sources */,
 				9B2B42593BA606ED4DDA9F25 /* FeedView.swift in Sources */,
 				B9ABDC386C8BDBE0CBBC9CED /* FeedViewModel.swift in Sources */,
 				E158D8EF56E3BDE19B93E9BD /* HTTPMethod.swift in Sources */,
 				94C1C62ED3BC9451E37AD277 /* Home.swift in Sources */,
 				3A2BED0FFFAC043F2F81A466 /* ImagePicker.swift in Sources */,
+				B609708A2D5644520032F4CF /* NotificationService.swift in Sources */,
 				7584B335511A199DCC9A9819 /* ImageUploader.swift in Sources */,
 				A48CE4A74F25A49D0EA54AD2 /* KeychainStore.swift in Sources */,
 				265E6A61651B15BF73E09419 /* LoginView.swift in Sources */,
--- a/Sources/App/DIContainer.swift
+++ b/Sources/App/DIContainer.swift
@@ -51,7 +51,7 @@ final class DIContainer {
         container.register(apiClient, type: .apiClient)
         
         // 配置 AuthService
+        let authService = AuthService1(apiClient: apiClient)
         container.register(authService, type: .authService)
         
         // 配置 TweetService
@@ -62,6 +62,10 @@ final class DIContainer {
         let profileService = ProfileService(apiClient: apiClient)
         container.register(profileService, type: .profileService)
         
+        // 配置 NotificationService
+        let notificationService = NotificationService(apiClient: apiClient)
+        container.register(notificationService, type: .notificationService)
+        
         return container
     }
 }
--- a/Sources/Core/Network/Base/APIClient.swift
+++ b/Sources/Core/Network/Base/APIClient.swift
@@ -17,19 +17,20 @@ final class APIClient: APIClientProtocol {
     private let baseURL: URL
     private let session: URLSessionProtocol
     private let maxRetries: Int
+
+    init(baseURL: URL,
          session: URLSessionProtocol = URLSession.shared,
+         maxRetries: Int = 3)
+    {
         self.baseURL = baseURL
         self.session = session
         self.maxRetries = maxRetries
     }
+
     /// 发送网络请求，支持自动重试机制
     func sendRequest<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
         var attempts = 0
+
         while attempts < maxRetries {
             do {
                 return try await performRequest(endpoint)
@@ -45,90 +46,106 @@ final class APIClient: APIClientProtocol {
                 continue
             }
         }
+
         throw NetworkError.maxRetriesExceeded
     }
+
     /// 执行实际的网络请求并处理响应
     private func performRequest<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
         var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path),
+                                       resolvingAgainstBaseURL: true)
         components?.queryItems = endpoint.queryItems
+
         guard let url = components?.url else {
             throw NetworkError.invalidURL
         }
+
         var request = URLRequest(url: url)
         request.httpMethod = endpoint.method.rawValue
         request.httpBody = endpoint.body
         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
+
         endpoint.headers?.forEach { key, value in
             request.setValue(value, forHTTPHeaderField: key)
         }
+
         #if DEBUG
+            logRequest(request)
         #endif
+
         let (data, response) = try await session.data(for: request)
+
         #if DEBUG
+            logResponse(response, data: data)
         #endif
+
         guard let httpResponse = response as? HTTPURLResponse else {
             throw NetworkError.invalidResponse
         }
+
         switch httpResponse.statusCode {
+        case 200 ... 299:
             do {
                 let decoder = JSONDecoder()
                 decoder.keyDecodingStrategy = .convertFromSnakeCase
+
+                // 创建自定义的 ISO8601 格式化器，并支持毫秒
+                let isoFormatter = ISO8601DateFormatter()
+                isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
+
+                // 设置自定义日期解码策略
+                decoder.dateDecodingStrategy = .custom { decoder -> Date in
+                    let container = try decoder.singleValueContainer()
+                    let dateString = try container.decode(String.self)
+                    if let date = isoFormatter.date(from: dateString) {
+                        return date
+                    }
+                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "无法解析日期字符串: \(dateString)")
+                }
+
                 return try decoder.decode(T.self, from: data)
             } catch {
                 #if DEBUG
+                    print("解码错误: \(error)")
+                    if let json = String(data: data, encoding: .utf8) {
+                        print("原始JSON: \(json)")
+                    }
                 #endif
                 throw NetworkError.decodingError(error)
             }
         case 401:
             throw NetworkError.unauthorized
+        case 400 ... 499:
             throw NetworkError.clientError(try? decodeErrorResponse(from: data))
+        case 500 ... 599:
             throw NetworkError.serverError
         default:
             throw NetworkError.httpError(httpResponse.statusCode)
         }
     }
+
     #if DEBUG
+        private func logRequest(_ request: URLRequest) {
+            print("🚀 发送请求: \(request.httpMethod ?? "Unknown") \(request.url?.absoluteString ?? "")")
+            if let headers = request.allHTTPHeaders {
+                print("📋 Headers: \(headers)")
+            }
+            if let body = request.httpBody,
+               let json = String(data: body, encoding: .utf8)
+            {
+                print("📦 Body: \(json)")
+            }
         }
+
+        private func logResponse(_ response: URLResponse, data: Data) {
+            guard let httpResponse = response as? HTTPURLResponse else { return }
+            print("📥 收到响应: \(httpResponse.statusCode)")
+            if let json = String(data: data, encoding: .utf8) {
+                print("📄 Response: \(json)")
+            }
         }
     #endif
+
     private func decodeErrorResponse(from data: Data) throws -> APIError {
         return try JSONDecoder().decode(APIError.self, from: data)
     }
@@ -137,7 +154,7 @@ final class APIClient: APIClientProtocol {
 // 扩展 URLRequest 以方便访问所有 headers
 private extension URLRequest {
     var allHTTPHeaders: [String: String]? {
+        return allHTTPHeaderFields
     }
 }
 
--- a/Sources/Core/Network/Base/APIEndpoint.swift
+++ b/Sources/Core/Network/Base/APIEndpoint.swift
@@ -117,32 +117,47 @@ enum TweetEndpoint: APIEndpoint {
         }
     }
 
+    var headers: [String: String]? {
+        var headers: [String: String] = [:]
+        
+        if case .uploadImage = self {
+            // 修改: 使用正确的 multipart Content-Type
+            let boundary = UUID().uuidString
+            headers["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
+        } else {
+            headers["Content-Type"] = "application/json"
+        }
+        
+        if let token = UserDefaults.standard.string(forKey: "jwt") {
+            headers["Authorization"] = "Bearer \(token)"
+        }
+        
+        return headers
+    }
+    
     var body: Data? {
         switch self {
         case let .createTweet(text, userId):
             let body = ["text": text, "userId": userId]
             return try? JSONSerialization.data(withJSONObject: body)
         case let .uploadImage(_, imageData):
+            // 修改: 构造 multipart 请求体
+            let boundary = UUID().uuidString
+            var data = Data()
+            
+            // 添加图片数据
+            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
+            data.append("Content-Disposition: form-data; name=\"image\"; filename=\"tweet.jpg\"\r\n".data(using: .utf8)!)
+            data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
+            data.append(imageData)
+            data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
+            
+            return data
         default:
             return nil
         }
     }
+    
     var queryItems: [URLQueryItem]? {
         return nil
     }
--- a/Sources/Features/Feed/Services/TweetService.swift
+++ b/Sources/Features/Feed/Services/TweetService.swift
@@ -55,12 +55,26 @@ final class TweetService: TweetServiceProtocol {
     }
 
     func uploadImage(tweetId: String, image: UIImage) async throws -> ImageUploadResponse {
+        return try await withCheckedThrowingContinuation { continuation in
+            ImageUploader.uploadImage(
+                paramName: "image",
+                fileName: "tweet.jpg",
+                image: image,
+                urlPath: "/tweets/\(tweetId)/image"
+            ) { result in
+                switch result {
+                case .success(let response):
+                    if let data = try? JSONSerialization.data(withJSONObject: response),
+                       let uploadResponse = try? JSONDecoder().decode(ImageUploadResponse.self, from: data) {
+                        continuation.resume(returning: uploadResponse)
+                    } else {
+                        continuation.resume(throwing: NetworkError.decodingError(NSError(domain: "", code: -1)))
+                    }
+                case .failure(let error):
+                    continuation.resume(throwing: error)
+                }
+            }
         }
     }
 }
 
--- a/Sources/Features/Feed/ViewModels/TweetCellViewModel.swift
+++ b/Sources/Features/Feed/ViewModels/TweetCellViewModel.swift
@@ -3,24 +3,24 @@ import SwiftUI
 @MainActor
 final class TweetCellViewModel: ObservableObject {
     @Published var tweet: Tweet
     @Published var isLikeActionLoading: Bool = false
     @Published var error: Error?
     
     private let tweetService: TweetServiceProtocol
+    private let notificationService: NotificationServiceProtocol
     private let currentUserId: String
     private let onTweetUpdated: ((Tweet) -> Void)?
     
     init(
         tweet: Tweet,
         tweetService: TweetServiceProtocol,
+        notificationService: NotificationServiceProtocol,
         currentUserId: String,
         onTweetUpdated: ((Tweet) -> Void)? = nil
     ) {
         self.tweet = tweet
         self.tweetService = tweetService
+        self.notificationService = notificationService
         self.currentUserId = currentUserId
         self.onTweetUpdated = onTweetUpdated
     }
@@ -38,13 +38,12 @@ final class TweetCellViewModel: ObservableObject {
     /// 点赞操作（乐观更新）
     func likeTweet() {
         guard !isLikeActionLoading else { return }
         if isLiked {
             unlikeTweet()
             return
         }
         
+        // 乐观更新点赞状态
         if tweet.likes == nil {
             tweet.likes = [currentUserId]
         } else if !(tweet.likes!.contains(currentUserId)) {
@@ -55,13 +54,21 @@ final class TweetCellViewModel: ObservableObject {
         
         Task {
             do {
+                // 发送点赞请求
                 let updatedTweet = try await tweetService.likeTweet(tweetId: tweet.id)
                 self.tweet = updatedTweet
                 onTweetUpdated?(updatedTweet)
+                
+                // 发送通知
+                try await notificationService.createNotification(
+                    username: tweet.username,
+                    receiverId: tweet.userId,
+                    type: .like,
+                    postText: tweet.text
+                )
             } catch {
                 print("点赞失败: \(error)")
+                // 回滚点赞状态
                 if var likes = tweet.likes {
                     likes.removeAll { $0 == currentUserId }
                     tweet.likes = likes
--- a/Sources/Features/Feed/Views/FeedView.swift
+++ b/Sources/Features/Feed/Views/FeedView.swift
@@ -21,12 +21,15 @@ struct FeedView: View {
                             tweet: tweet,
                             tweetService: container.resolve(.tweetService)
                                 ?? TweetService(apiClient: APIClient(baseURL: APIConfig.baseURL)),
+                            notificationService: container.resolve(.notificationService)
+                                ?? NotificationService(apiClient: APIClient(baseURL: APIConfig.baseURL)),
                             currentUserId: authViewModel.currentUser?.id ?? "",
                             onTweetUpdated: { updatedTweet in
                                 viewModel.updateTweet(updatedTweet)
                             }
                         )
                     )
+
                     .padding(.horizontal)
                     Divider()
                 }
--- a/Sources/Features/Main/Views/Home.swift
+++ b/Sources/Features/Main/Views/Home.swift
@@ -18,16 +18,18 @@ struct HomeView: View {
                     }
                     .tag(0)
 
+                SearchView(searchText: $searchText, isEditing: $isSearching)
+             
                     .tabItem {
                         Image(systemName: "magnifyingglass")
                         Text("Search")
                     }
                     .tag(1)
                 
+                NotificationsView(
+                    user: viewModel.currentUser ?? User.mock,
+                    service: container.resolve(.notificationService) ?? NotificationService(apiClient:APIClient( baseURL: APIConfig.baseURL))
+                )
                     .tabItem {
                         Image(systemName: "bell")
                         Text("Notifications")
--- a/Sources/Features/Notifications/Models/Notification.swift
+++ b/Sources/Features/Notifications/Models/Notification.swift
@@ -1,27 +1,54 @@
 import Foundation
 
+// 通知类型枚举
+enum NotificationType: String, Codable {
     case like
     case follow
+    
+    var message: String {
         switch self {
+        case .like: return "点赞了你的推文"
+        case .follow: return "关注了你"
         }
     }
 }
+
+struct Notification: Identifiable, Codable {
+    let id: String
+    let notificationSenderId: String
+    let notificationReceiverId: String
+    let notificationType: NotificationType
+    let postText: String?
+    let createdAt: Date
+    var senderUsername: String?
+
+    enum CodingKeys: String, CodingKey {
+        case id = "_id"
+        case notificationSenderId
+        case notificationReceiverId
+        case notificationType
+        case postText
+        case createdAt
+    }
+    
+    // 定义内部用于解析发送者信息的 key
+    enum SenderKeys: String, CodingKey {
+        case id = "_id"
+        case username
+    }
+    
+    init(from decoder: Decoder) throws {
+        let container = try decoder.container(keyedBy: CodingKeys.self)
+        id = try container.decode(String.self, forKey: .id)
+        
+        // 对 notificationSenderId 字段进行嵌套解码
+        let senderContainer = try container.nestedContainer(keyedBy: SenderKeys.self, forKey: .notificationSenderId)
+        notificationSenderId = try senderContainer.decode(String.self, forKey: .id)
+        senderUsername = try senderContainer.decode(String.self, forKey: .username)
+        
+        notificationReceiverId = try container.decode(String.self, forKey: .notificationReceiverId)
+        notificationType = try container.decode(NotificationType.self, forKey: .notificationType)
+        postText = try container.decodeIfPresent(String.self, forKey: .postText)
+        createdAt = try container.decode(Date.self, forKey: .createdAt)
+    }
+}
\ No newline at end of file
--- a/Sources/Features/Notifications/ViewModels/NotificationsViewModel.swift
+++ b/Sources/Features/Notifications/ViewModels/NotificationsViewModel.swift
@@ -1,75 +1,67 @@
+import Foundation
 
+@MainActor
+final class NotificationsViewModel: ObservableObject {
+    // 发布数据和状态
+    @Published private(set) var notifications: [Notification] = []
+    @Published private(set) var isLoading = false
+    @Published private(set) var error: Error?
+
+    // 依赖注入
+    private let service: NotificationServiceProtocol
+    private let user: User
+    // 标志，防止重复加载
+    private var didFetch = false
+
+    init(user: User, service: NotificationServiceProtocol) {
         self.user = user
+        self.service = service
     }
 
+    /// 获取通知列表（首次加载时调用）
+    func fetchNotifications() async {
+        // 若正在加载或已经加载过则直接返回
+        guard !isLoading, !didFetch else { return }
+        isLoading = true
+        error = nil
+        do {
+            notifications = try await service.fetchNotifications(userId: user.id)
+            didFetch = true
+        } catch {
+            self.error = error
+            print("Failed to fetch notifications: \(error)")
         }
+        isLoading = false
+    }
+    
+    /// 刷新通知列表（下拉刷新时调用）
+    func refreshNotifications() async {
+        // 清除标志后重新加载数据
+        didFetch = false
+        await fetchNotifications()
+    }
+    
+    /// 创建新通知
+    func createNotification(receiverId: String, type: NotificationType, postText: String? = nil) {
+        Task {
             do {
+                let newNotification = try await service.createNotification(
+                    username: user.username,
+                    receiverId: receiverId,
+                    type: type,
+                    postText: postText
+                )
+                // 新通知插入列表最前面
+                notifications.insert(newNotification, at: 0)
             } catch {
+                self.error = error
+                print("Failed to create notification: \(error)")
             }
         }
     }
+    
+    /// 清除错误状态
+    func clearError() {
+        error = nil
+    }
+}
\ No newline at end of file
--- a/Sources/Features/Notifications/Views/NotificationCell.swift
+++ b/Sources/Features/Notifications/Views/NotificationCell.swift
@@ -23,20 +23,18 @@ struct NotificationCell: View {
                     .frame(width: 20, height: 20)
                 
                 VStack(alignment: .leading, spacing: 5, content: {
+                    KFImage(URL(string: "http://localhost:3000/users/\(notification.notificationSenderId)/avatar"))
                         .resizable()
                         .scaledToFit()
                         .frame(width: 36, height: 36)
                         .cornerRadius(18)
                     
                     
+                    Text(notification.senderUsername ?? "")
                         .fontWeight(.bold)
                         .foregroundColor(.primary)
+                    + Text(" ")
+                    + Text(notification.notificationType.message)
                         .foregroundColor(.black)
                     
                 })
--- a/Sources/Features/Notifications/Views/NotificationsView.swift
+++ b/Sources/Features/Notifications/Views/NotificationsView.swift
@@ -1,72 +1,69 @@
 import SwiftUI
 
 struct NotificationsView: View {
+    @StateObject private var viewModel: NotificationsViewModel
+
+    init(user: User, service: NotificationServiceProtocol) {
+        _viewModel = StateObject(wrappedValue: NotificationsViewModel(user: user, service: service))
     }
+
     var body: some View {
+        ZStack {
+            // 如果没有加载过数据，并且正在加载时显示 ProgressView，否则显示内容
+            if viewModel.isLoading && viewModel.notifications.isEmpty {
+                ProgressView()
             } else {
+                content
+            }
+        }
+        // 使用动态绑定控制 Alert 的显示
+        .alert("错误", isPresented: Binding(
+            get: { viewModel.error != nil },
+            set: { _ in viewModel.clearError() }
+        )) {
+            Button("确定") {
+                viewModel.clearError()
+            }
+        } message: {
+            if let error = viewModel.error {
+                Text(error.localizedDescription)
+            }
+        }
+        // 视图首次出现时加载通知
+        .task {
+            await viewModel.fetchNotifications()
+        }
+    }
+
+    private var content: some View {
+        ScrollView {
+            LazyVStack(spacing: 0) {
+                if viewModel.notifications.isEmpty {
+                    emptyView
+                } else {
+                    ForEach(viewModel.notifications) { notification in
+                        NotificationCell(notification: notification)
+                        Divider()
                     }
                 }
             }
         }
+        // 下拉刷新时重新加载数据
+        .refreshable {
+            await viewModel.refreshNotifications()
+        }
+    }
+
+    private var emptyView: some View {
+        VStack(spacing: 12) {
+            Text("暂无通知")
+                .font(.title3)
+                .fontWeight(.semibold)
+            Text("新的通知将会显示在这里")
+                .font(.subheadline)
+                .foregroundColor(.gray)
         }
+        .frame(maxWidth: .infinity, maxHeight: .infinity)
+        .padding(.vertical, 32)
     }
+}
\ No newline at end of file
--- a/Sources/Features/Profile/Views/ProfileView.swift
+++ b/Sources/Features/Profile/Views/ProfileView.swift
@@ -372,8 +372,9 @@ struct TweetListView: View {
                 TweetCellView(
                     viewModel: TweetCellViewModel(
                         tweet: tweet,
+                        tweetService: container.resolve(.tweetService) ?? TweetService(apiClient: APIClient(baseURL: APIConfig.baseURL)),   notificationService:container.resolve(.notificationService) ?? NotificationService(apiClient:APIClient( baseURL: APIConfig.baseURL)), currentUserId: authViewModel.currentUser?.id ?? ""
                     )
+                 
                 )
                 Divider()
             }
--- a/Sources/Features/Search/Views/SearchView.swift
+++ b/Sources/Features/Search/Views/SearchView.swift
@@ -1,46 +1,46 @@
+import Kingfisher
+import SwiftUI
+
+struct SearchView: View {
+    @EnvironmentObject private var authViewModel: AuthState
+    @ObservedObject var viewModel = SearchViewModel()
+    @ObserveInjection var inject
+  @Environment(\.diContainer) private var container
+    // 从 TopBar 传入的搜索状态
+    @Binding var searchText: String
+    @Binding var isEditing: Bool
+    
+    var users: [User] {
+        return searchText.isEmpty ? viewModel.users : viewModel.filteredUsers(searchText)
+    }
+
+    var body: some View {
+        ScrollView {
+            VStack {
+                LazyVStack {
+                    ForEach(users) { user in
+                      NavigationLink(destination: ProfileView(userId: user.id, diContainer: container)) {
+                            SearchUserCell(user: user)
+                                .padding(.leading)
+                        }
+                    }
+                }
+                .transition(
+                    .asymmetric(
+                        insertion: .move(edge: .trailing).combined(with: .opacity),
+                        removal: .move(edge: .leading).combined(with: .opacity)
+                    )
+                )
+            }
+            .animation(
+                .spring(
+                    response: 0.4,
+                    dampingFraction: 0.7,
+                    blendDuration: 0.2
+                ),
+                value: isEditing
+            )
+        }
+        .enableInjection()
+    }
+}

--- a/git.md
+++ b/git.md
@@ -1,1016 +0,0 @@
\ No newline at end of file