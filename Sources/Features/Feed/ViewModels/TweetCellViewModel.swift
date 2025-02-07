import SwiftUI

@MainActor
final class TweetCellViewModel: ObservableObject {
    @Published var tweet: Tweet
    /// 用于防止重复点击点赞/取消点赞时的 loading 状态
    @Published var isLikeActionLoading: Bool = false
    @Published var error: Error?
    
    private let tweetService: TweetServiceProtocol
    /// 当前登录用户的 id，从认证模块传入
    private let currentUserId: String
    /// 当 tweet 被更新时回调（例如同步 FeedView 中的 tweet）
    private let onTweetUpdated: ((Tweet) -> Void)?
    
    init(
        tweet: Tweet,
        tweetService: TweetServiceProtocol,
        currentUserId: String,
        onTweetUpdated: ((Tweet) -> Void)? = nil
    ) {
        self.tweet = tweet
        self.tweetService = tweetService
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
        // 如果已经点赞则切换为取消点赞
        if isLiked {
            unlikeTweet()
            return
        }
        
        // 乐观更新：将当前用户 id 添加到 likes 数组中
        if tweet.likes == nil {
            tweet.likes = [currentUserId]
        } else if !(tweet.likes!.contains(currentUserId)) {
            tweet.likes!.append(currentUserId)
        }
        
        isLikeActionLoading = true
        
        Task {
            do {
                let updatedTweet = try await tweetService.likeTweet(tweetId: tweet.id)
                // 使用服务端返回数据确保状态一致
                self.tweet = updatedTweet
                onTweetUpdated?(updatedTweet)
            } catch {
                print("点赞失败: \(error)")
                // 回滚乐观更新
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
