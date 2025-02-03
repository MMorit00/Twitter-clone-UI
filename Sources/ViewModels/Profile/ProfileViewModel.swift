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
        // 如果 userId 为空或者等于当前用户ID，则说明是查看自己
        userId == nil || userId == AuthViewModel.shared.user?.id
    }

    init(userId: String? = nil) {
        self.userId = userId

        // 先给 user 赋一个当前用户或空 user 的初始值
        if let currentUser = AuthViewModel.shared.user {
            user = currentUser
        } else {
            user = User(username: "", name: "", email: "")
        }

        // 如果是查看其他用户的profile，就调用 fetchUserData
        if let userId = userId,
           userId != AuthViewModel.shared.user?.id {
            fetchUserData(userId: userId)
        } else {
            // 如果是当前用户，则订阅 AuthViewModel.shared.$user
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

            // 加载当前用户自己的推文
            fetchTweets()
        }
    }

    private func fetchUserData(userId: String) {
        error = nil

        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            error = AuthenticationError.custom("No token found")
            return
        }

        AuthService.fetchUser(userId: userId, token: token) { [weak self] result in
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

        guard let currentUser = AuthViewModel.shared.user else {
            fatalError("Current user should not be nil when creating TweetCellViewModel")
        }

        let viewModel = TweetCellViewModel(tweet: tweet, currentUser: currentUser)
        tweetViewModels[tweet.id] = viewModel
        return viewModel
    }

    // 加载推文
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

    // 在 user 里检查是否关注
    func checkIfUserIsFollowed() {
        guard let currentUserId = AuthViewModel.shared.user?.id else { return }

        // 检查目标用户的followers数组里是否包含当前用户ID
        let isFollowed = user.followers.contains(currentUserId)
        user.isFollowed = isFollowed
        isFollowing = isFollowed
    }

    // 修改 follow 方法：本地更新，不再重拉整个用户数据
    func follow() {
        guard let currentUser = AuthViewModel.shared.user else { return }

        RequestServices.followingProcess(userId: user.id, isFollowing: false) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(response):
                    if response.message.contains("已经关注") {
                        // 如果接口提示已经关注，确保UI状态正确
                        self?.user.isFollowed = true
                        self?.isFollowing = true
                    } else {
                        // 正常关注成功,更新本地状态
                        self?.user.followers.append(currentUser.id)
                        self?.user.isFollowed = true
                        self?.isFollowing = true
                    }
                    
                    // -------- 关键改动 --------
                    // 只有当“要关注的这个用户”就是当前用户自己时，才在全局里更新 following
                    // （一般来说，这种场景不多见。但如果你确实需要“我自己”关注“我自己”，可以酌情改动）
                    //
                    // 如果你想让全局的 AuthViewModel 记录下「当前用户关注了谁」信息，可以这样：
                    if currentUser.id == AuthViewModel.shared.user?.id {
                        // 说明我在查看我的Profile，不用动
                        // 或者：AuthViewModel.shared.user?.followers = self?.user.followers ?? []
                    } else {
                        // 如果是“我”去关注其他人，需要局部更新 AuthViewModel.shared.user 的 following
                        // 注意这样也会触发较大范围刷新，必要时可以省略
                        AuthViewModel.shared.user?.following.append(self?.user.id ?? "")
                    }
                    // -------------------------
                    
                    print("Follow response: \(response.message)")

                case let .failure(error):
                    print("Follow error: \(error.localizedDescription)")
                }
            }
        }
    }

    // 修改 unfollow 方法：本地更新，不再重拉用户数据
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

                    // 2. 如果要同步修改全局当前用户的 following，也只做局部操作
                    if currentUser.id == AuthViewModel.shared.user?.id {
                        // 说明我在操作自己，不用动
                    } else {
                        AuthViewModel.shared.user?.following.removeAll(where: { $0 == self?.user.id })
                    }

                    print("Unfollow success: \(response.message)")

                case let .failure(error):
                    print("Unfollow error: \(error.localizedDescription)")
                }
            }
        }
    }
}
