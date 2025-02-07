

import SwiftUI

@MainActor
final class TweetCellViewModel: ObservableObject {
    @Published var tweet: Tweet
    @Published var isLoading = false
    @Published var error: Error?
    
    private let tweetService: TweetServiceProtocol
    private let onTweetUpdated: ((Tweet) -> Void)?
    
    init(
        tweet: Tweet,
        tweetService: TweetServiceProtocol,
        onTweetUpdated: ((Tweet) -> Void)? = nil
    ) {
        self.tweet = tweet
        self.tweetService = tweetService
        self.onTweetUpdated = onTweetUpdated
    }
    
    func likeTweet() {
        guard !isLoading else { return }
        isLoading = true
        
        Task {
            do {
                let updatedTweet = try await tweetService.likeTweet(tweetId: tweet.id)
                self.tweet = updatedTweet
                onTweetUpdated?(updatedTweet)
            } catch {
                self.error = error
                print("点赞失败: \(error)")
            }
            isLoading = false
        }
    }
    
    func unlikeTweet() {
        guard !isLoading else { return }
        isLoading = true
        
        Task {
            do {
                let updatedTweet = try await tweetService.unlikeTweet(tweetId: tweet.id)
                self.tweet = updatedTweet
                onTweetUpdated?(updatedTweet)
            } catch {
                self.error = error
                print("取消点赞失败: \(error)")
            }
            isLoading = false
        }
    }
    
  // 新增获取用户头像 URL 的方法
      func getUserAvatarURL() -> URL? {
          // 构造头像 URL，这里使用 tweet.userId
          return URL(string: "http://localhost:3000/users/\(tweet.userId)/avatar")
      }
      
    
    var isLiked: Bool {
        tweet.didLike ?? false
    }
    
    var likesCount: Int {
        tweet.likes?.count ?? 0
    }
}
