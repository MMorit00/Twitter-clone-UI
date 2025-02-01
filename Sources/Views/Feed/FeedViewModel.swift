import Foundation

class FeedViewModel: ObservableObject {
    // 发布tweets数组属性
    @Published var tweets: [Tweet] = []

    init() {
        // 初始化时自动获取tweets
        fetchTweets()
    }

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
                        self?.tweets = tweets
                    }
                } catch {
                    print("JSON Decoding error: \(error)")
                }

            case let .failure(error):
                print("Network error: \(error.localizedDescription)")
            }
        }
    }
}
