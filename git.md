--- a/CloneTwitter.xcodeproj/project.pbxproj
+++ b/CloneTwitter.xcodeproj/project.pbxproj
@@ -16,7 +16,6 @@
 		1D21FAB63AFC5E606C0C2A64 /* TweetCellView.swift in Sources */ = {isa = PBXBuildFile; fileRef = D1C453EC586A0665020D9A19 /* TweetCellView.swift */; };
 		224047DD3EE85ECD6AF106D5 /* File.xml in Resources */ = {isa = PBXBuildFile; fileRef = 054016E8D66F1B4C82E6B5D0 /* File.xml */; };
 		265E6A61651B15BF73E09419 /* LoginView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 16A96C0572F431B61D819EFF /* LoginView.swift */; };
 		39E5589799AE479A0961C12E /* WelcomeView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 971F650FD73A2B597D238C61 /* WelcomeView.swift */; };
 		3A2BED0FFFAC043F2F81A466 /* ImagePicker.swift in Sources */ = {isa = PBXBuildFile; fileRef = A4F78A7A3E204C9B5D7EC5F7 /* ImagePicker.swift */; };
 		4F41E88C3D8A52450B608CB9 /* Resources.swift in Sources */ = {isa = PBXBuildFile; fileRef = AE40C32AC8123DD59F172FB7 /* Resources.swift */; };
@@ -44,7 +43,6 @@
 		8E0A851518B6898ECB034D49 /* User.swift in Sources */ = {isa = PBXBuildFile; fileRef = 5CFC4E1CF5604E79DFA6473C /* User.swift */; };
 		91C978992D2A6102D9E58DD0 /* MultilineTextField.swift in Sources */ = {isa = PBXBuildFile; fileRef = A2B85D4169C23AC0BD82EAF8 /* MultilineTextField.swift */; };
 		94C1C62ED3BC9451E37AD277 /* Home.swift in Sources */ = {isa = PBXBuildFile; fileRef = E340CE3CF26FFEAB4FAEA1EF /* Home.swift */; };
 		9800B848E68D814BFCE8CA57 /* Media.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = DC7A55A39F786A0824ED647E /* Media.xcassets */; };
 		9B2B42593BA606ED4DDA9F25 /* FeedView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 948E51776C95105DFE7544F7 /* FeedView.swift */; };
 		A3255C675D0B3559EDD12415 /* AuthViewModel.swift in Sources */ = {isa = PBXBuildFile; fileRef = 61B39B8D904517C1C32AF91D /* AuthViewModel.swift */; };
