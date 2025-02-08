import SwiftUI

@MainActor
final class TweetCellViewModel: ObservableObject {
    @Published var tweet: Tweet
    @Published var isLikeActionLoading: Bool = false
    @Published var error: Error?
    
    private let tweetService: TweetServiceProtocol
    private let notificationService: NotificationServiceProtocol
    private let currentUserId: String
    private let onTweetUpdated: ((Tweet) -> Void)?
    
    init(
        tweet: Tweet,
        tweetService: TweetServiceProtocol,
        notificationService: NotificationServiceProtocol,
        currentUserId: String,
        onTweetUpdated: ((Tweet) -> Void)? = nil
    ) {
        self.tweet = tweet
        self.tweetService = tweetService
        self.notificationService = notificationService
        self.currentUserId = currentUserId
        self.onTweetUpdated = onTweetUpdated
    }
    
    /// 判断当前用户是否已点赞
    var isLiked: Bool {
        tweet.likes?.contains(currentUserId) ?? false
    }
    
    /// 点赞数量
    var likesCount: Int {
        tweet.likes?.count ?? 0
    }
    
    /// 点赞操作（乐观更新）
    func likeTweet() {
        guard !isLikeActionLoading else { return }
        if isLiked {
            unlikeTweet()
            return
        }
        
        // 乐观更新：先在本地添加当前用户
        if tweet.likes == nil {
            tweet.likes = [currentUserId]
        } else if !(tweet.likes!.contains(currentUserId)) {
            tweet.likes!.append(currentUserId)
        }
        
        isLikeActionLoading = true
        
        Task {
            do {
                let updatedTweet = try await tweetService.likeTweet(tweetId: tweet.id)
                self.tweet = updatedTweet
                onTweetUpdated?(updatedTweet)
                // 同时发送通知（如需要）
                try await notificationService.createNotification(
                    username: tweet.username,
                    receiverId: tweet.userId,
                    type: .like,
                    postText: tweet.text
                )
            } catch {
                // 回滚本地状态
                if var likes = tweet.likes {
                    likes.removeAll { $0 == currentUserId }
                    tweet.likes = likes
                }
                self.error = error
            }
            isLikeActionLoading = false
        }
    }
    
    /// 取消点赞操作（乐观更新）
    func unlikeTweet() {
        guard !isLikeActionLoading else { return }
        if var likes = tweet.likes {
            likes.removeAll { $0 == currentUserId }
            tweet.likes = likes
        }
        isLikeActionLoading = true
        
        Task {
            do {
                let updatedTweet = try await tweetService.unlikeTweet(tweetId: tweet.id)
                self.tweet = updatedTweet
                onTweetUpdated?(updatedTweet)
            } catch {
                // 回滚：将当前用户重新加回去
                if tweet.likes == nil {
                    tweet.likes = [currentUserId]
                } else if !(tweet.likes!.contains(currentUserId)) {
                    tweet.likes!.append(currentUserId)
                }
                self.error = error
            }
            isLikeActionLoading = false
        }
    }
    
    /// 根据传入的全局 AuthState 生成头像 URL（带时间戳以避免缓存问题）
    func getUserAvatarURL(from authState: AuthState) -> URL? {
        // 如果当前 tweet 用户与全局 currentUser 相同，则附加时间戳
        if authState.currentUser?.id == tweet.userId {
            let timestamp = Int(Date().timeIntervalSince1970)
            return URL(string: "http://localhost:3000/users/\(tweet.userId)/avatar?t=\(timestamp)")
        } else {
            return URL(string: "http://localhost:3000/users/\(tweet.userId)/avatar")
        }
    }
}