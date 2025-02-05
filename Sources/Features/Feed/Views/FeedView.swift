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
                    TweetCellView(
                        viewModel: TweetCellViewModel(
                            tweet: tweet,
                            tweetService: container.resolve(.tweetService) ?? TweetService(apiClient: APIClient(baseURL: APIConfig.baseURL)),
                            onTweetUpdated: { updatedTweet in
                                viewModel.updateTweet(updatedTweet)
                            }
                        )
                    )
                    .padding(.horizontal)
                    Divider()
                }
            } 
        }
        .refreshable { // 添加下拉刷新
            viewModel.refresh()
        }
        .enableInjection()
    }
}