@@ -108,9 +106,7 @@
 		361F150618D0D0F322A15E6E /* SearchViewModel.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SearchViewModel.swift; sourceTree = "<group>"; };
 		3EEAC94C4DC0E8ECCA2BC71D /* CreateTweetView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = CreateTweetView.swift; sourceTree = "<group>"; };
 		4213E06F3CCA243298091A66 /* KeychainStore.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = KeychainStore.swift; sourceTree = "<group>"; };
 		47D29BEB8668FC73D22D28DB /* NotificationCell.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = NotificationCell.swift; sourceTree = "<group>"; };
 		5CFC4E1CF5604E79DFA6473C /* User.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = User.swift; sourceTree = "<group>"; };
 		61B39B8D904517C1C32AF91D /* AuthViewModel.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AuthViewModel.swift; sourceTree = "<group>"; };
 		63FDE8CB94466263E5586230 /* NotificationsViewModel.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = NotificationsViewModel.swift; sourceTree = "<group>"; };
@@ -634,9 +630,7 @@
 		F2784F704F709C590F1DDC80 /* Legacy */ = {
 			isa = PBXGroup;
 			children = (
 				ECC92E6AFC831E4B3659BBE5 /* ImageUploader.swift */,
 			);
 			path = Legacy;
 			sourceTree = "<group>";
@@ -765,7 +759,6 @@
 				D083743D5A289AE1EA1CC99F /* APIClient.swift in Sources */,
 				0DC7DDE2F6AD950C536C467C /* APIConfig.swift in Sources */,
 				F5BD618014CAF831D47E4432 /* APIEndpoint.swift in Sources */,
 				A3255C675D0B3559EDD12415 /* AuthViewModel.swift in Sources */,
 				021CA03EDFAA691B6EB4CDB2 /* AuthenticationView.swift in Sources */,
 				7C55E95293106EE806379032 /* BlurView.swift in Sources */,
@@ -804,7 +797,6 @@
 				5984A8CEE38ACEBBB22DF543 /* ProfileViewModel.swift in Sources */,
 				B8A02EBDEE432D9F43AE0049 /* RegisterView.swift in Sources */,
 				B609707D2D5385890032F4CF /* AuthState.swift in Sources */,
 				4F41E88C3D8A52450B608CB9 /* Resources.swift in Sources */,
 				015135E631653147116C5BF2 /* SearchBar.swift in Sources */,
 				06911A9577ACF6B3FC13CBBA /* SearchCell.swift in Sources */,
--- a/Sources/Core/Legacy/AuthService.swift
+++ b//dev/null
@@ -1,316 +0,0 @@
--- a/Sources/Core/Legacy/ImageUploader.swift
+++ b/Sources/Core/Legacy/ImageUploader.swift
@@ -1,7 +1,7 @@
 import SwiftUI
 
 enum ImageUploader {
+    /// 上传图片的静态方法
     static func uploadImage(
         paramName: String,
         fileName: String,
@@ -11,36 +11,38 @@ enum ImageUploader {
     ) {
         // 1. 构建完整URL
         guard let url = URL(string: "http://localhost:3000\(urlPath)") else { return }
+        
+        // 2. 生成 boundary
         let boundary = UUID().uuidString
+        
         // 3. 创建请求
         var request = URLRequest(url: url)
         request.httpMethod = "POST"
+        
+        // 4. 设置请求头（注意替换 token 获取方式）
         guard let token = UserDefaults.standard.string(forKey: "jwt") else { return }
         request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
         request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
+        
+        // 5. 构建 multipart 表单数据
         var data = Data()
+        data.append("--\(boundary)\r\n".data(using: .utf8)!)
         data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
         data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
+        if let imageData = image.jpegData(compressionQuality: 0.5) {
+            data.append(imageData)
+        }
         data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
+        
         // 6. 创建上传任务
         let task = URLSession.shared.uploadTask(with: request, from: data) { data, _, error in
             if let error = error {
                 completion(.failure(error))
                 return
             }
+            
             guard let data = data else { return }
+            
             do {
                 if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                     completion(.success(json))
@@ -49,8 +51,8 @@ enum ImageUploader {
                 completion(.failure(error))
             }
         }
+        
         // 7. 开始上传
         task.resume()
     }
+}
\ No newline at end of file
--- a/Sources/Core/Legacy/RequestServices.swift
+++ b//dev/null
@@ -1,403 +0,0 @@
--- a/Sources/Core/Network/Base/APIClient.swift
+++ b/Sources/Core/Network/Base/APIClient.swift
@@ -10,6 +10,7 @@ extension URLSession: URLSessionProtocol {}
 /// API客户端协议
 protocol APIClientProtocol {
     func sendRequest<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
+    func sendRequestWithoutDecoding(_ endpoint: APIEndpoint) async throws
 }
 
 /// API客户端实现，处理所有网络请求
@@ -63,6 +64,8 @@ final class APIClient: APIClientProtocol {
         var request = URLRequest(url: url)
         request.httpMethod = endpoint.method.rawValue
         request.httpBody = endpoint.body
+        // 添加：避免使用缓存
+        request.cachePolicy = .reloadIgnoringLocalCacheData
         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
 
         endpoint.headers?.forEach { key, value in
@@ -124,6 +127,66 @@ final class APIClient: APIClientProtocol {
         }
     }
 
+  /// 新增方法：发送请求但不对响应内容进行解码，用于图片上传等返回数据格式不确定的接口
+   func sendRequestWithoutDecoding(_ endpoint: APIEndpoint) async throws {
+       var attempts = 0
+
+       while attempts < maxRetries {
+           do {
+               try await performRequestWithoutDecoding(endpoint)
+               return
+           } catch NetworkError.serverError {
+               attempts += 1
+               if attempts == maxRetries {
+                   throw NetworkError.maxRetriesExceeded
+               }
+               try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempts))) * 1_000_000_000)
+           }
+       }
+
+       throw NetworkError.maxRetriesExceeded
+   }
+
+   /// 执行实际网络请求但不进行数据解码
+   private func performRequestWithoutDecoding(_ endpoint: APIEndpoint) async throws {
+       var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path),
+                                      resolvingAgainstBaseURL: true)
+       components?.queryItems = endpoint.queryItems
+
+       guard let url = components?.url else {
+           throw NetworkError.invalidURL
+       }
+
+       var request = URLRequest(url: url)
+       request.httpMethod = endpoint.method.rawValue
+       request.httpBody = endpoint.body
+       request.cachePolicy = .reloadIgnoringLocalCacheData
+        
+        endpoint.headers?.forEach { key, value in
+            request.setValue(value, forHTTPHeaderField: key)
+        }
+
+        let (data, response) = try await session.data(for: request)
+        
+        guard let httpResponse = response as? HTTPURLResponse else {
+            throw NetworkError.invalidResponse
+        }
+        
+        switch httpResponse.statusCode {
+        case 200...299:
+            return  // 成功，不解析返回数据
+        case 401:
+            throw NetworkError.unauthorized
+        case 400...499:
+            throw NetworkError.clientError(try? decodeErrorResponse(from: data))
+        case 500...599:
+            throw NetworkError.serverError
+        default:
+            throw NetworkError.httpError(httpResponse.statusCode)
+        }
+   }
+  
+  
     #if DEBUG
         private func logRequest(_ request: URLRequest) {
             print("🚀 发送请求: \(request.httpMethod ?? "Unknown") \(request.url?.absoluteString ?? "")")
--- a/Sources/Features/Auth/ViewModels/AuthState.swift
+++ b/Sources/Features/Auth/ViewModels/AuthState.swift
@@ -7,18 +7,30 @@
 
 import Foundation
 import SwiftUI
+import Combine
 
 @MainActor
 final class AuthState: ObservableObject {
     private let authService: AuthServiceProtocol
     @Published var currentUser: User?
     @Published var isAuthenticated = false
     @Published var isLoading = false
     @Published var error: String?
     
+    private var cancellables = Set<AnyCancellable>()
+    
     init(authService: AuthServiceProtocol) {
         self.authService = authService
+        
+        // 订阅更新用户的通知
+        NotificationCenter.default.publisher(for: .didUpdateProfile)
+            .compactMap { $0.object as? User }
+            .sink { [weak self] updatedUser in
+                print("AuthState 收到更新通知，更新 currentUser")
+                self?.currentUser = updatedUser
+            }
+            .store(in: &cancellables)
+        
         Task {
             await checkAuthStatus()
         }
@@ -28,7 +40,7 @@ final class AuthState: ObservableObject {
     
     func login(email: String, password: String) async {
         await performAction {
+            let response = try await self.authService.login(email: email, password: password)
             self.currentUser = response.user
             self.isAuthenticated = true
         }
@@ -36,7 +48,7 @@ final class AuthState: ObservableObject {
     
     func register(email: String, username: String, password: String, name: String) async {
         await performAction {
+            let user = try await self.authService.register(
                 email: email,
                 username: username,
                 password: password,
@@ -55,8 +67,9 @@ final class AuthState: ObservableObject {
     
     func updateProfile(data: [String: Any]) async {
         await performAction {
+            let updatedUser = try await self.authService.updateProfile(data: data)
             self.currentUser = updatedUser
+            // 此处也可以发布通知，不过后续 ProfileViewModel 会发布，这里只更新全局状态
         }
     }
     
@@ -69,7 +82,7 @@ final class AuthState: ObservableObject {
         }
         
         await performAction {
+            let user = try await self.authService.fetchCurrentUser()
             self.currentUser = user
             self.isAuthenticated = true
         }
--- a/Sources/Features/Feed/ViewModels/TweetCellViewModel.swift
+++ b/Sources/Features/Feed/ViewModels/TweetCellViewModel.swift
@@ -25,12 +25,12 @@ final class TweetCellViewModel: ObservableObject {
         self.onTweetUpdated = onTweetUpdated
     }
     
+    /// 判断当前用户是否已点赞
     var isLiked: Bool {
         tweet.likes?.contains(currentUserId) ?? false
     }
     
+    /// 点赞数量
     var likesCount: Int {
         tweet.likes?.count ?? 0
     }
@@ -43,7 +43,7 @@ final class TweetCellViewModel: ObservableObject {
             return
         }
         
+        // 乐观更新：先在本地添加当前用户
         if tweet.likes == nil {
             tweet.likes = [currentUserId]
         } else if !(tweet.likes!.contains(currentUserId)) {
@@ -54,12 +54,10 @@ final class TweetCellViewModel: ObservableObject {
         
         Task {
             do {
                 let updatedTweet = try await tweetService.likeTweet(tweetId: tweet.id)
                 self.tweet = updatedTweet
                 onTweetUpdated?(updatedTweet)
+                // 同时发送通知（如需要）
                 try await notificationService.createNotification(
                     username: tweet.username,
                     receiverId: tweet.userId,
@@ -67,8 +65,7 @@ final class TweetCellViewModel: ObservableObject {
                     postText: tweet.text
                 )
             } catch {
+                // 回滚本地状态
                 if var likes = tweet.likes {
                     likes.removeAll { $0 == currentUserId }
                     tweet.likes = likes
@@ -82,13 +79,10 @@ final class TweetCellViewModel: ObservableObject {
     /// 取消点赞操作（乐观更新）
     func unlikeTweet() {
         guard !isLikeActionLoading else { return }
         if var likes = tweet.likes {
             likes.removeAll { $0 == currentUserId }
             tweet.likes = likes
         }
         isLikeActionLoading = true
         
         Task {
@@ -97,8 +91,7 @@ final class TweetCellViewModel: ObservableObject {
                 self.tweet = updatedTweet
                 onTweetUpdated?(updatedTweet)
             } catch {
+                // 回滚：将当前用户重新加回去
                 if tweet.likes == nil {
                     tweet.likes = [currentUserId]
                 } else if !(tweet.likes!.contains(currentUserId)) {
@@ -110,8 +103,14 @@ final class TweetCellViewModel: ObservableObject {
         }
     }
     
+    /// 根据传入的全局 AuthState 生成头像 URL（带时间戳以避免缓存问题）
+    func getUserAvatarURL(from authState: AuthState) -> URL? {
+        // 如果当前 tweet 用户与全局 currentUser 相同，则附加时间戳
+        if authState.currentUser?.id == tweet.userId {
+            let timestamp = Int(Date().timeIntervalSince1970)
+            return URL(string: "http://localhost:3000/users/\(tweet.userId)/avatar?t=\(timestamp)")
+        } else {
+            return URL(string: "http://localhost:3000/users/\(tweet.userId)/avatar")
+        }
     }
+}
\ No newline at end of file
--- a/Sources/Features/Feed/Views/TweetCellView.swift
+++ b/Sources/Features/Feed/Views/TweetCellView.swift
@@ -5,7 +5,8 @@ struct TweetCellView: View {
     @ObserveInjection var inject
     @ObservedObject var viewModel: TweetCellViewModel
     @Environment(\.diContainer) private var container
+    @EnvironmentObject var authState: AuthState  // 直接获取全局 AuthState
+    
     var body: some View {
         VStack(alignment: .leading, spacing: 12) {
             // 如果点赞数大于 0，则显示点赞数
@@ -19,7 +20,7 @@ struct TweetCellView: View {
                 }
                 .padding(.trailing, 16)
             }
+            
             HStack(alignment: .top, spacing: 12) {
                 // 头像区域：点击跳转到对应用户的个人主页
                 NavigationLink {
@@ -27,7 +28,7 @@ struct TweetCellView: View {
                 } label: {
                     avatarView
                 }
+                
                 // 推文内容区域
                 VStack(alignment: .leading, spacing: 4) {
                     // 用户信息
@@ -38,18 +39,17 @@ struct TweetCellView: View {
                             .foregroundColor(.gray)
                         Text("·")
                             .foregroundColor(.gray)
                         Text("11h")
                             .foregroundColor(.gray)
                     }
                     .font(.system(size: 16))
+                    
                     // 推文文本
                     Text(viewModel.tweet.text)
                         .font(.system(size: 16))
                         .frame(maxHeight: 100)
                         .lineSpacing(4)
+                    
                     // 推文图片（如果存在）
                     if viewModel.tweet.image == true {
                         GeometryReader { proxy in
@@ -62,12 +62,12 @@ struct TweetCellView: View {
                         .frame(height: 200)
                         .zIndex(0)
                     }
+                    
                     // 互动按钮区域
                     HStack(spacing: 40) {
                         InteractionButton(image: "message", count: 0)
                         InteractionButton(image: "arrow.2.squarepath", count: 0)
+                        
                         Button(action: {
                             if viewModel.isLiked {
                                 viewModel.unlikeTweet()
@@ -88,7 +88,7 @@ struct TweetCellView: View {
                         .zIndex(1)
                         .padding(8)
                         .contentShape(Rectangle())
+                        
                         InteractionButton(image: "square.and.arrow.up", count: nil)
                     }
                     .padding(.top, 8)
@@ -101,10 +101,10 @@ struct TweetCellView: View {
         .contentShape(Rectangle())
         .enableInjection()
     }
+    
+    // 使用全局 AuthState 重新计算头像 URL
     private var avatarView: some View {
+        KFImage(getAvatarURL())
             .placeholder {
                 Circle()
                     .fill(Color.gray)
@@ -114,6 +114,17 @@ struct TweetCellView: View {
             .scaledToFill()
             .frame(width: 44, height: 44)
             .clipShape(Circle())
+            .onAppear {
+                // 可选：在 onAppear 清除缓存，确保加载最新图片
+                if let url = getAvatarURL() {
+                    KingfisherManager.shared.cache.removeImage(forKey: url.absoluteString)
+                }
+            }
+    }
+    
+    private func getAvatarURL() -> URL? {
+        // 调用 TweetCellViewModel 中的方法，传入全局 authState
+        return viewModel.getUserAvatarURL(from: authState)
     }
 }
 
@@ -122,7 +133,7 @@ struct TweetCellView: View {
 private struct InteractionButton: View {
     let image: String
     let count: Int?
+    
     var body: some View {
         HStack(spacing: 4) {
             Image(systemName: image)
@@ -134,4 +145,4 @@ private struct InteractionButton: View {
             }
         }
     }
+}
\ No newline at end of file
--- a/Sources/Features/Main/Views/SlideMenu.swift
+++ b/Sources/Features/Main/Views/SlideMenu.swift
@@ -2,147 +2,153 @@ import Kingfisher
 import SwiftUI
 
 struct SlideMenu: View {
+    @EnvironmentObject private var authViewModel: AuthState // 注入 AuthState
+    @State private var showSettings = false // 添加这一行
 
+    // 修改 onProfileTap，接收 String 参数
     var onProfileTap: (String) -> Void
+    @State private var isExpanded = false
+    @ObserveInjection var inject
+  private var avatarURL: URL? {
+      guard let user = authViewModel.currentUser else { return nil }
+      // 这里直接使用当前时间戳，保证 URL 每次都不同（注意：如果担心每次重绘都刷新可考虑只在用户更新时刷新）
+      let timestamp = Int(Date().timeIntervalSince1970)
+      return URL(string: "http://localhost:3000/users/\(user.id)/avatar?t=\(timestamp)")
+  }
 
+    var body: some View {
+        VStack(alignment: .leading) {
+            // 顶部用户信息区域
+            HStack(alignment: .top, spacing: 0) {
+                VStack(alignment: .leading, spacing: 0) {
+                    Button {
+                        // 当点击头像时，如果当前用户存在，则将 user.id 传给 onProfileTap 回调
                         if let userId = authViewModel.currentUser?.id {
                             onProfileTap(userId)
                         }
+                    } label: {
+                        HStack {
+                            KFImage(avatarURL)
+                                .placeholder {
+                                    Circle()
+                                        .fill(.gray)
+                                        .frame(width: 44, height: 44)
+                                }
+                                .resizable()
+                                .scaledToFill()
+                                .frame(width: 44, height: 44)
+                                .clipShape(Circle())
+                                .onAppear {
+                                    // 清除特定 URL 的缓存
+                                    if let url = avatarURL {
+                                        KingfisherManager.shared.cache.removeImage(forKey: url.absoluteString)
+                                    }
+                                }
+                                .padding(.bottom, 12)
 
+                            VStack(alignment: .leading, spacing: 0) {
+                                Text(authViewModel.currentUser?.name ?? "")
+                                    .font(.system(size: 14))
+                                    .padding(.bottom, 4)
+                                Text("@\(authViewModel.currentUser?.username ?? "")")
+                                    .font(.system(size: 12))
+                                    .bold()
+                                    .foregroundColor(.gray)
+                            }
+                        }
+                    }
+                    .contentShape(Rectangle())
+                }
+                Spacer()
+
+                Button(action: {
+                    isExpanded.toggle()
+                }) {
+                    Image(systemName: "chevron.down")
+                        .font(.system(size: 16))
+                }
+                .padding(.top, 12)
+            }
 
+            // 关注信息区域
+            HStack(spacing: 0) {
+                //    Text("\(authViewModel.user!.following.count) ")
+                Text("324")
+                    .font(.system(size: 14))
+                    .bold()
+                Text("Following")
+                    .foregroundStyle(.gray)
+                    .font(.system(size: 14))
+                    .bold()
+                    .padding(.trailing, 8)
+                //    Text("\(authViewModel.user!.followers.count) ")
+                Text("253")
+                    .font(.system(size: 14))
+                    .bold()
+                Text("Followers")
+                    .font(.system(size: 14))
+                    .foregroundStyle(.gray)
+                    .bold()
+            }
 
+            .padding(.top, 4)
 
+            // 主菜单列表区域
+            VStack(alignment: .leading, spacing: 0) {
+                ForEach([
+                    ("person", "Profile"),
+                    ("list.bullet", "Lists"),
+                    ("number", "Topics"),
+                    ("bookmark", "Bookmarks"),
+                    ("sparkles", "Moments"),
+                ], id: \.1) { icon, text in
+                    HStack {
+                        Image(systemName: icon)
+                            .font(.system(size: 20))
+                            .padding(16)
+                            .padding(.leading, -16)
 
+                        Text(text)
+                            .font(.system(size: 18))
+                            .bold()
+                    }
+                }
+            }
+            .padding(.vertical, 12)
 
+            Divider()
+                .padding(.bottom, 12 + 16)
 
+            // 底部区域
+            VStack(alignment: .leading, spacing: 12) {
+                Button {
+                    showSettings = true
+                } label: {
+                    Text("Settings and privacy")
+                        .font(.system(size: 14))
+                        .bold()
+                }
 
+                Text("Help Center")
+                    .font(.system(size: 14))
+                    .foregroundStyle(.gray)
 
+                HStack {
+                    Image(systemName: "lightbulb")
+                    Spacer()
+                    Image(systemName: "qrcode")
+                }
+                .font(.title3)
+                .padding(.vertical, 12)
+                .bold()
+            }
+        }
+        .sheet(isPresented: $showSettings) {
+            SettingsView()
+        }
+        .padding(.top, 12)
+        .padding(.horizontal, 24)
+        .frame(maxHeight: .infinity, alignment: .top)
+        .enableInjection()
+    }
 }
--- a/Sources/Features/Notifications/ViewModels/NotificationsViewModel.swift
+++ b/Sources/Features/Notifications/ViewModels/NotificationsViewModel.swift
@@ -6,38 +6,39 @@ final class NotificationsViewModel: ObservableObject {
     @Published private(set) var notifications: [Notification] = []
     @Published private(set) var isLoading = false
     @Published private(set) var error: Error?
+    
     // 依赖注入
     private let service: NotificationServiceProtocol
     private let user: User
 
     init(user: User, service: NotificationServiceProtocol) {
         self.user = user
         self.service = service
     }
+    
+    /// 获取通知列表，每次调用都会重新加载数据
     func fetchNotifications() async {
+        // 如果正在加载，则直接返回，防止并发调用
+        guard !isLoading else { return }
         isLoading = true
         error = nil
         do {
+            let newNotifications = try await service.fetchNotifications(userId: user.id)
+            notifications = newNotifications
         } catch {
+            // 如果错误是任务取消，则忽略错误，不赋值 error
+            if error is CancellationError {
+                print("Fetch notifications cancelled. Ignoring cancellation error.")
+            } else {
+                self.error = error
+                print("Failed to fetch notifications: \(error)")
+            }
         }
         isLoading = false
     }
     
+    /// 刷新通知列表，直接调用 fetchNotifications()
     func refreshNotifications() async {
         await fetchNotifications()
     }
     
@@ -54,8 +55,12 @@ final class NotificationsViewModel: ObservableObject {
                 // 新通知插入列表最前面
                 notifications.insert(newNotification, at: 0)
             } catch {
+                if error is CancellationError {
+                    print("Create notification cancelled. Ignoring cancellation error.")
+                } else {
+                    self.error = error
+                    print("Failed to create notification: \(error)")
+                }
             }
         }
     }
--- a/Sources/Features/Notifications/Views/NotificationsView.swift
+++ b/Sources/Features/Notifications/Views/NotificationsView.swift
@@ -9,30 +9,38 @@ struct NotificationsView: View {
 
     var body: some View {
         ZStack {
+            // 如果数据正在加载且列表为空，则显示加载指示器，否则显示内容
             if viewModel.isLoading && viewModel.notifications.isEmpty {
                 ProgressView()
             } else {
                 content
             }
         }
+//        // 通过 Alert 显示错误信息
+//        .alert("错误", isPresented: Binding(
+//            get: { viewModel.error != nil },
+//            set: { _ in viewModel.clearError() }
+//        )) {
+//            Button("确定") {
+//                viewModel.clearError()
+//            }
+//        } message: {
+//            if let error = viewModel.error {
+//                Text(error.localizedDescription)
+//            }
+//        }
+        // 视图首次加载时调用一次
         .task {
             await viewModel.fetchNotifications()
         }
+        // 每隔 5 秒自动刷新一次（避免多次并发刷新）
+        .onReceive(Timer.publish(every: 5, on: .main, in: .common).autoconnect()) { _ in
+            if !viewModel.isLoading {
+                Task {
+                    await viewModel.fetchNotifications()
+                }
+            }
+        }
     }
 
     private var content: some View {
@@ -48,7 +56,7 @@ struct NotificationsView: View {
                 }
             }
         }
+        // 下拉刷新时调用 refreshNotifications()
         .refreshable {
             await viewModel.refreshNotifications()
         }
@@ -66,4 +74,4 @@ struct NotificationsView: View {
         .frame(maxWidth: .infinity, maxHeight: .infinity)
         .padding(.vertical, 32)
     }
\ No newline at end of file
+}
--- a/Sources/Features/Profile/Services/ProfileServiceProtocol..swift
+++ b/Sources/Features/Profile/Services/ProfileServiceProtocol..swift
@@ -16,6 +16,7 @@ protocol ProfileServiceProtocol {
     func fetchUserTweets(userId: String) async throws -> [Tweet]
     func uploadAvatar(imageData: Data) async throws -> User
     func uploadBanner(imageData: Data) async throws -> User
+  
 }
 
 final class ProfileService: ProfileServiceProtocol {
@@ -40,14 +41,20 @@ final class ProfileService: ProfileServiceProtocol {
         return try await apiClient.sendRequest(endpoint)
     }
     
+    /// 修改后的上传头像逻辑  
+    /// 第一步调用 sendRequestWithoutDecoding 上传图片（不解码响应），
+    /// 第二步调用 fetchUserProfile 获取更新后的用户数据
     func uploadAvatar(imageData: Data) async throws -> User {
+        let uploadEndpoint = ProfileEndpoint.uploadAvatar(imageData: imageData)
+        try await apiClient.sendRequestWithoutDecoding(uploadEndpoint)
+        // 上传成功后获取最新用户数据
+        return try await fetchUserProfile(userId: "me")
     }
+
     func uploadBanner(imageData: Data) async throws -> User {
+        let uploadEndpoint = ProfileEndpoint.uploadBanner(imageData: imageData)
+        try await apiClient.sendRequestWithoutDecoding(uploadEndpoint)
+        return try await fetchUserProfile(userId: "me")
     }
 }
 
--- a/Sources/Features/Profile/ViewModels/ProfileViewModel.swift
+++ b/Sources/Features/Profile/ViewModels/ProfileViewModel.swift
@@ -1,20 +1,25 @@
 import SwiftUI
 import Foundation
+import Kingfisher
+
+// Fix notification name definition
+extension NSNotification.Name {
+    static let didUpdateProfile = NSNotification.Name("didUpdateProfile")
+}
 
 @MainActor
 final class ProfileViewModel: ObservableObject {
     private let profileService: ProfileServiceProtocol
+    private let userId: String?
     
     @Published var user: User?
     @Published var tweets: [Tweet] = []
     @Published var isLoading = false
+    @Published var errorMessage: String?
     @Published var shouldRefreshImage = false
     
+    private(set) var lastImageRefreshTime: TimeInterval = Date().timeIntervalSince1970
     
     var isCurrentUser: Bool {
         guard let profileUserId = user?.id else { return false }
         return userId == nil || userId == profileUserId
@@ -35,21 +40,12 @@ final class ProfileViewModel: ObservableObject {
         defer { isLoading = false }
         
         do {
+            let targetUserId = userId ?? self.user?.id ?? "me"
+            async let profile = profileService.fetchUserProfile(userId: targetUserId)
+            async let userTweets = profileService.fetchUserTweets(userId: targetUserId)
             let (fetchedProfile, fetchedTweets) = try await (profile, userTweets)
             self.user = fetchedProfile
             self.tweets = fetchedTweets
         } catch let networkError as NetworkError {
             errorMessage = networkError.errorDescription
         } catch {
@@ -63,8 +59,12 @@ final class ProfileViewModel: ObservableObject {
         defer { isLoading = false }
         
         do {
+            let updatedUser = try await profileService.updateProfile(data: data)
             self.user = updatedUser
+            self.lastImageRefreshTime = Date().timeIntervalSince1970
+            self.shouldRefreshImage.toggle()
+            // 发布通知，传递最新的用户数据
+            NotificationCenter.default.post(name: .didUpdateProfile, object: updatedUser)
         } catch let networkError as NetworkError {
             errorMessage = networkError.errorDescription
         } catch {
@@ -73,28 +73,21 @@ final class ProfileViewModel: ObservableObject {
     }
     
     func uploadAvatar(imageData: Data) async {
         isLoading = true
         errorMessage = nil
         defer { isLoading = false }
         
         do {
+            let updatedUser = try await profileService.uploadAvatar(imageData: imageData)
             self.user = updatedUser
             self.lastImageRefreshTime = Date().timeIntervalSince1970
             self.shouldRefreshImage.toggle()
+            if let url = getAvatarURL() {
+                try await KingfisherManager.shared.cache.removeImage(forKey: url.absoluteString)
+            }
+            // 发布通知，全局更新
+            NotificationCenter.default.post(name: .didUpdateProfile, object: updatedUser)
+            try await fetchProfile()
         } catch let networkError as NetworkError {
             errorMessage = networkError.errorDescription
         } catch {
@@ -108,11 +101,3 @@ final class ProfileViewModel: ObservableObject {
         return URL(string: "\(baseURL)?t=\(Int(lastImageRefreshTime))")
     }
 }
--- a/Sources/Features/Profile/Views/EditProfileView.swift
+++ b/Sources/Features/Profile/Views/EditProfileView.swift
@@ -15,6 +15,8 @@ struct EditProfileView: View {
     // 图片相关状态
     @State private var profileImage: UIImage?
     @State private var bannerImage: UIImage?
+    @State private var showError = false
+    @State private var errorMessage: String?
 
     // 图片选择器相关状态
     @State private var showImagePicker = false
@@ -215,12 +217,14 @@ struct EditProfileView: View {
                                 "website": website,
                                 "location": location,
                             ])
+                            authState.currentUser = viewModel.user
+                            mode.wrappedValue.dismiss()
                         }
                     }) {
                         Text("Save")
                             .bold()
                     }
+                    .disabled(viewModel.isLoading)
                 }
                 .padding()
                 .background(Material.ultraThin)
@@ -229,50 +233,94 @@ struct EditProfileView: View {
                 Spacer()
             }
 
+            // ImagePicker 弹窗部分
             .sheet(isPresented: $showImagePicker) {
                 ImagePicker(image: $selectedImage)
                     .presentationDetents([.large])
                     .edgesIgnoringSafeArea(.all)
                     .onDisappear {
+                        Task {
+                            await handleSelectedImage()
                         }
                     }
             }
+            .alert("上传失败", isPresented: $showError) {
+                Button("确定", role: .cancel) {
+                    errorMessage = nil
+                }
+            } message: {
+                Text(errorMessage ?? "未知错误")
+            }
         }
+//      .onReceive(viewModel.$shouldRefreshImage) { _ in
+//     // mode.wrappedValue.dismiss()
+        // }
+//         .onReceive(viewModel.$user) { updatedUser in
+//             // 可选：若 updatedUser != nil，说明资料更新完毕
+//         }
         .onAppear {
             // 可选：清除缓存或其他逻辑
             KingfisherManager.shared.cache.clearCache()
         }
     }
 }
+
+extension EditProfileView {
+  private func handleSelectedImage() async {
+        guard let image = selectedImage else { return }
+
+        // 根据选择类型判断上传头像或banner
+        if imagePickerType == .profile {
+            profileImage = image
+
+            // 注意：字段名称需要与后端保持一致，此处传 "avatar"
+            ImageUploader.uploadImage(
+                paramName: "avatar", // 修改前为 "image"，现改为 "avatar"
+                fileName: "avatar.jpg",
+                image: image,
+                urlPath: "/users/me/avatar"
+            ) { result in
+                Task { @MainActor in
+                    switch result {
+                    case .success:
+                        // 上传成功后刷新个人资料
+                        await viewModel.fetchProfile()
+                    case let .failure(error):
+                        errorMessage = error.localizedDescription
+                        showError = true
+                    }
+                }
+            }
+
+            await viewModel.uploadAvatar(imageData: image.jpegData(compressionQuality: 0.8)!)
+
+            // 清除所有头像缓存
+            await KingfisherManager.shared.cache.clearMemoryCache()
+            await KingfisherManager.shared.cache.clearDiskCache()
+
+        } else if imagePickerType == .banner {
+            bannerImage = image
+            // 如果需要上传 banner，可类似实现：
+            /*
+             ImageUploader.uploadImage(
+                 paramName: "banner",
+                 fileName: "banner.jpg",
+                 image: image,
+                 urlPath: "/users/me/banner"
+             ) { result in
+                 Task { @MainActor in
+                     switch result {
+                     case .success(_):
+                         await viewModel.fetchProfile()
+                     case .failure(let error):
+                         errorMessage = error.localizedDescription
+                         showError = true
+                     }
+                 }
+             }
+             */
+        }
+
+        selectedImage = nil
+    }
+}
--- a/Sources/Features/Profile/Views/ProfileView.swift
+++ b/Sources/Features/Profile/Views/ProfileView.swift
@@ -64,7 +64,7 @@ struct ProfileView: View {
                 GeometryReader { proxy -> AnyView in
                     // 使用命名坐标空间 "scroll" 得到准确的偏移
                     let minY = proxy.frame(in: .named("scroll")).minY
+                  AnyView(
                         ZStack {
                             // Banner 图片：高度为 180，下拉时高度增加
                             Image("SSC_banner")
@@ -169,7 +169,8 @@ struct ProfileView: View {
                             .sheet(isPresented: $editProfileShow, onDismiss: {
                                 KingfisherManager.shared.cache.clearCache()
                             }, content: {
+                              EditProfileView(viewModel: viewModel)
+                              
                             })
                         }
                     }
--- a/Sources/Features/Search/ViewModels/SearchViewModel.swift
+++ b/Sources/Features/Search/ViewModels/SearchViewModel.swift
@@ -11,22 +11,22 @@ class SearchViewModel: ObservableObject {
     }
     
     func fetchUsers() {
+//        AuthService.requestDomain = "http://localhost:3000/users"
+//        
+//        AuthService.fetchUsers { res in
+//            switch res {
+//                case .success(let data):
+//                guard let users = try? JSONDecoder().decode([User].self, from: data!) else {
+//                        return
+//                    }
+//                    DispatchQueue.main.async {
+//                        self.users = users
+//                    }
+//
+//                case .failure(let error):
+//                    print(error.localizedDescription)
+//            }
+//        }
     }
     
     func filteredUsers(_ query: String) -> [User] {
--- a/api.md
+++ b//dev/null
@@ -1,91 +0,0 @@
--- a/git.md
+++ b/git.md
@@ -1,672 +0,0 @@
\ No newline at end of file