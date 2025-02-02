import Combine
import Foundation

class FeedViewModel: ObservableObject {
    // 发布tweets数组属性
    @Published var tweets: [Tweet] = []
    @Published var user: User // 添加用户属性

    private var cancellables = Set<AnyCancellable>()
    private var refreshTimer: AnyCancellable? // 用于定时刷新

    init() {
        // 初始化用户
        user = AuthViewModel.shared.user!

        // 订阅用户变化
        AuthViewModel.shared.$user
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedUser in
                self?.user = updatedUser
                // 用户更新时刷新 tweets
                self?.fetchTweets()
            }
            .store(in: &cancellables)

        // // 设置定时刷新（例如每30秒）
        // setupRefreshTimer()

        // 初始获取tweets
        fetchTweets()
    }

    // private func setupRefreshTimer() {
    //     refreshTimer = Timer.publish(every: 30, on: .main, in: .common)
    //         .autoconnect()
    //         .sink { [weak self] _ in
    //             self?.fetchTweets()
    //         }
    // }

    func fetchTweets() {
        // 设置请求域名
        RequestServices.requestDomain = "http://localhost:3000/tweets"

        // 调用网络请求方法获取tweets
        RequestServices.fetchTweets { [weak self] result in
            switch result {
            case let .success(data):
                // 添加日志输出
                print("Received data: \(String(data: data, encoding: .utf8) ?? "")")

                do {
                    let tweets = try JSONDecoder().decode([Tweet].self, from: data)
                    print("Successfully decoded \(tweets.count) tweets")

                    DispatchQueue.main.async {
                        // 更新前比较，避免不必要的UI刷新
                        if self?.tweets != tweets {
                            self?.tweets = tweets
                        }
                    }
                } catch {
                    print("JSON Decoding error: \(error)")
                }

            case let .failure(error):
                print("Network error: \(error.localizedDescription)")
            }
        }
    }

    // 添加手动刷新方法
    func refresh() {
        fetchTweets()
    }

    // 清理资源
    deinit {
        refreshTimer?.cancel()
        cancellables.removeAll()
    }
}
