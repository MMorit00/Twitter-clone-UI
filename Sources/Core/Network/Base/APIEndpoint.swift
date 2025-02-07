import Foundation

protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem]? { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
}

// Auth 相关的 endpoints
enum AuthEndpoint: APIEndpoint {
    case login(email: String, password: String)
    case register(email: String, username: String, password: String, name: String)
    case fetchCurrentUser
    case updateProfile(data: [String: Any])

    var path: String {
        switch self {
        case .login:
            return "/users/login"
        case .register:
            return "/users"
        case .fetchCurrentUser:
            return "/users/me"
        case .updateProfile:
            return "/users/me"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .register:
            return .post
        case .fetchCurrentUser:
            return .get
        case .updateProfile:
            return .patch
        }
    }

    var body: Data? {
        switch self {
        case let .login(email, password):
            let body = ["email": email, "password": password]
            return try? JSONSerialization.data(withJSONObject: body)

        case let .register(email, username, password, name):
            let body = [
                "email": email,
                "username": username,
                "password": password,
                "name": name,
            ]
            return try? JSONSerialization.data(withJSONObject: body)

        case let .updateProfile(data):
            return try? JSONSerialization.data(withJSONObject: data)

        default:
            return nil
        }
    }

    var headers: [String: String]? {
        var headers = ["Content-Type": "application/json"]

        // 对需要认证的接口添加 token
        switch self {
        case .fetchCurrentUser, .updateProfile:
            if let token = UserDefaults.standard.string(forKey: "jwt") {
                headers["Authorization"] = "Bearer \(token)"
            }
        default:
            break
        }

        return headers
    }

    var queryItems: [URLQueryItem]? {
        return nil
    }
}

// Tweet 相关的 endpoints
enum TweetEndpoint: APIEndpoint {
    case fetchTweets
    case createTweet(text: String, userId: String)
    case likeTweet(tweetId: String)
    case unlikeTweet(tweetId: String)
    case uploadImage(tweetId: String, imageData: Data)

    var path: String {
        switch self {
        case .fetchTweets:
            return "/tweets"
        case .createTweet:
            return "/tweets"
        case let .likeTweet(id):
            return "/tweets/\(id)/like"
        case let .unlikeTweet(id):
            return "/tweets/\(id)/unlike"
        case let .uploadImage(id, _):
            return "/tweets/\(id)/image"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchTweets:
            return .get
        case .createTweet, .uploadImage:
            return .post
        case .likeTweet, .unlikeTweet:
            return .put
        }
    }

    var headers: [String: String]? {
        var headers: [String: String] = [:]
        
        if case .uploadImage = self {
            // 修改: 使用正确的 multipart Content-Type
            let boundary = UUID().uuidString
            headers["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
        } else {
            headers["Content-Type"] = "application/json"
        }
        
        if let token = UserDefaults.standard.string(forKey: "jwt") {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return headers
    }
    
    var body: Data? {
        switch self {
        case let .createTweet(text, userId):
            let body = ["text": text, "userId": userId]
            return try? JSONSerialization.data(withJSONObject: body)
        case let .uploadImage(_, imageData):
            // 修改: 构造 multipart 请求体
            let boundary = UUID().uuidString
            var data = Data()
            
            // 添加图片数据
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"image\"; filename=\"tweet.jpg\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            data.append(imageData)
            data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            
            return data
        default:
            return nil
        }
    }
    
    var queryItems: [URLQueryItem]? {
        return nil
    }
}
