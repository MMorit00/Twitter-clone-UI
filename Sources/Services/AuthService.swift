import Foundation

//! authService 与 requestService 的差异在于 requestService 返回的是 json 数据，而 authService 返回的是 APIResponse 数据
public class AuthService {
    // 静态域名变量
    public static var requestDomain: String = ""

    // 注册API的静态URL
    private static let registerURL = "http://localhost:3000/users"

    // 添加登录URL常量
    private static let loginURL = "http://localhost:3000/users/login"

    // 添加获取用户信息的URL
    private static let userURL = "http://localhost:3000/users/"

    // MARK: - Error Types

    enum NetworkError: Error {
        case invalidURL
        case noData
        case decodingError
    }

    enum AuthenticationError: Error {
        case invalidCredentials
        case custom(String)
    }

    // MARK: - Network Request

    static func makeRequest(
        urlString: String,
        requestBody: [String: Any],
        completion: @escaping (Result<Data, NetworkError>) -> Void
    ) {
        // 1. 创建 URL
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }

        // 2. 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // 3. 设置请求体
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            request.httpBody = jsonData
        } catch {
            completion(.failure(.invalidURL))
            return
        }

        // 4. 创建数据任务
        let task = URLSession.shared.dataTask(with: request) { data, _, _ in
            // 检查是否有数据
            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            // 返回成功结果
            completion(.success(data))
        }

        // 5. 开始任务
        task.resume()
    }

    // MARK: - Response Type

    struct APIResponse: Codable {
        let user: User
        let token: String
    }

    // MARK: - Authentication Methods

    static func register(
        email: String,
        username: String,
        password: String,
        name: String,
        completion: @escaping (Result<APIResponse, AuthenticationError>) -> Void
    ) {
        // 构建请求体
        let requestBody: [String: Any] = [
            "email": email,
            "username": username,
            "password": password,
            "name": name,
        ]

        // 调用 makeRequest
        makeRequest(urlString: registerURL, requestBody: requestBody) { result in
            switch result {
            case let .success(data):
                // 尝试解码返回的数据
                do {
                    let response = try JSONDecoder().decode(APIResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(.custom("Failed to decode response")))
                }

            case let .failure(error):
                switch error {
                case .noData:
                    completion(.failure(.custom("No data received")))
                case .invalidURL:
                    completion(.failure(.custom("Invalid URL")))
                case .decodingError:
                    completion(.failure(.custom("Failed to decode response")))
                }
            }
        }
    }

    // 登录方法
    static func login(
        email: String,
        password: String,
        completion: @escaping (Result<APIResponse, AuthenticationError>) -> Void
    ) {
        // 构建请求体
        let requestBody: [String: Any] = [
            "email": email,
            "password": password,
        ]

        // 调用makeRequest
        makeRequest(urlString: loginURL, requestBody: requestBody) { result in
            switch result {
            case let .success(data):
                do {
                    let response = try JSONDecoder().decode(APIResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(.custom("Failed to decode response")))
                }

            case let .failure(error):
                switch error {
                case .noData:
                    completion(.failure(.custom("No data received")))
                case .invalidURL:
                    completion(.failure(.custom("Invalid URL")))
                case .decodingError:
                    completion(.failure(.custom("Failed to decode response")))
                }
            }
        }
    }

    // 获取用户信息方法
    static func fetchUser(
        userId: String,
        token: String,
        completion: @escaping (Result<User, AuthenticationError>) -> Void
    ) {
        // 构建完整的URL
        let urlString = userURL + userId

        guard let url = URL(string: urlString) else {
            completion(.failure(.custom("Invalid URL")))
            return
        }

        // 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = "GET" // 明确指定GET方法
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // 发送请求
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(.custom(error.localizedDescription)))
                return
            }

            guard let data = data else {
                completion(.failure(.custom("No data received")))
                return
            }

            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                completion(.success(user))
            } catch {
                completion(.failure(.custom("Failed to decode user data")))
            }
        }

        task.resume()
    }

    // 添加 PATCH 请求方法
    static func makePatchRequestWithAuth(
        urlString: String,
        requestBody: [String: Any],
        token: String,
        completion: @escaping (Result<Data, NetworkError>) -> Void
    ) {
        // 1. 创建 URL
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }

        // 2. 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // 3. 设置请求体
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            request.httpBody = jsonData
        } catch {
            completion(.failure(.invalidURL))
            return
        }

        // 4. 创建数据任务
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            // 检查是否有错误
            if let error = error {
                completion(.failure(.noData))
                return
            }

            // 检查是否有数据
            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            // 返回成功结果
            completion(.success(data))
        }

        // 5. 开始任务
        task.resume()
    }

    // static func makePatchRequestWithAuth(
//    urlString: String,
//    requestBody: [String: Any],
//    token: String,
//    completion: @escaping (Result<Data, NetworkError>) -> Void
    // ) {
//    // 使用 Task 在后台调用 async 版本
//    Task {
//        do {
//            let data = try await makePatchRequestWithAuth(
//                urlString: urlString,
//                requestBody: requestBody,
//                token: token
//            )
//            completion(.success(data))
//        } catch {
//            if let networkError = error as? NetworkError {
//                completion(.failure(networkError))
//            } else {
//                completion(.failure(.noData))
//            }
//        }
//    }
    // }

    static func fetchUserById(
        userId: String,
        token: String,
        completion: @escaping (Result<User, AuthenticationError>) -> Void
    ) {
        // 构建URL
        let urlString = "http://localhost:3000/users/\(userId)"
        guard let url = URL(string: urlString) else {
            completion(.failure(.custom("Invalid URL")))
            return
        }

        // 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // 发送请求
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(.custom(error.localizedDescription)))
                return
            }

            guard let data = data else {
                completion(.failure(.custom("No data received")))
                return
            }

            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                completion(.success(user))
            } catch {
                completion(.failure(.custom("Failed to decode user data")))
            }
        }.resume()
    }
}
