import Foundation

public class RequestServices {
    // 服务器域名,可配置
    public static var requestDomain: String = ""

    // 发推文的网络请求方法
    public static func postTweet(
        text: String,
        user: String,
        username: String,
        userId: String,
        completion: @escaping (Result<[String: Any]?, Error>) -> Void
    ) {
        // 构建请求URL
        guard let url = URL(string: requestDomain + "/tweets") else { return }

        // 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // 添加认证token
        guard let token = UserDefaults.standard.string(forKey: "JSON_WEB_TOKEN") else { return }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // 设置JSON请求头
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        // 构建请求参数
        let params: [String: Any] = [
            "text": text,
            "user": user,
            "username": username,
            "userId": userId,
        ]

        // JSON序列化
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            request.httpBody = jsonData

            // 创建数据任务
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                // 错误处理
                if let error = error {
                    completion(.failure(error))
                    return
                }

                // 解析响应数据
                guard let data = data else { return }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        completion(.success(json))
                    }
                } catch {
                    completion(.failure(error))
                }
            }

            // 开始请求
            task.resume()

        } catch {
            completion(.failure(error))
        }
    }

    // 获取推文列表的网络请求方法
    static func fetchTweets(completion: @escaping (Result<Data, Error>) -> Void) {
        // 构建请求URL
        guard let url = URL(string: requestDomain) else { return }

        // 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // 添加认证token
        guard let token = UserDefaults.standard.string(forKey: "jwt") else { return }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // 设置JSON请求头
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        // 创建数据任务
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            // 错误处理
            if let error = error {
                completion(.failure(error))
                return
            }

            // 检查并返回数据
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            completion(.success(data))
        }

        // 开始请求
        task.resume()
    }
}

// 定义网络错误类型
enum NetworkError: Error {
    case noData
}
