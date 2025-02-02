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
                    // 确保正确设置关注状态
                    self?.checkIfUserIsFollowed()
                    let currentTime = Date().timeIntervalSince1970
                    if currentTime - (self?.lastImageRefreshTime ?? 0) > 1.0 {
                        self?.shouldRefreshImage.toggle()
                        self?.lastImageRefreshTime = currentTime
                    }
                }
                .store(in: &cancellables)

            fetchTweets()
        }
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
                    // 获取用户数据后立即检查关注状态
                    self?.checkIfUserIsFollowed()
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

    // 修改 checkIfUserIsFollowed 方法
    func checkIfUserIsFollowed() {
        guard let currentUserId = AuthViewModel.shared.user?.id else { return }

        // 检查是否在 followers 数组中
        let isFollowed = user.followers.contains(currentUserId)
        user.isFollowed = isFollowed
        isFollowing = isFollowed

        print("Checking follow status - isFollowed: \(isFollowed)")
    }

    // 修改 follow 方法
    func follow() {
        guard let currentUser = AuthViewModel.shared.user else { return }

        RequestServices.followingProcess(userId: user.id, isFollowing: false) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(response):
                    if response.message.contains("已经关注") {
                        // 如果已经关注,确保UI状态正确
                        self?.user.isFollowed = true
                        self?.isFollowing = true
                    } else {
                        // 关注成功,更新状态
                        self?.user.followers.append(currentUser.id)
                        self?.user.isFollowed = true
                        self?.isFollowing = true

                        // 更新当前用户的 following
                        if var currentUser = AuthViewModel.shared.user {
                            currentUser.following.append(self?.user.id ?? "")
                            AuthViewModel.shared.updateCurrentUser(currentUser)
                        }
                    }
                    print("Follow response: \(response.message)")

                case let .failure(error):
                    print("Follow error: \(error.localizedDescription)")
                }
            }
        }
    }

    // 修改 unfollow 方法
    func unfollow() {
        guard let currentUser = AuthViewModel.shared.user else { return }

        RequestServices.followingProcess(userId: user.id, isFollowing: true) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(response):
                    // 1. 更新目标用户的 followers
                    self?.user.followers.removeAll(where: { $0 == currentUser.id })
                    self?.user.isFollowed = false
                    self?.isFollowing = false

                    // 2. 更新当前用户的 following
                    if var currentUser = AuthViewModel.shared.user {
                        currentUser.following.removeAll(where: { $0 == self?.user.id })
                        AuthViewModel.shared.updateCurrentUser(currentUser)
                    }

                    print("Unfollow success: \(response.message)")

                case let .failure(error):
                    print("Unfollow error: \(error.localizedDescription)")
                }
            }
        }
    }

//    func checkIfIsCurrentUser() {
//        if user._id == AuthViewModel.shared.user?._id {
//            user.isCurrentUser = true
//        }
//    }
}

// 添加错误响应模型
struct ErrorResponse: Codable {
    let message: String
}
