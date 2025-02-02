import Combine
import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var tweets = [Tweet]()
    @Published var user: User
    @Published var shouldRefreshImage = false
    @Published var isLoading = false
    @Published var error: Error?

    // 添加TweetCellViewModel缓存
    private var tweetViewModels: [String: TweetCellViewModel] = [:]
    private var lastImageRefreshTime: TimeInterval = 0
    private var cancellables = Set<AnyCancellable>()
    private var userId: String?

    var isCurrentUser: Bool {
        userId == nil || userId == AuthViewModel.shared.user?.id
    }

    init(userId: String? = nil) {
        self.userId = userId

        // 初始化一个空的用户对象
        if let currentUser = AuthViewModel.shared.user {
            user = currentUser
        } else {
            // 提供一个默认的空用户对象
            user = User(username: "", name: "", email: "")
        }

        // 如果是查看其他用户的profile
        if let userId = userId, userId != AuthViewModel.shared.user?.id {
            fetchUserData(userId: userId)
        } else {
            // 如果是当前用户，监听用户更新
            AuthViewModel.shared.$user
                .compactMap { $0 }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] updatedUser in
                    self?.user = updatedUser
                    let currentTime = Date().timeIntervalSince1970
                    if currentTime - (self?.lastImageRefreshTime ?? 0) > 1.0 {
                        self?.shouldRefreshImage.toggle()
                        self?.lastImageRefreshTime = currentTime
                    }
                }
                .store(in: &cancellables)
        }

        fetchTweets()
    }

    private func fetchUserData(userId: String) {
        isLoading = true
        error = nil

        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            error = AuthenticationError.custom("No token found")
            isLoading = false
            return
        }

        AuthService.fetchUserById(userId: userId, token: token) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case let .success(fetchedUser):
                    self?.user = fetchedUser
                    self?.fetchTweets()
                case let .failure(error):
                    self?.error = error
                }
            }
        }
    }

    // 获取带时间戳的头像URL
    func getAvatarURL() -> URL? {
        let baseURL = "http://localhost:3000/users/\(user.id)/avatar"
        return URL(string: "\(baseURL)?t=\(Int(lastImageRefreshTime))")
    }

    // 获取或创建TweetCellViewModel
    func getTweetCellViewModel(for tweet: Tweet) -> TweetCellViewModel {
        if let existing = tweetViewModels[tweet.id] {
            return existing
        }
        let viewModel = TweetCellViewModel(tweet: tweet)
        tweetViewModels[tweet.id] = viewModel
        return viewModel
    }

    // 修改 fetchTweets 方法
    func fetchTweets() {
        isLoading = true

        // 确定要请求的用户ID
        let targetUserId: String
        if let userId = userId {
            targetUserId = userId
        } else if let currentUserId = AuthViewModel.shared.user?.id {
            targetUserId = currentUserId
        } else {
            isLoading = false
            return
        }

        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            isLoading = false
            return
        }

        let urlString = "http://localhost:3000/tweets/user/\(targetUserId)"
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                guard let data = data else { return }

                do {
                    let tweets = try JSONDecoder().decode([Tweet].self, from: data)
                    self?.tweets = tweets

                    // 清理不再需要的viewModel
                    self?.cleanupTweetViewModels(currentTweets: tweets)
                } catch {
                    print("Error decoding tweets: \(error)")
                }
            }
        }.resume()
    }

    // 清理不再使用的viewModel
    private func cleanupTweetViewModels(currentTweets: [Tweet]) {
        let currentIds = Set(currentTweets.map { $0.id })
        tweetViewModels = tweetViewModels.filter { currentIds.contains($0.key) }
    }
}
