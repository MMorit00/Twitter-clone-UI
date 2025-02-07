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
    
    /// 通过比较 likes 数组判断是否已点赞
    var isLiked: Bool {
        tweet.likes?.contains(currentUserId) ?? false
    }
    
    /// 点赞数
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
        
        // 乐观更新点赞状态
        if tweet.likes == nil {
            tweet.likes = [currentUserId]
        } else if !(tweet.likes!.contains(currentUserId)) {
            tweet.likes!.append(currentUserId)
        }
        
        isLikeActionLoading = true
        
        Task {
            do {
                // 发送点赞请求
                let updatedTweet = try await tweetService.likeTweet(tweetId: tweet.id)
                self.tweet = updatedTweet
                onTweetUpdated?(updatedTweet)
                
                // 发送通知
                try await notificationService.createNotification(
                    username: tweet.username,
                    receiverId: tweet.userId,
                    type: .like,
                    postText: tweet.text
                )
            } catch {
                print("点赞失败: \(error)")
                // 回滚点赞状态
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
        
        // 乐观更新：移除 likes 数组中的当前用户 id
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
                print("取消点赞失败: \(error)")
                // 回滚：如果失败则将当前用户 id 加回去
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
    
    /// 获取头像 URL，不依赖点赞 loading 状态
    func getUserAvatarURL() -> URL? {
        URL(string: "http://localhost:3000/users/\(tweet.userId)/avatar")
    }
}
