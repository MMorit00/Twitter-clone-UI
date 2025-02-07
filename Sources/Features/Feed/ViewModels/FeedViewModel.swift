

import SwiftUI
import Combine

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var tweets: [Tweet] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let tweetService: TweetServiceProtocol
    private var refreshTask: Task<Void, Never>?
    
    init(tweetService: TweetServiceProtocol) {
        self.tweetService = tweetService
    }
    
    func fetchTweets() {
        isLoading = true
        error = nil
        
        refreshTask?.cancel()
        refreshTask = Task {
            do {
                tweets = try await tweetService.fetchTweets()
            } catch {
                self.error = error
                print("获取推文失败: \(error)")
            }
            isLoading = false
        }
    }
    
    // 提供一个更新单个推文的方法，供 TweetCellViewModel 调用
    func updateTweet(_ updatedTweet: Tweet) {
        if let index = tweets.firstIndex(where: { $0.id == updatedTweet.id }) {
            tweets[index] = updatedTweet
        }
    }
}