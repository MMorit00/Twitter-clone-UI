import Combine
import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var tweets = [Tweet]()
    @Published var user: User
    @Published var shouldRefreshImage = false
    @Published var error: Error?
    @Published var isFollowing = false

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
        checkIfUserIsFollowed()
    }

    private func fetchUserData(userId: String) {
        error = nil

        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            error = AuthenticationError.custom("No token found")
            return
        }

        AuthService.fetchUserById(userId: userId, token: token) { [weak self] result in
            DispatchQueue.main.async {
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
        // 确定要请求的用户ID
        let targetUserId: String
        if let userId = userId {
            targetUserId = userId
        } else if let currentUserId = AuthViewModel.shared.user?.id {
            targetUserId = currentUserId
        } else {
            return
        }

        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            return
        }

        let urlString = "http://localhost:3000/tweets/user/\(targetUserId)"
        guard let url = URL(string: urlString) else {
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let data = data else { return }

                do {
                    let tweets = try JSONDecoder().decode([Tweet].self, from: data)
                    self?.tweets = tweets
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

    // 初始化时设置关注状态
    private func checkIfUserIsFollowed() {
        guard let currentUserId = AuthViewModel.shared.user?.id else { return }
        isFollowing = user.followers.contains(currentUserId)
    }

    // Follow/Unfollow 方法
    func followUser() {
        guard let token = UserDefaults.standard.string(forKey: "jwt") else { return }
        let userId = user.id

        let urlString = "http://localhost:3000/users/\(userId)/follow"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // 乐观更新UI
        isFollowing = true

        URLSession.shared.dataTask(with: request) { [weak self] _, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error following user: \(error)")
                    // 如果失败,恢复原状态
                    self?.isFollowing = false
                    return
                }

                // 更新用户数据，但不显示 loading
                if let userId = self?.user.id {
                    self?.fetchUserData(userId: userId)
                }
            }
        }.resume()
    }

    func unfollowUser() {
        guard let token = UserDefaults.standard.string(forKey: "jwt") else { return }
        let userId = user.id

        let urlString = "http://localhost:3000/users/\(userId)/unfollow"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // 乐观更新UI
        isFollowing = false

        URLSession.shared.dataTask(with: request) { [weak self] _, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error unfollowing user: \(error)")
                    // 如果失败,恢复原状态
                    self?.isFollowing = true
                    return
                }

                // 更新用户数据时使用
                if let userId = self?.user.id {
                    self?.fetchUserData(userId: userId)
                }
            }
        }.resume()
    }
}
