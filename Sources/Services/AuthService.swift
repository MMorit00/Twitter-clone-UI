import Foundation

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
        case custom(String)
    }
    
    enum AuthenticationError: Error {
        case invalidCredentials
        case custom(String)
    }


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
        completion(.failure(.custom("JSON序列化失败：\(error.localizedDescription)")))
        return
    }

    // 4. 创建数据任务
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        // 检查是否有错误
        if let error = error {
            completion(.failure(.custom("网络请求错误：\(error.localizedDescription)")))
            return
        }
        // 检查 HTTP 状态码
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            var errMsg = "服务器返回状态码 \(httpResponse.statusCode)"
            // 如有返回数据，尝试转换为字符串
            if let data = data, let serverMessage = String(data: data, encoding: .utf8) {
                errMsg += "，详情：\(serverMessage)"
            }
            completion(.failure(.custom(errMsg)))
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
    // MARK: - Response Type

struct APIResponse: Codable {
    let user: User
    let token: String?   // 修改为可选类型
}

    // MARK: - Authentication Methods

  static func register(
    email: String,
    username: String,
    password: String,
    name: String,
    completion: @escaping (Result<User, AuthenticationError>) -> Void
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
            // 尝试解码前先打印返回的字符串（便于调试）
            if let dataString = String(data: data, encoding: .utf8) {
                print("注册返回数据：\(dataString)")
            }
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                completion(.success(user))
            } catch {
                print("解码失败：\(error.localizedDescription)")
                completion(.failure(.custom("解析用户数据失败")))
            }

        case let .failure(error):
            completion(.failure(.custom(error.localizedDescription)))
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
                  case .custom(_):
                    completion(.failure(.custom(error.localizedDescription)))
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



    static func fetchUsers(completion: @escaping (_ result: Result<Data?, AuthenticationError>) -> Void) {
        
        let urlString = URL(string: "http://localhost:3000/users")!
        
        let urlRequest = URLRequest(url: urlString)
        
        let url = URL(string: requestDomain)!
        
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
            
        request.httpMethod = "GET"
        
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: reqBody, options: .prettyPrinted)
//        }
//        catch let error {
//            print(error)
//        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = session.dataTask(with: request) { data, res, err in
            guard err == nil else {
                
                return
                
            }
            
            guard let data = data else {
                completion(.failure(.invalidCredentials))
                return
                
            }
            
            completion(.success(data))
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    
                    
                }
                
            }
            catch let error {
                completion(.failure(.invalidCredentials))
                print(error)
            }
        }
        
        task.resume()
    }
}
// 为 NetworkError 添加 LocalizedError 支持
extension AuthService.NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的 URL。"
        case .noData:
            return "没有接收到服务器数据。"
        case .decodingError:
            return "数据解析失败。"
        case .custom(let message):
            return message
        }
    }
}

// 为 AuthenticationError 添加 LocalizedError 支持
extension AuthService.AuthenticationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "用户名或密码不正确。"
        case .custom(let message):
            return message
        }
    }
}
