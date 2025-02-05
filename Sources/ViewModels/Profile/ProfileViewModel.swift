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
           userId != AuthViewModel.shared.user?.id
        {
            fetchUserData(userId: userId)
        } else {
                fetchUserData(userId: AuthViewModel.shared.user?.id ?? "")
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

    deinit {
        if  userId == AuthViewModel.shared.user?.id {
        AuthViewModel.shared.user! = self.user
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

 func follow() {
    guard let currentUser = AuthViewModel.shared.user else { return }
    
    // 1. 先更新 UI
    withAnimation {
        user.isFollowed = true
        isFollowing = true
        if !user.followers.contains(currentUser.id) {
            user.followers.append(currentUser.id)
        }
    }
    
    // 2. 后台进行数据更新
    Task {
      
        do {
            let result = try await withCheckedThrowingContinuation { continuation in
                RequestServices.followingProcess(userId: user.id, isFollowing: false) { result in
                    continuation.resume(with: result)
                }
            }
            
            // // 3. 成功后更新全局状态
            // await MainActor.run {
            //     if currentUser.id == AuthViewModel.shared.user?.id {
            //         var globalUser = AuthViewModel.shared.user!
            //         if !globalUser.following.contains(self.user.id) {
            //             globalUser.following.append(self.user.id)
            //             AuthViewModel.shared.user = globalUser
            //         }
            //     }
            // }
        } catch {
            // 4. 失败时回滚 UI
            await MainActor.run {
                withAnimation {
                    user.isFollowed = false
                    isFollowing = false
                    user.followers.removeAll(where: { $0 == currentUser.id })
                }
            }
            print("Follow error: \(error.localizedDescription)")
        }
    }
}

func unfollow() {
    guard let currentUser = AuthViewModel.shared.user else { return }
    
    // 1. 先更新 UI
    withAnimation {
        user.isFollowed = false
        isFollowing = false
        user.followers.removeAll(where: { $0 == currentUser.id })
    }
    
    // 2. 后台进行数据更新
    Task {
        do {
            let result = try await withCheckedThrowingContinuation { continuation in
                RequestServices.followingProcess(userId: user.id, isFollowing: true) { result in
                    continuation.resume(with: result)
                }
            }
            
            // 3. 成功后更新全局状态
            // await MainActor.run {
            //     if currentUser.id == AuthViewModel.shared.user?.id {
            //         var globalUser = AuthViewModel.shared.user!
            //         globalUser.following.removeAll(where: { $0 == self.user.id })
            //         AuthViewModel.shared.user = globalUser
            //     }
            // }
        } catch {
            // 4. 失败时回滚 UI
            await MainActor.run {
                withAnimation {
                    user.isFollowed = true
                    isFollowing = true
                    if !user.followers.contains(currentUser.id) {
                        user.followers.append(currentUser.id)
                    }
                }
            }
            print("Unfollow error: \(error.localizedDescription)")
        }
    }
}
}
