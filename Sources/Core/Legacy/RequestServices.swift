
import Foundation

// 添加响应模型
struct FollowResponse: Codable {
    let message: String
}

// 添加点赞响应模型
struct LikeResponse: Codable {
    let message: String
}



// 添加点赞响应模型
struct ErrorResponse: Codable {
    let message: String
}

public class RequestServices {
    // 修改 requestDomain 的默认值和访问级别
    public static var requestDomain: String = "http://localhost:3000"

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
        guard let token = UserDefaults.standard.string(forKey: "jwt") else { return }
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

    // 修改 followingProcess 方法
    static func followingProcess(
        userId: String,
        isFollowing: Bool,
        completion: @escaping (Result<FollowResponse, Error>) -> Void
    ) {
        // 打印当前的 requestDomain 用于调试
        print("Current requestDomain: \(requestDomain)")

        let endpoint = isFollowing ? "/unfollow" : "/follow"

        // 确保 requestDomain 末尾没有 "/"，也没有 "/tweets"
        var baseURL = requestDomain
        if baseURL.hasSuffix("/") {
            baseURL = String(baseURL.dropLast())
        }
        if baseURL.hasSuffix("/tweets") {
            baseURL = String(baseURL.dropLast(7)) // 移除 "/tweets"
        }

        // 构建完整的URL
        let urlString = "\(baseURL)/users/\(userId)\(endpoint)"
        print("Request URL: \(urlString)") // 调试日志

        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            completion(.failure(NetworkError.noToken))
            return
        }

        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        // 添加调试日志
        print("Sending \(isFollowing ? "unfollow" : "follow") request for user: \(userId)")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // 打印 HTTP 响应状态码
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            // 打印原始响应数据用于调试
            if let responseString = String(data: data, encoding: .utf8) {
                print("Server response: \(responseString)")
            }

            do {
                let response = try JSONDecoder().decode(FollowResponse.self, from: data)
                completion(.success(response))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(error))
            }
        }

        task.resume()
    }

    // 修改 likeTweet 方法
    static func likeTweet(
        tweetId: String,
        isLiked: Bool,
        completion: @escaping (Result<LikeResponse, Error>) -> Void
    ) {
        // 构建URL
        let endpoint = isLiked ? "/unlike" : "/like"
        let urlString = "http://localhost:3000/tweets/\(tweetId)\(endpoint)"

        print("Request URL: \(urlString)") // 调试日志

        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        // 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        // 添加认证
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            completion(.failure(NetworkError.noToken))
            return
        }

        // 设置请求头
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // 发送请求
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // 打印 HTTP 响应状态码和原始响应数据（用于调试）
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }

            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Raw response: \(responseString)")
            }

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            do {
                let response = try JSONDecoder().decode(LikeResponse.self, from: data)
                completion(.success(response))
            } catch {
                // 尝试解码错误响应
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    completion(.failure(NetworkError.custom(errorResponse.message)))
                } else {
                    completion(.failure(error))
                }
            }
        }

        task.resume()
    }

 static func fetchData(completion: @escaping (_ result: Result<Data?, NetworkError>) -> Void) {
    guard let token = UserDefaults.standard.string(forKey: "jwt") else {
        completion(.failure(.noToken))
        return
    }
    
    // 确保URL正确拼接
    guard let url = URL(string: requestDomain + "/notifications") else {
        completion(.failure(.invalidURL))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    // 添加认证 token
    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Status Code: \(httpResponse.statusCode)")  // 输出响应的 HTTP 状态码
        }
        
        if let error = error {
            print("Error fetching data: \(error.localizedDescription)")  // 打印请求错误
            completion(.failure(.custom(error.localizedDescription)))
            return
        }
        
        guard let data = data else {
            print("No data received")  // 没有接收到数据时的错误提示
            completion(.failure(.noData))
            return
        }
        
        // 打印返回的原始数据
        if let responseString = String(data: data, encoding: .utf8) {
            print("Raw response: \(responseString)")
        }
        
        // 验证返回的数据是否为有效的 JSON
        do {
            _ = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            completion(.success(data))
        } catch {
            print("Invalid JSON response: \(error)")  // 解析JSON失败
            completion(.failure(.custom("Invalid JSON response")))
        }
    }
    
    task.resume()
}

    public static func sendNotification(username: String, notSenderId: String, notReceiverId: String, notificationType: String, postText: String, completion: @escaping (_ result: [String: Any]?) -> Void) {
        // 确保 notificationReceiverId 是有效的字符串，并符合 MongoDB ObjectId 格式
        guard !notReceiverId.isEmpty else {
            print("Error: notificationReceiverId is empty.")
            return
        }


        // 构建请求参数
        var params: [String: Any] {
            return postText.isEmpty ? [
                "username": username,
                "notSenderId": notSenderId,
                "notReceiverId": notReceiverId, // 确保传递的是字符串
                "notificationType": notificationType
            ] : [
                "username": username,
                "notSenderId": notSenderId,
                "notReceiverId": notReceiverId, // 确保传递的是字符串
                "notificationType": notificationType,
                "postText": postText,
            ]
        }

        // 打印请求参数，调试请求
        print("Sending notification with params: \(params)") // Debugging the params being sent

        // 确保正确的请求URL
        guard let url = URL(string: requestDomain + "/notifications") else {
            print("Invalid URL for sending notification.")
            return
        }

        let session = URLSession.shared
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        } catch {
            print("Error serializing JSON: \(error)")
            return
        }

        let token = UserDefaults.standard.string(forKey: "jwt")!
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = session.dataTask(with: request) { data, _, err in
            // 打印请求错误
            if let err = err {
                print("Error sending notification: \(err.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received.")
                return
            }

            // 打印原始响应数据
            print("Raw response: \(String(data: data, encoding: .utf8) ?? "No data")")

            // 尝试解析响应
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print("Notification sent successfully: \(json)") // Debugging successful response
                    completion(json)
                }
            } catch {
                print("Error decoding response: \(error)") // Debugging response decoding error
            }
        }
        task.resume()
    }
}
