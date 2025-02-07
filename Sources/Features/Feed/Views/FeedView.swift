import SwiftUI

struct FeedView: View {
    @ObserveInjection var inject
    @Environment(\.diContainer) private var container
    @StateObject private var viewModel: FeedViewModel
    @EnvironmentObject private var authViewModel: AuthState

    init(container: DIContainer) {
        let tweetService: TweetServiceProtocol = container.resolve(.tweetService)
            ?? TweetService(apiClient: APIClient(baseURL: APIConfig.baseURL))
        _viewModel = StateObject(wrappedValue: FeedViewModel(tweetService: tweetService))
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.tweets) { tweet in
                    TweetCellView(
                        viewModel: TweetCellViewModel(
                            tweet: tweet,
                            tweetService: container.resolve(.tweetService)
                                ?? TweetService(apiClient: APIClient(baseURL: APIConfig.baseURL)),
                            notificationService: container.resolve(.notificationService)
                                ?? NotificationService(apiClient: APIClient(baseURL: APIConfig.baseURL)),
                            currentUserId: authViewModel.currentUser?.id ?? "",
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
        .refreshable {
            viewModel.fetchTweets()
        }
        .onAppear {
            viewModel.fetchTweets()
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .enableInjection()
    }
}
