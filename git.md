--- a/Sources/Features/Feed/Models/Tweet.swift
+++ b/Sources/Features/Feed/Models/Tweet.swift
@@ -1,33 +1,27 @@
 import Foundation
 
 struct Tweet: Identifiable, Decodable, Equatable {
+    // MongoDB 的 _id 字段
     let _id: String
     let text: String
     let userId: String
+    /// 用户昵称，如为空则显示默认值
     let username: String
+    /// 用户真实姓名，如为空则显示默认值
     let user: String
 
+    // 可选字段，后续预留扩展（例如是否带图片）
     var image: Bool?
+    /// 点赞列表：存储点赞的用户 id 数组
     var likes: [String]?
 
+    // 满足 Identifiable 协议
     var id: String {
         _id
     }
 
     enum CodingKeys: String, CodingKey {
+        case _id, text, userId, username, user, image, likes
     }
 
     init(from decoder: Decoder) throws {
@@ -35,20 +29,20 @@ struct Tweet: Identifiable, Decodable, Equatable {
 
         _id = try container.decode(String.self, forKey: ._id)
         text = try container.decode(String.self, forKey: .text)
+        
+        // 如果 userId 是嵌套对象，则解析其中的用户信息
+        if let userInfo = try? container.decode([String: String].self, forKey: .userId) {
+            userId = userInfo["_id"] ?? ""
+            user = userInfo["name"] ?? ""
+            username = userInfo["username"] ?? ""
         } else {
+            // 否则直接解码，并对 user 与 username 采用 decodeIfPresent，若缺失则提供默认值
             userId = try container.decode(String.self, forKey: .userId)
+            user = try container.decodeIfPresent(String.self, forKey: .user) ?? ""
+            username = try container.decodeIfPresent(String.self, forKey: .username) ?? ""
         }
+        
         image = try? container.decode(Bool.self, forKey: .image)
         likes = try? container.decode([String].self, forKey: .likes)
     }
+}
\ No newline at end of file
--- a/Sources/Features/Feed/ViewModels/TweetCellViewModel.swift
+++ b/Sources/Features/Feed/ViewModels/TweetCellViewModel.swift
@@ -1,46 +1,88 @@
 import SwiftUI
 
 @MainActor
 final class TweetCellViewModel: ObservableObject {
     @Published var tweet: Tweet
+    /// 用于防止重复点击点赞/取消点赞时的 loading 状态
+    @Published var isLikeActionLoading: Bool = false
     @Published var error: Error?
     
     private let tweetService: TweetServiceProtocol
+    /// 当前登录用户的 id，从认证模块传入
+    private let currentUserId: String
+    /// 当 tweet 被更新时回调（例如同步 FeedView 中的 tweet）
     private let onTweetUpdated: ((Tweet) -> Void)?
     
     init(
         tweet: Tweet,
         tweetService: TweetServiceProtocol,
+        currentUserId: String,
         onTweetUpdated: ((Tweet) -> Void)? = nil
     ) {
         self.tweet = tweet
         self.tweetService = tweetService
+        self.currentUserId = currentUserId
         self.onTweetUpdated = onTweetUpdated
     }
     
+    /// 通过比较 likes 数组判断是否已点赞
+    var isLiked: Bool {
+        tweet.likes?.contains(currentUserId) ?? false
+    }
+    
+    /// 点赞数
+    var likesCount: Int {
+        tweet.likes?.count ?? 0
+    }
+    
+    /// 点赞操作（乐观更新）
     func likeTweet() {
+        guard !isLikeActionLoading else { return }
+        // 如果已经点赞则切换为取消点赞
+        if isLiked {
+            unlikeTweet()
+            return
+        }
+        
+        // 乐观更新：将当前用户 id 添加到 likes 数组中
+        if tweet.likes == nil {
+            tweet.likes = [currentUserId]
+        } else if !(tweet.likes!.contains(currentUserId)) {
+            tweet.likes!.append(currentUserId)
+        }
+        
+        isLikeActionLoading = true
         
         Task {
             do {
                 let updatedTweet = try await tweetService.likeTweet(tweetId: tweet.id)
+                // 使用服务端返回数据确保状态一致
                 self.tweet = updatedTweet
                 onTweetUpdated?(updatedTweet)
             } catch {
                 print("点赞失败: \(error)")
+                // 回滚乐观更新
+                if var likes = tweet.likes {
+                    likes.removeAll { $0 == currentUserId }
+                    tweet.likes = likes
+                }
+                self.error = error
             }
+            isLikeActionLoading = false
         }
     }
     
+    /// 取消点赞操作（乐观更新）
     func unlikeTweet() {
+        guard !isLikeActionLoading else { return }
+        
+        // 乐观更新：移除 likes 数组中的当前用户 id
+        if var likes = tweet.likes {
+            likes.removeAll { $0 == currentUserId }
+            tweet.likes = likes
+        }
+        
+        isLikeActionLoading = true
         
         Task {
             do {
@@ -48,25 +90,21 @@ final class TweetCellViewModel: ObservableObject {
                 self.tweet = updatedTweet
                 onTweetUpdated?(updatedTweet)
             } catch {
                 print("取消点赞失败: \(error)")
+                // 回滚：如果失败则将当前用户 id 加回去
+                if tweet.likes == nil {
+                    tweet.likes = [currentUserId]
+                } else if !(tweet.likes!.contains(currentUserId)) {
+                    tweet.likes!.append(currentUserId)
+                }
+                self.error = error
             }
+            isLikeActionLoading = false
         }
     }
     
+    /// 获取头像 URL，不依赖点赞 loading 状态
+    func getUserAvatarURL() -> URL? {
+        URL(string: "http://localhost:3000/users/\(tweet.userId)/avatar")
     }
 }
--- a/Sources/Features/Feed/Views/FeedView.swift
+++ b/Sources/Features/Feed/Views/FeedView.swift
@@ -1,13 +1,14 @@
 import SwiftUI
 
 struct FeedView: View {
     @ObserveInjection var inject
     @Environment(\.diContainer) private var container
     @StateObject private var viewModel: FeedViewModel
+    @EnvironmentObject private var authViewModel: AuthState
 
     init(container: DIContainer) {
+        let tweetService: TweetServiceProtocol = container.resolve(.tweetService)
+            ?? TweetService(apiClient: APIClient(baseURL: APIConfig.baseURL))
         _viewModel = StateObject(wrappedValue: FeedViewModel(tweetService: tweetService))
     }
 
@@ -18,7 +19,9 @@ struct FeedView: View {
                     TweetCellView(
                         viewModel: TweetCellViewModel(
                             tweet: tweet,
+                            tweetService: container.resolve(.tweetService)
+                                ?? TweetService(apiClient: APIClient(baseURL: APIConfig.baseURL)),
+                            currentUserId: authViewModel.currentUser?.id ?? "",
                             onTweetUpdated: { updatedTweet in
                                 viewModel.updateTweet(updatedTweet)
                             }
--- a/Sources/Features/Feed/Views/TweetCellView.swift
+++ b/Sources/Features/Feed/Views/TweetCellView.swift
@@ -1,5 +1,5 @@
 import Kingfisher
+import SwiftUI
 
 struct TweetCellView: View {
     @ObserveInjection var inject
@@ -8,6 +8,7 @@ struct TweetCellView: View {
 
     var body: some View {
         VStack(alignment: .leading, spacing: 12) {
+            // 如果点赞数大于 0，则显示点赞数
             if viewModel.likesCount > 0 {
                 HStack(spacing: 8) {
                     Image(systemName: "heart.fill")
@@ -18,16 +19,16 @@ struct TweetCellView: View {
                 }
                 .padding(.trailing, 16)
             }
+
             HStack(alignment: .top, spacing: 12) {
+                // 头像区域：点击跳转到对应用户的个人主页
+                NavigationLink {
+                    ProfileView(userId: viewModel.tweet.userId, diContainer: container)
+                } label: {
+                    avatarView
+                }
+
+                // 推文内容区域
                 VStack(alignment: .leading, spacing: 4) {
                     // 用户信息
                     HStack {
@@ -37,7 +38,7 @@ struct TweetCellView: View {
                             .foregroundColor(.gray)
                         Text("·")
                             .foregroundColor(.gray)
+                        // 目前固定显示时间，后续可根据需求格式化
                         Text("11h")
                             .foregroundColor(.gray)
                     }
@@ -49,7 +50,7 @@ struct TweetCellView: View {
                         .frame(maxHeight: 100)
                         .lineSpacing(4)
 
+                    // 推文图片（如果存在）
                     if viewModel.tweet.image == true {
                         GeometryReader { proxy in
                             KFImage(URL(string: "http://localhost:3000/tweets/\(viewModel.tweet.id)/image"))
@@ -62,17 +63,21 @@ struct TweetCellView: View {
                         .zIndex(0)
                     }
 
+                    // 互动按钮区域
                     HStack(spacing: 40) {
                         InteractionButton(image: "message", count: 0)
                         InteractionButton(image: "arrow.2.squarepath", count: 0)
 
                         Button(action: {
+                            if viewModel.isLiked {
+                                viewModel.unlikeTweet()
+                            } else {
+                                viewModel.likeTweet()
+                            }
                         }) {
                             HStack(spacing: 4) {
+                                Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
+                                    .foregroundColor(viewModel.isLiked ? .red : .gray)
                                 if let likes = viewModel.tweet.likes {
                                     Text("\(likes.count)")
                                         .font(.system(size: 12))
@@ -96,30 +101,23 @@ struct TweetCellView: View {
         .contentShape(Rectangle())
         .enableInjection()
     }
+
     // 抽取的头像视图
     private var avatarView: some View {
+        KFImage(viewModel.getUserAvatarURL())
+            .placeholder {
+                Circle()
+                    .fill(Color.gray)
                     .frame(width: 44, height: 44)
             }
+            .resizable()
+            .scaledToFill()
+            .frame(width: 44, height: 44)
+            .clipShape(Circle())
     }
 }
 
+// MARK: - 子视图：互动按钮
 
 private struct InteractionButton: View {
     let image: String
--- a/Sources/Features/Profile/Views/ProfileView.swift
+++ b/Sources/Features/Profile/Views/ProfileView.swift
@@ -365,14 +365,14 @@ struct TweetListView: View {
     var tweets: [Tweet]
     var viewModel: ProfileViewModel
     @Environment(\.diContainer) private var container
+    @EnvironmentObject private var authViewModel: AuthState 
     var body: some View {
         VStack(spacing: 18) {
             ForEach(tweets) { tweet in
                 TweetCellView(
                     viewModel: TweetCellViewModel(
                         tweet: tweet,
+                        tweetService: container.resolve(.tweetService) ?? TweetService(apiClient: APIClient(baseURL: APIConfig.baseURL)), currentUserId: authViewModel.currentUser?.id ?? ""
                     )
                 )
                 Divider()
@@ -381,4 +381,4 @@ struct TweetListView: View {
         .padding(.top)
         .zIndex(0)
     }
\ No newline at end of file
+}
--- a/git.md
+++ b/git.md
@@ -1,237 +1,702 @@
\ No newline at end of file
+import Foundation
+import SwiftUI
+
+struct Tweet: Identifiable, Decodable, Equatable {
+    // MongoDB的_id字段
+    let _id: String
+    let text: String
+    let userId: String
+    let username: String
+    let user: String
+
+    // 可选字段,后续功能预留
+    var image: Bool?
+    var likes: [String]?
+    var didLike: Bool? = false // 添加点赞状态标记
+
+    // 满足Identifiable协议
+    var id: String {
+        _id
+    }
+
+    // 处理JSON字段映射
+    enum CodingKeys: String, CodingKey {
+        case _id
+        case text
+        case userId
+        case username
+        case user
+        case image
+        case likes
+    }
+
+    init(from decoder: Decoder) throws {
+        let container = try decoder.container(keyedBy: CodingKeys.self)
+
+        _id = try container.decode(String.self, forKey: ._id)
+        text = try container.decode(String.self, forKey: .text)
+
+        // 处理嵌套的用户信息
+        if let userId = try? container.decode([String: String].self, forKey: .userId) {
+            self.userId = userId["_id"] ?? ""
+            user = userId["name"] ?? ""
+            username = userId["username"] ?? ""
+        } else {
+            // 兼容直接字符串形式的 userId
+            userId = try container.decode(String.self, forKey: .userId)
+            user = try container.decode(String.self, forKey: .user)
+            username = try container.decode(String.self, forKey: .username)
+        }
+
+        image = try? container.decode(Bool.self, forKey: .image)
+        likes = try? container.decode([String].self, forKey: .likes)
+    }
+}
+
+
+
+import SwiftUI
+
+@MainActor
+final class TweetCellViewModel: ObservableObject {
+    @Published var tweet: Tweet
+    @Published var isLoading = false
+    @Published var error: Error?
+    
+    private let tweetService: TweetServiceProtocol
+    private let onTweetUpdated: ((Tweet) -> Void)?
+    
+    init(
+        tweet: Tweet,
+        tweetService: TweetServiceProtocol,
+        onTweetUpdated: ((Tweet) -> Void)? = nil
+    ) {
+        self.tweet = tweet
+        self.tweetService = tweetService
+        self.onTweetUpdated = onTweetUpdated
+    }
+    
+    func likeTweet() {
+        guard !isLoading else { return }
+        isLoading = true
+        
+        Task {
+            do {
+                let updatedTweet = try await tweetService.likeTweet(tweetId: tweet.id)
+                self.tweet = updatedTweet
+                onTweetUpdated?(updatedTweet)
+            } catch {
+                self.error = error
+                print("点赞失败: \(error)")
+            }
+            isLoading = false
+        }
+    }
+    
+    func unlikeTweet() {
+        guard !isLoading else { return }
+        isLoading = true
+        
+        Task {
+            do {
+                let updatedTweet = try await tweetService.unlikeTweet(tweetId: tweet.id)
+                self.tweet = updatedTweet
+                onTweetUpdated?(updatedTweet)
+            } catch {
+                self.error = error
+                print("取消点赞失败: \(error)")
+            }
+            isLoading = false
+        }
+    }
+    
+  // 新增获取用户头像 URL 的方法
+      func getUserAvatarURL() -> URL? {
+          // 构造头像 URL，这里使用 tweet.userId
+          return URL(string: "http://localhost:3000/users/\(tweet.userId)/avatar")
+      }
+      
+    
+    var isLiked: Bool {
+        tweet.didLike ?? false
+    }
+    
+    var likesCount: Int {
+        tweet.likes?.count ?? 0
+    }
+}
+
+//
+//  TweetService.swift
+//  CloneTwitter
+//
+//  Created by 潘令川 on 2025/2/5.
+//
+import Foundation
+
+struct ImageUploadResponse: Codable {
+    let message: String
+}
+
+
+
+
+
+import Foundation
+import UIKit
+
+protocol TweetServiceProtocol {
+    
+  func fetchTweets() async throws -> [Tweet]
+  func createTweet(text: String, userId: String) async throws -> Tweet
+  func likeTweet(tweetId: String) async throws -> Tweet
+  func unlikeTweet(tweetId: String) async throws -> Tweet
+  func uploadImage(tweetId: String, image: UIImage) async throws -> ImageUploadResponse
+
+}
+
+final class TweetService: TweetServiceProtocol {
+    private let apiClient: APIClientProtocol
+
+    init(apiClient: APIClientProtocol) {
+        self.apiClient = apiClient
+    }
+
+    func fetchTweets() async throws -> [Tweet] {
+        let endpoint = TweetEndpoint.fetchTweets
+        return try await apiClient.sendRequest(endpoint)
+    }
+
+    func createTweet(text: String, userId: String) async throws -> Tweet {
+        let endpoint = TweetEndpoint.createTweet(text: text, userId: userId)
+        return try await apiClient.sendRequest(endpoint)
+    }
+
+    func likeTweet(tweetId: String) async throws -> Tweet {
+        let endpoint = TweetEndpoint.likeTweet(tweetId: tweetId)
+        return try await apiClient.sendRequest(endpoint)
+    }
+
+    func unlikeTweet(tweetId: String) async throws -> Tweet {
+        let endpoint = TweetEndpoint.unlikeTweet(tweetId: tweetId)
+        return try await apiClient.sendRequest(endpoint)
+    }
+
+    func uploadImage(tweetId: String, image: UIImage) async throws -> ImageUploadResponse {
+        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
+            throw NetworkError.custom("Failed to convert image to data")
+        }
+        
+        let endpoint = TweetEndpoint.uploadImage(tweetId: tweetId, imageData: imageData)
+        return try await apiClient.sendRequest(endpoint)
+    }
+}
+
+#if DEBUG
+    final class MockTweetService: TweetServiceProtocol {
+        var shouldSucceed = true
+
+        func fetchTweets() async throws -> [Tweet] {
+            if shouldSucceed {
+                return [.mock, .mock]
+            } else {
+                throw NetworkError.serverError
+            }
+        }
+
+        func createTweet(text _: String, userId _: String) async throws -> Tweet {
+            if shouldSucceed {
+                return .mock
+            } else {
+                throw NetworkError.serverError
+            }
+        }
+
+        func likeTweet(tweetId _: String) async throws -> Tweet {
+            if shouldSucceed {
+                return .mock
+            } else {
+                throw NetworkError.serverError
+            }
+        }
+
+        func unlikeTweet(tweetId _: String) async throws -> Tweet {
+            if shouldSucceed {
+                return .mock
+            } else {
+                throw NetworkError.serverError
+            }
+        }
+
+      func uploadImage(tweetId _: String, image _: UIImage) async throws -> ImageUploadResponse {
+          if shouldSucceed {
+              return ImageUploadResponse(message: "Tweet image uploaded successfully")
+          } else {
+              throw NetworkError.serverError
+          }
+      }
+    }
+
+    // Mock 实现修正
+
+#if DEBUG
+extension Tweet {
+    static var mock: Tweet {
+        let json = """
+        {
+            "_id": "mock_id",
+            "text": "This is a mock tweet",
+            "userId": "mock_user_id",
+            "username": "mock_username",
+            "user": "Mock User"
+        }
+        """.data(using: .utf8)!
+        
+        return try! JSONDecoder().decode(Tweet.self, from: json)
+    }
+}
+#endif
+#endif
+
+import SwiftUI
+import Kingfisher
+
+struct TweetCellView: View {
+    @ObserveInjection var inject
+    @ObservedObject var viewModel: TweetCellViewModel
+    @Environment(\.diContainer) private var container
+
+    var body: some View {
+        VStack(alignment: .leading, spacing: 12) {
+            if viewModel.likesCount > 0 {
+                HStack(spacing: 8) {
+                    Image(systemName: "heart.fill")
+                        .foregroundColor(.gray)
+                    Text("\(viewModel.likesCount) likes")
+                        .font(.system(size: 14))
+                        .foregroundColor(.gray)
+                }
+                .padding(.trailing, 16)
+            }
+            
+            HStack(alignment: .top, spacing: 12) {
+                // 头像部分：点击头像跳转到对应用户的个人主页
+              NavigationLink {
+                  ProfileView(userId: viewModel.tweet.userId, diContainer: container)
+              } label: {
+                  avatarView
+              }
+                
+                // 推文内容
+                VStack(alignment: .leading, spacing: 4) {
+                    // 用户信息
+                    HStack {
+                        Text(viewModel.tweet.user)
+                            .fontWeight(.semibold)
+                        Text("@\(viewModel.tweet.username)")
+                            .foregroundColor(.gray)
+                        Text("·")
+                            .foregroundColor(.gray)
+                        // TODO: 添加时间格式化显示
+                        Text("11h")
+                            .foregroundColor(.gray)
+                    }
+                    .font(.system(size: 16))
+
+                    // 推文文本
+                    Text(viewModel.tweet.text)
+                        .font(.system(size: 16))
+                        .frame(maxHeight: 100)
+                        .lineSpacing(4)
+
+                    // Tweet Image (if exists)
+                    if viewModel.tweet.image == true {
+                        GeometryReader { proxy in
+                            KFImage(URL(string: "http://localhost:3000/tweets/\(viewModel.tweet.id)/image"))
+                                .resizable()
+                                .scaledToFill()
+                                .frame(width: proxy.size.width, height: 200)
+                                .cornerRadius(15)
+                        }
+                        .frame(height: 200)
+                        .zIndex(0)
+                    }
+
+                    // 互动按钮
+                    HStack(spacing: 40) {
+                        InteractionButton(image: "message", count: 0)
+                        InteractionButton(image: "arrow.2.squarepath", count: 0)
+
+                        Button(action: {
+                            viewModel.likeTweet()
+                        }) {
+                            HStack(spacing: 4) {
+                                Image(systemName: viewModel.tweet.didLike! ? "heart.fill" : "heart")
+                                    .foregroundColor(viewModel.tweet.didLike! ? .red : .gray)
+                                if let likes = viewModel.tweet.likes {
+                                    Text("\(likes.count)")
+                                        .font(.system(size: 12))
+                                        .foregroundColor(.gray)
+                                }
+                            }
+                        }
+                        .zIndex(1)
+                        .padding(8)
+                        .contentShape(Rectangle())
+
+                        InteractionButton(image: "square.and.arrow.up", count: nil)
+                    }
+                    .padding(.top, 8)
+                    .frame(maxWidth: .infinity, alignment: .leading)
+                }
+                .contentShape(Rectangle())
+            }
+            .frame(maxWidth: .infinity, alignment: .leading)
+        }
+        .contentShape(Rectangle())
+        .enableInjection()
+    }
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
+}
+
+// MARK: - 子视图
+
+private struct InteractionButton: View {
+    let image: String
+    let count: Int?
+
+    var body: some View {
+        HStack(spacing: 4) {
+            Image(systemName: image)
+                .foregroundColor(.gray)
+            if let count = count {
+                Text("\(count)")
+                    .font(.system(size: 12))
+                    .foregroundColor(.gray)
+            }
+        }
+    }
+}
+
+import SwiftUI
+
+
+struct FeedView: View {
+    @ObserveInjection var inject
+    @Environment(\.diContainer) private var container
+    @StateObject private var viewModel: FeedViewModel
+
+    init(container: DIContainer) {
+        let tweetService: TweetServiceProtocol = container.resolve(.tweetService) ?? TweetService(apiClient: APIClient(baseURL: APIConfig.baseURL))
+        _viewModel = StateObject(wrappedValue: FeedViewModel(tweetService: tweetService))
+    }
+
+    var body: some View {
+        ScrollView {
+            LazyVStack(spacing: 16) {
+                ForEach(viewModel.tweets) { tweet in
+                    TweetCellView(
+                        viewModel: TweetCellViewModel(
+                            tweet: tweet,
+                            tweetService: container.resolve(.tweetService) ?? TweetService(apiClient: APIClient(baseURL: APIConfig.baseURL)),
+                            onTweetUpdated: { updatedTweet in
+                                viewModel.updateTweet(updatedTweet)
+                            }
+                        )
+                    )
+                    .padding(.horizontal)
+                    Divider()
+                }
+            }
+        }
+        .refreshable {
+            viewModel.fetchTweets()
+        }
+        .onAppear {
+            viewModel.fetchTweets()
+        }
+        .overlay {
+            if viewModel.isLoading {
+                ProgressView()
+            }
+        }
+        .enableInjection()
+    }
+}
+
+
+import SwiftUI
+import Combine
+
+@MainActor
+final class FeedViewModel: ObservableObject {
+    @Published var tweets: [Tweet] = []
+    @Published var isLoading = false
+    @Published var error: Error?
+    
+    private let tweetService: TweetServiceProtocol
+    private var refreshTask: Task<Void, Never>?
+    
+    init(tweetService: TweetServiceProtocol) {
+        self.tweetService = tweetService
+    }
+    
+    func fetchTweets() {
+        isLoading = true
+        error = nil
+        
+        refreshTask?.cancel()
+        refreshTask = Task {
+            do {
+                tweets = try await tweetService.fetchTweets()
+            } catch {
+                self.error = error
+                print("获取推文失败: \(error)")
+            }
+            isLoading = false
+        }
+    }
+    
+    // 提供一个更新单个推文的方法，供 TweetCellViewModel 调用
+    func updateTweet(_ updatedTweet: Tweet) {
+        if let index = tweets.firstIndex(where: { $0.id == updatedTweet.id }) {
+            tweets[index] = updatedTweet
+        }
+    }
+}
+const express = require("express");
+const Tweet = require("../models/Tweet");
+const auth = require("../middleware/auth");
+const multer = require("multer");
+const sharp = require("sharp");
+const router = new express.Router();
+
+// 配置 multer
+const upload = multer({
+  limits: {
+    fileSize: 1000000, // 限制文件大小为1MB
+  },
+});
+
+router.post("/tweets", auth, async (req, res) => {
+  try {
+    const tweet = new Tweet({
+      ...req.body,
+      userId: req.user._id,
+    });
+    await tweet.save();
+    res.status(201).send(tweet);
+  } catch (error) {
+    res.status(400).send(error);
+  }
+});
+
+// 获取所有推文可以保持公开
+router.get("/tweets", async (req, res) => {
+  try {
+    const tweets = await Tweet.find()
+      .populate("userId", "name username")
+      .sort({ createdAt: -1 }); // 按时间倒序排列
+    res.send(tweets);
+  } catch (error) {
+    res.status(500).send(error);
+  }
+});
+
+// 上传推文图片路由
+router.post(
+  "/tweets/:id/image",
+  auth,
+  upload.single("image"),
+  async (req, res) => {
+    try {
+      const tweet = await Tweet.findOne({
+        _id: req.params.id,
+        userId: req.user._id,
+      });
+
+      if (!tweet) {
+        throw new Error("Tweet not found or unauthorized");
+      }
+
+      // 使用 sharp 处理图片
+      const buffer = await sharp(req.file.buffer)
+        .resize(1080) // 调整宽度,保持宽高比
+        .png()
+        .toBuffer();
+
+      tweet.image = buffer;
+      await tweet.save();
+      res.send({ message: "Tweet image uploaded successfully" });
+    } catch (error) {
+      res.status(400).send({ error: error.message });
+    }
+  }
+);
+
+// 获取推文图片路由
+router.get("/tweets/:id/image", async (req, res) => {
+  try {
+    const tweet = await Tweet.findById(req.params.id);
+
+    if (!tweet || !tweet.image) {
+      throw new Error("Tweet or image not found");
+    }
+
+    res.set("Content-Type", "image/png");
+    res.send(tweet.image);
+  } catch (error) {
+    res.status(404).send({ error: error.message });
+  }
+});
+
+// 点赞推文路由
+router.put("/tweets/:id/like", auth, async (req, res) => {
+  try {
+    // 1. 查找推文
+    const tweet = await Tweet.findById(req.params.id);
+
+    if (!tweet) {
+      return res.status(404).send({ error: "Tweet not found" });
+    }
+
+    // 2. 检查是否已经点赞
+    if (!tweet.likes.includes(req.user._id)) {
+      // 3. 添加点赞
+      await Tweet.updateOne(
+        { _id: req.params.id },
+        {
+          $push: { likes: req.user._id },
+        }
+      );
+      res.status(200).send({ message: "Tweet has been liked" });
+    } else {
+      // 4. 已点赞则返回错误
+      res.status(403).send({ error: "You have already liked this tweet" });
+    }
+  } catch (error) {
+    res.status(500).send(error);
+  }
+});
+
+// ... existing code ...
+
+// 取消点赞推文路由
+router.put("/tweets/:id/unlike", auth, async (req, res) => {
+  try {
+    // 1. 查找推文
+    const tweet = await Tweet.findById(req.params.id);
+
+    if (!tweet) {
+      return res.status(404).send({ error: "Tweet not found" });
+    }
+
+    // 2. 检查是否已经点赞
+    if (tweet.likes.includes(req.user._id)) {
+      // 3. 移除点赞
+      await Tweet.updateOne(
+        { _id: req.params.id },
+        {
+          $pull: { likes: req.user._id },
+        }
+      );
+      res.status(200).send({ message: "Tweet has been unliked" });
+    } else {
+      // 4. 未点赞则返回错误
+      res.status(403).send({ error: "You have already unliked this tweet" });
+    }
+  } catch (error) {
+    res.status(500).send(error);
+  }
+});
+
+
+// 获取特定用户的推文
+router.get("/tweets/user/:id", async (req, res) => {
+  try {
+    const tweets = await Tweet.find({
+      userId: req.params.id,
+    })
+      .populate("userId", "name username")
+      .sort({ createdAt: -1 });
+
+    if (!tweets || tweets.length === 0) {
+      return res.status(404).send([]);
+    }
+
+    res.send(tweets);
+  } catch (error) {
+    res.status(500).send(error);
+  }
+});
+
+
+module.exports = router;
+const mongoose = require("mongoose");
+
+const tweetSchema = new mongoose.Schema(
+  {
+    text: {
+      type: String,
+      required: true,
+      trim: true,
+    },
+    userId: {
+      type: mongoose.Schema.Types.ObjectId,
+      required: true,
+      ref: "User",
+    },
+    likes: [
+      {
+        type: mongoose.Schema.Types.ObjectId,
+        ref: "User",
+      },
+    ],
+    image: {
+      type: Buffer,
+    },
+  },
+  {
+    timestamps: true, // 添加 createdAt 和 updatedAt 字段
+  }
+);
+
+
+// 修改toJSON方法来处理图片属性
+tweetSchema.methods.toJSON = function () {
+  const tweet = this;
+  const tweetObject = tweet.toObject();
+
+  // 检查图片是否存在
+  if (tweetObject.image) {
+    tweetObject.image = true;  // 如果存在图片,将image属性设置为true
+  }
+
+  return tweetObject;
+};
+
+
+
+const Tweet = mongoose.model("Tweet", tweetSchema);
+
+module.exports = Tweet;