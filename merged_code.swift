// Merged Swift Files


// MARK: - App/App.swift

//
//  App.swift
//  CloneTwitter
//
//  Created by 潘令川 on 2025/2/5.
//

import Foundation
@_exported import Inject
import SwiftUI

@main
struct TwitterCloneApp: App {
    
    let container: DIContainer = {
        let container = DIContainer.defaultContainer()
        
        #if DEBUG
        // 打印调试信息
        if let client: APIClientProtocol = container.resolve(.apiClient) {
            print("成功注册 APIClient")
        } else {
            print("APIClient 注册失败")
        }
        #endif
        
        return container
    }()


   @StateObject private var authState: AuthState = {
        guard let authService: AuthServiceProtocol = DIContainer.defaultContainer().resolve(.authService) else {
            fatalError("Failed to resolve AuthService")
        }
        return AuthState(authService: authService)
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.diContainer, container)
                .environmentObject(authState)
        }
    }
}


// MARK: - App/ContentView.swift

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authState: AuthState
    
    var body: some View {
        Group {
            if authState.isAuthenticated {
                MainView()
            } else {
                WelcomeView()
            }
        }
    }
}


// MARK: - App/DIContainer.swift

import Foundation
import SwiftUI

final class DIContainer {
    private var dependencies: [String: Any] = [:]
    
    // MARK: - Registration
    
    func register<T>(_ dependency: T, for key: String) {
        dependencies[key] = dependency
    }
    
    func register<T>(_ dependency: T, type: ServiceType) {
        register(dependency, for: type.rawValue)
    }
    
    // MARK: - Resolution
    
    func resolve<T>(_ key: String) -> T? {
        return dependencies[key] as? T
    }
    
    func resolve<T>(_ type: ServiceType) -> T? {
        return resolve(type.rawValue)
    }
    
    // MARK: - Lifecycle
    
    func reset() {
        dependencies.removeAll()
    }
    
    // MARK: - Service Types
    
    enum ServiceType: String {
        case apiClient
        case authService
        case tweetService
        case profileService
        case notificationService
        case imageUploadService
    }
    
    // MARK: - Convenience Methods
    
    static func defaultContainer() -> DIContainer {
        let container = DIContainer()
        
        // 配置基础服务
        let apiClient = APIClient(baseURL: APIConfig.baseURL)
        container.register(apiClient, type: .apiClient)
        
        // 配置 AuthService
        let authService = AuthService1(apiClient: apiClient)
        container.register(authService, type: .authService)
        
        // 配置 TweetService
        let tweetService = TweetService(apiClient: apiClient)
        container.register(tweetService, type: .tweetService)
        
        // 配置 ProfileService
        let profileService = ProfileService(apiClient: apiClient)
        container.register(profileService, type: .profileService)
        
        // 配置 NotificationService
        let notificationService = NotificationService(apiClient: apiClient)
        container.register(notificationService, type: .notificationService)
        
        return container
    }
}

// MARK: - Environment Integration

private struct DIContainerKey: EnvironmentKey {
    static let defaultValue = DIContainer.defaultContainer()
}

extension EnvironmentValues {
    var diContainer: DIContainer {
        get { self[DIContainerKey.self] }
        set { self[DIContainerKey.self] = newValue }
    }
}


// MARK: - Core/Common/Extensions/ImagePicker.swift

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    // 改为可选类型
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var mode

    // 创建UIImagePickerController
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    // 更新控制器(本例中不需要实现)
    func updateUIViewController(_: UIImagePickerController, context _: Context) {}

    // 创建协调器
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // 协调器类处理图片选择回调
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        // 处理图片选择完成的回调
        func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                // 直接赋值可选类型
                parent.image = image
            }

            // 关闭图片选择器
            parent.mode.wrappedValue.dismiss()
        }
    }
}


// MARK: - Core/Legacy/ImageUploader.swift

import SwiftUI

enum ImageUploader {
    /// 上传图片的静态方法
    static func uploadImage(
        paramName: String,
        fileName: String,
        image: UIImage,
        urlPath: String,
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        // 1. 构建完整URL
        guard let url = URL(string: "http://localhost:3000\(urlPath)") else { return }
        
        // 2. 生成 boundary
        let boundary = UUID().uuidString
        
        // 3. 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // 4. 设置请求头（注意替换 token 获取方式）
        guard let token = UserDefaults.standard.string(forKey: "jwt") else { return }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // 5. 构建 multipart 表单数据
        var data = Data()
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        if let imageData = image.jpegData(compressionQuality: 0.5) {
            data.append(imageData)
        }
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        // 6. 创建上传任务
        let task = URLSession.shared.uploadTask(with: request, from: data) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    completion(.success(json))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        // 7. 开始上传
        task.resume()
    }
}

// MARK: - Core/Network/Base/APIClient.swift

import Foundation

/// 定义网络请求协议，用于依赖注入和测试
protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

/// API客户端协议
protocol APIClientProtocol {
    func sendRequest<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
    func sendRequestWithoutDecoding(_ endpoint: APIEndpoint) async throws
}

/// API客户端实现，处理所有网络请求
final class APIClient: APIClientProtocol {
    private let baseURL: URL
    private let session: URLSessionProtocol
    private let maxRetries: Int

    init(baseURL: URL,
         session: URLSessionProtocol = URLSession.shared,
         maxRetries: Int = 3)
    {
        self.baseURL = baseURL
        self.session = session
        self.maxRetries = maxRetries
    }

    /// 发送网络请求，支持自动重试机制
    func sendRequest<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        var attempts = 0

        while attempts < maxRetries {
            do {
                return try await performRequest(endpoint)
            } catch NetworkError.unauthorized {
                throw NetworkError.unauthorized
            } catch NetworkError.serverError {
                attempts += 1
                if attempts == maxRetries {
                    throw NetworkError.maxRetriesExceeded
                }
                // 指数退避重试
                try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempts))) * 1_000_000_000)
                continue
            }
        }

        throw NetworkError.maxRetriesExceeded
    }

    /// 执行实际的网络请求并处理响应
    private func performRequest<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path),
                                       resolvingAgainstBaseURL: true)
        components?.queryItems = endpoint.queryItems

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        // 添加：避免使用缓存
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        #if DEBUG
            logRequest(request)
        #endif

        let (data, response) = try await session.data(for: request)

        #if DEBUG
            logResponse(response, data: data)
        #endif

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200 ... 299:
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                // 创建自定义的 ISO8601 格式化器，并支持毫秒
                let isoFormatter = ISO8601DateFormatter()
                isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

                // 设置自定义日期解码策略
                decoder.dateDecodingStrategy = .custom { decoder -> Date in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    if let date = isoFormatter.date(from: dateString) {
                        return date
                    }
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "无法解析日期字符串: \(dateString)")
                }

                return try decoder.decode(T.self, from: data)
            } catch {
                #if DEBUG
                    print("解码错误: \(error)")
                    if let json = String(data: data, encoding: .utf8) {
                        print("原始JSON: \(json)")
                    }
                #endif
                throw NetworkError.decodingError(error)
            }
        case 401:
            throw NetworkError.unauthorized
        case 400 ... 499:
            throw NetworkError.clientError(try? decodeErrorResponse(from: data))
        case 500 ... 599:
            throw NetworkError.serverError
        default:
            throw NetworkError.httpError(httpResponse.statusCode)
        }
    }

  /// 新增方法：发送请求但不对响应内容进行解码，用于图片上传等返回数据格式不确定的接口
   func sendRequestWithoutDecoding(_ endpoint: APIEndpoint) async throws {
       var attempts = 0

       while attempts < maxRetries {
           do {
               try await performRequestWithoutDecoding(endpoint)
               return
           } catch NetworkError.serverError {
               attempts += 1
               if attempts == maxRetries {
                   throw NetworkError.maxRetriesExceeded
               }
               try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempts))) * 1_000_000_000)
           }
       }

       throw NetworkError.maxRetriesExceeded
   }

   /// 执行实际网络请求但不进行数据解码
   private func performRequestWithoutDecoding(_ endpoint: APIEndpoint) async throws {
       var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path),
                                      resolvingAgainstBaseURL: true)
       components?.queryItems = endpoint.queryItems

       guard let url = components?.url else {
           throw NetworkError.invalidURL
       }

       var request = URLRequest(url: url)
       request.httpMethod = endpoint.method.rawValue
       request.httpBody = endpoint.body
       request.cachePolicy = .reloadIgnoringLocalCacheData
        
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return  // 成功，不解析返回数据
        case 401:
            throw NetworkError.unauthorized
        case 400...499:
            throw NetworkError.clientError(try? decodeErrorResponse(from: data))
        case 500...599:
            throw NetworkError.serverError
        default:
            throw NetworkError.httpError(httpResponse.statusCode)
        }
   }
  
  
    #if DEBUG
        private func logRequest(_ request: URLRequest) {
            print("🚀 发送请求: \(request.httpMethod ?? "Unknown") \(request.url?.absoluteString ?? "")")
            if let headers = request.allHTTPHeaders {
                print("📋 Headers: \(headers)")
            }
            if let body = request.httpBody,
               let json = String(data: body, encoding: .utf8)
            {
                print("📦 Body: \(json)")
            }
        }

        private func logResponse(_ response: URLResponse, data: Data) {
            guard let httpResponse = response as? HTTPURLResponse else { return }
            print("📥 收到响应: \(httpResponse.statusCode)")
            if let json = String(data: data, encoding: .utf8) {
                print("📄 Response: \(json)")
            }
        }
    #endif

    private func decodeErrorResponse(from data: Data) throws -> APIError {
        return try JSONDecoder().decode(APIError.self, from: data)
    }
}

// 扩展 URLRequest 以方便访问所有 headers
private extension URLRequest {
    var allHTTPHeaders: [String: String]? {
        return allHTTPHeaderFields
    }
}

// API 错误响应模型
struct APIError: Codable {
    let message: String
    let code: String?
}


// MARK: - Core/Network/Base/APIEndpoint.swift

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


// MARK: - Core/Network/Base/HTTPMethod.swift

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

// MARK: - Core/Network/Base/NetworkError.swift

import Foundation

// 删除旧的定义，使用统一的 NetworkError
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    case serverError
    case clientError(APIError?)
    case unauthorized
    case noData
    case maxRetriesExceeded
    case noToken
    case custom(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .invalidResponse:
            return "无效的响应"
        case .httpError(let code):
            return "HTTP错误: \(code)"
        case .decodingError(let error):
            return "数据解析错误: \(error.localizedDescription)"
        case .serverError:
            return "服务器错误"
        case .clientError(let apiError):
            return apiError?.message ?? "客户端错误"
        case .unauthorized:
            return "未授权访问"
        case .noData:
            return "没有数据"
        case .maxRetriesExceeded:
            return "超过最大重试次数"
        case .noToken:
            return "未找到访问令牌"
        case .custom(let message):
            return message
        }
    }
}

// MARK: - Core/Network/Base/ProfileEndpoint.swift

//
//  ProfileEndpoint.swift
//  CloneTwitter
//
//  Created by 潘令川 on 2025/2/6.
//

import Foundation


enum ProfileEndpoint: APIEndpoint {
    case fetchUserProfile(userId: String)
    case updateProfile(data: [String: Any])
    case fetchUserTweets(userId: String)
    case uploadAvatar(imageData: Data)
    case uploadBanner(imageData: Data)
    
    var path: String {
        switch self {
        case .fetchUserProfile(let userId):
            return "/users/\(userId)"
        case .updateProfile:
            return "/users/me"
        case .fetchUserTweets(let userId):
            return "/tweets/user/\(userId)"
        case .uploadAvatar:
            return "/users/me/avatar"
        case .uploadBanner:
            return "/users/me/banner"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchUserProfile, .fetchUserTweets:
            return .get
        case .updateProfile:
            return .patch
        case .uploadAvatar, .uploadBanner:
            return .post
        }
    }
    
    var body: Data? {
        switch self {
        case .updateProfile(let data):
            return try? JSONSerialization.data(withJSONObject: data)
        case .uploadAvatar(let imageData), .uploadBanner(let imageData):
            return imageData
        default:
            return nil
        }
    }
    
    var headers: [String: String]? {
        var headers = ["Content-Type": "application/json"]
        
        switch self {
        case .uploadAvatar, .uploadBanner:
            headers["Content-Type"] = "image/jpeg"
        default: break
        }
        
        if let token = UserDefaults.standard.string(forKey: "jwt") {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return headers
    }
    
    var queryItems: [URLQueryItem]? {
        return nil
    }
}


// MARK: - Core/Network/Config/APIConfig.swift

import Foundation

enum APIConfig {
    static let baseURL = URL(string: "http://localhost:3000")!
    
    enum Path {
        static let login = "/users/login"
        static let register = "/users"
        static let tweets = "/tweets"
        static let users = "/users"
    }
}

// MARK: - Core/Network/Config/NetworkMonitor.swift



// MARK: - Core/Storage/Keychain/KeychainStore.swift



// MARK: - Core/Storage/UserDefaults/UserDefaultsStore.swift



// MARK: - Features/Auth/Models/User.swift

import Foundation

struct User: Codable, Identifiable, Hashable {
    // 对应MongoDB的_id
    let id: String
    var username: String
    var name: String
    var email: String

    // 可选字段
    var location: String?
    var bio: String?
    var website: String?
    var avatarExists: Bool?

    // 关注关系
    var followers: [String]
    var following: [String]
    var isFollowed: Bool = false
    // CodingKeys用于处理MongoDB的_id映射
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case username, name, email
        case location, bio, website
        case avatarExists
        case followers, following
    }

    init(id: String = UUID().uuidString,
         username: String,
         name: String,
         email: String,
         location: String? = nil,
         bio: String? = nil,
         website: String? = nil,
         avatarExists: Bool? = false,
         followers: [String] = [],
         following: [String] = [])
    {
        self.id = id
        self.username = username
        self.name = name
        self.email = email
        self.location = location
        self.bio = bio
        self.website = website
        self.avatarExists = avatarExists
        self.followers = followers
        self.following = following
    }

    // 添加以下内容实现 Hashable（编译器会自动合成）
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(username)
        hasher.combine(email)
    }

    // 可选：实现 == 运算符（编译器也会自动合成）
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id &&
            lhs.username == rhs.username &&
            lhs.email == rhs.email
    }

       // 自定义解码，缺失字段使用默认值
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.username = try container.decode(String.self, forKey: .username)
        self.name = try container.decode(String.self, forKey: .name)
        self.email = try container.decode(String.self, forKey: .email)
        self.location = try container.decodeIfPresent(String.self, forKey: .location)
        self.bio = try container.decodeIfPresent(String.self, forKey: .bio)
        self.website = try container.decodeIfPresent(String.self, forKey: .website)
        self.avatarExists = try container.decodeIfPresent(Bool.self, forKey: .avatarExists)
        self.followers = try container.decodeIfPresent([String].self, forKey: .followers) ?? []
        self.following = try container.decodeIfPresent([String].self, forKey: .following) ?? []
        self.isFollowed = false
    }
    
    // 编码方法（若需要将 User 编码为 JSON，可保留此方法）
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(username, forKey: .username)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encodeIfPresent(location, forKey: .location)
        try container.encodeIfPresent(bio, forKey: .bio)
        try container.encodeIfPresent(website, forKey: .website)
        try container.encodeIfPresent(avatarExists, forKey: .avatarExists)
        try container.encode(followers, forKey: .followers)
        try container.encode(following, forKey: .following)
    }
    
    

    
}


// MARK: - Features/Auth/Services/authService.swift


import Foundation

protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> APIResponse
    func register(email: String, username: String, password: String, name: String) async throws -> User
    func fetchCurrentUser() async throws -> User
    func updateProfile(data: [String: Any]) async throws -> User
}

// 定义登录响应模型
struct APIResponse: Codable {
    let user: User
    let token: String
}

import Foundation

final class AuthService1: AuthServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func login(email: String, password: String) async throws -> APIResponse {
        let endpoint = AuthEndpoint.login(email: email, password: password)
        let response: APIResponse = try await apiClient.sendRequest(endpoint)

        // 保存 token
        UserDefaults.standard.set(response.token, forKey: "jwt")

        return response
    }

    func register(email: String, username: String, password: String, name: String) async throws -> User {
        let endpoint = AuthEndpoint.register(
            email: email,
            username: username,
            password: password,
            name: name
        )
        return try await apiClient.sendRequest(endpoint)
    }

    func fetchCurrentUser() async throws -> User {
        let endpoint = AuthEndpoint.fetchCurrentUser
        return try await apiClient.sendRequest(endpoint)
    }

    func updateProfile(data: [String: Any]) async throws -> User {
        let endpoint = AuthEndpoint.updateProfile(data: data)
        return try await apiClient.sendRequest(endpoint)
    }
}

// MARK: - Mock 实现，用于测试

#if DEBUG
    final class MockAuthService: AuthServiceProtocol {
        var shouldSucceed = true

        func login(email _: String, password _: String) async throws -> APIResponse {
            if shouldSucceed {
                return APIResponse(
                    user: User.mock,
                    token: "mock_token"
                )
            } else {
                throw NetworkError.unauthorized
            }
        }

        func register(email _: String, username _: String, password _: String, name _: String) async throws -> User {
            if shouldSucceed {
                return User.mock
            } else {
                throw NetworkError.clientError(APIError(message: "Registration failed", code: "400"))
            }
        }

        func fetchCurrentUser() async throws -> User {
            if shouldSucceed {
                return User.mock
            } else {
                throw NetworkError.unauthorized
            }
        }

        func updateProfile(data _: [String: Any]) async throws -> User {
            if shouldSucceed {
                return User.mock
            } else {
                throw NetworkError.unauthorized
            }
        }
    }

   extension User {
        static var mock: User {
            User(
                id: "mock_id",
                username: "mock_user",
                name: "Mock User",
                email: "mock@example.com",
                bio: nil
            )
        }
    }
#endif


// MARK: - Features/Auth/ViewModels/AuthState.swift

//
//  AuthState.swift
//  CloneTwitter
//
//  Created by 潘令川 on 2025/2/5.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class AuthState: ObservableObject {
    private let authService: AuthServiceProtocol
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
        
        // 订阅更新用户的通知
        NotificationCenter.default.publisher(for: .didUpdateProfile)
            .compactMap { $0.object as? User }
            .sink { [weak self] updatedUser in
                print("AuthState 收到更新通知，更新 currentUser")
                self?.currentUser = updatedUser
            }
            .store(in: &cancellables)
        
        Task {
            await checkAuthStatus()
        }
    }
    
    // MARK: - Public Methods
    
    func login(email: String, password: String) async {
        await performAction {
            let response = try await self.authService.login(email: email, password: password)
            self.currentUser = response.user
            self.isAuthenticated = true
        }
    }
    
    func register(email: String, username: String, password: String, name: String) async {
        await performAction {
            let user = try await self.authService.register(
                email: email,
                username: username,
                password: password,
                name: name
            )
            self.currentUser = user
            self.isAuthenticated = true
        }
    }
    
    func signOut() {
        UserDefaults.standard.removeObject(forKey: "jwt")
        currentUser = nil
        isAuthenticated = false
    }
    
    func updateProfile(data: [String: Any]) async {
        await performAction {
            let updatedUser = try await self.authService.updateProfile(data: data)
            self.currentUser = updatedUser
            // 此处也可以发布通知，不过后续 ProfileViewModel 会发布，这里只更新全局状态
        }
    }
    
    // MARK: - Private Methods
    
    private func checkAuthStatus() async {
        guard UserDefaults.standard.string(forKey: "jwt") != nil else {
            isAuthenticated = false
            return
        }
        
        await performAction {
            let user = try await self.authService.fetchCurrentUser()
            self.currentUser = user
            self.isAuthenticated = true
        }
    }
    
    private func performAction(_ action: @escaping () async throws -> Void) async {
        isLoading = true
        error = nil
        
        do {
            try await action()
        } catch let networkError as NetworkError {
            error = networkError.errorDescription
            if case .unauthorized = networkError {
                signOut()
            }
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
}

#if DEBUG
extension AuthState {
    static var preview: AuthState {
        AuthState(authService: MockAuthService())
    }
}
#endif


// MARK: - Features/Auth/ViewModels/AuthViewModel.swift

// import Foundation
// import SwiftUI

// class AuthViewModel: ObservableObject {
//     // 添加静态共享实例
//     static let shared = AuthViewModel()

//     @Published var isAuthenticated: Bool = false
//     @Published var user: User?
//     @Published var error: Error?

//     // 用于存储用户凭证
//     @AppStorage("jwt") var token: String = ""
//     @AppStorage("userId") var userId: String = ""

//     // 将 init() 改为私有,确保只能通过 shared 访问
//     private init() {
//         // 初始化时检查认证状态
//         checkAuthStatus()
//     }

//     private func checkAuthStatus() {
//         // 如果有token和userId,尝试获取用户信息
//         if !token.isEmpty && !userId.isEmpty {
//             fetchUser()
//         }
//     }

//    // 在 AuthViewModel 的 login 方法中
// func login(email: String, password: String) {
//     AuthService.login(email: email, password: password) { [weak self] result in
//         DispatchQueue.main.async {
//             switch result {
//             case let .success(response):
//                 // 保存 token 和 userId (如果 token 为 nil，则赋值为空字符串)
//                 self?.token = response.token ?? ""
//                 self?.userId = response.user.id
//                 // 保存用户信息
//                 self?.user = response.user
//                 // 更新认证状态
//                 self?.isAuthenticated = true
//                 print("Logged in successfully")

//             case let .failure(error):
//                 // 处理错误
//                 self?.error = error
//                 print("Login error: \(error)")
//             }
//         }
//     }
// }

//     // 注册方法
//    func register(name: String, username: String, email: String, password: String) async throws {
//      try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
//         AuthService.register(
//             email: email,
//             username: username,
//             password: password,
//             name: name
//         ) { [weak self] result in
//             guard let self = self else {
//                 continuation.resume(throwing: AuthService.AuthenticationError.custom("Self is nil"))
//                 return
//             }
            
//             switch result {
//             case let .success(user):
//                 // 更新用户信息（此时还没有 token, 所以接下来调用 login 获取 token）
//                 DispatchQueue.main.async {
//                     self.user = user
//                     // 进行登录来获取 token
//                     self.login(email: email, password: password)
//                     continuation.resume()
//                 }
                
//             case let .failure(error):
//                 DispatchQueue.main.async {
//                     self.error = error
//                     continuation.resume(throwing: error)
//                 }
//             }
//         }
//     }
// }

//     // 登出方法
//     func signOut() {
//         // 清除用户数据和token
//         isAuthenticated = false
//         user = nil
//         token = ""
//         userId = ""
//     }

//     // 验证token是否有效
//     func validateToken() {
//         // TODO: 实现token验证
//     }

//     private func fetchUser() {
//         guard !token.isEmpty && !userId.isEmpty else { return }

//         AuthService.fetchUser(userId: userId, token: token) { [weak self] result in
//             DispatchQueue.main.async {
//                 switch result {
//                 case let .success(user): // 直接使用返回的 user 对象
//                     self?.user = user
//                     self?.isAuthenticated = true
//                 case let .failure(error):
//                     self?.error = error
//                     self?.signOut() // 如果获取用户信息失败,清除认证状态
//                 }
//             }
//         }
//     }

//     // 添加更新用户方法
//     func updateUser(_ updatedUser: User) {
//         DispatchQueue.main.async {
//             self.user = updatedUser
//             // 可以在这里添加持久化逻辑
//         }
//     }

//     // 修改更新方法,添加 transaction 支持
//     func updateCurrentUser(_ updatedUser: User, transaction: Transaction = .init()) {
//         withTransaction(transaction) {
//             // 只更新 following/followers 相关数据
//             if let currentUser = self.user {
//                 var newUser = currentUser
//                 newUser.following = updatedUser.following
//                 newUser.followers = updatedUser.followers
//                 self.user = newUser
//             }
//         }
//     }

//     // 添加静默更新方法
//     func silentlyUpdateFollowing(_ following: [String]) {
//         if var currentUser = user {
//             currentUser.following = following
//             // 直接更新，不触发 objectWillChange
//             user = currentUser
//         }
//     }
// }


// MARK: - Features/Auth/Views/AuthenticationView.swift

import SwiftUI

struct AuthenticationView: View {
    var body: some View {
        Text("Authentication")
    }
}

#Preview {
    AuthenticationView()
} 

// MARK: - Features/Auth/Views/CustomAuthTextField.swift

import SwiftUI

struct CustomAuthTextField: View {
    let placeholder: String
    @Binding var text: String
    let keyboardType: UIKeyboardType

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField("", text: $text)
                .placeholder(when: text.isEmpty) {
                    Text(placeholder)
                        .foregroundColor(.gray)
                }
                .keyboardType(keyboardType)
                .frame(height: 45)

            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(.horizontal, 20)
    }
}

// 添加TextField的placeholder扩展
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}


// MARK: - Features/Auth/Views/LoginView.swift

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var emailDone = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    @ObserveInjection var inject
    @EnvironmentObject private var authState: AuthState

    var body: some View {
        VStack(spacing: 0) {
            // Header
            ZStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                            .foregroundColor(Color("BG"))
                    }
                    Spacer()
                }

                Image("X")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            .padding(.horizontal)

            if !emailDone {
                // Email Input View
                Text("Enter your email, phone number or username")
                    .font(.title2)
                    .fontWeight(.heavy)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 40)

                CustomAuthTextField(
                    placeholder: "Phone, email, or username",
                    text: $email,
                    keyboardType: .emailAddress
                )
                .padding(.top, 30)

                Spacer()

                // Bottom Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        if !email.isEmpty {
                            emailDone.toggle()
                        }
                    }) {
                        Text("Next")
                            .foregroundColor(.white)
                            .font(.title3)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(email.isEmpty ? Color.gray : Color("BG"))
                            .clipShape(Capsule())
                    }
                    .disabled(email.isEmpty)
                    .padding(.horizontal)

                    Button("Forgot Password?") {
                        // 后续添加忘记密码功能
                    }
                    .foregroundColor(Color("BG"))
                }
                .padding(.bottom, 30)
            } else {
                // Password Input View
                Text("Enter your password")
                    .font(.title2)
                    .fontWeight(.heavy)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 40)

                SecureAuthTextField(
                    placeholder: "Password",
                    text: $password
                )
                .padding(.top, 30)
                .disabled(authState.isLoading)

                Spacer()

                VStack(spacing: 12) {
                    // Login Button
                    Button(action: {
                        Task {
                            await authState.login(email: email, password: password)
                            
                            if authState.isAuthenticated {
                                // 延迟2秒后关闭页面
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    dismiss()
                                }
                            }
                        }
                    }) {
                        HStack {
                            if authState.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 8)
                            }

                            Text(authState.isLoading ? "登录中..." : "Log in")
                                .foregroundColor(.white)
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            password.isEmpty || authState.isLoading
                                ? Color.gray
                                : Color("BG")
                        )
                        .clipShape(Capsule())
                    }
                    .disabled(password.isEmpty || authState.isLoading)
                    .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
        }
        .toolbar(.hidden)
        .enableInjection()
        .disabled(authState.isLoading)
        .animation(.easeInOut, value: authState.isLoading)
        .alert("登录失败", isPresented: .init(
            get: { authState.error != nil },
            set: { if !$0 { authState.error = nil } }
        )) {
            Button("确定", role: .cancel) {
                authState.error = nil
            }
        } message: {
            Text(authState.error ?? "未知错误")
        }
    }
}


// MARK: - Features/Auth/Views/RegisterView.swift

import SwiftUI 

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @ObserveInjection var inject
    @EnvironmentObject private var authState: AuthState
    @State private var showSuccessOverlay = false  // 添加这一行
    var body: some View {

        ZStack{
        
            
        
        VStack(spacing: 0) {
            // Header
            ZStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .foregroundColor(Color("BG"))
                    }
                    Spacer()
                }
                Image("X")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            .padding(.horizontal)
            
            Text("Create your account")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            // Form Fields
            CustomAuthTextField(
                placeholder: "Name",
                text: $name,
                keyboardType: .default
            )
            .disabled(authState.isLoading)
            
            CustomAuthTextField(
                placeholder: "Username",
                text: $username,
                keyboardType: .default
            )
            .disabled(authState.isLoading)
            
            CustomAuthTextField(
                placeholder: "Email",
                text: $email,
                keyboardType: .emailAddress
            )
            .disabled(authState.isLoading)
            
            SecureAuthTextField(
                placeholder: "Password",
                text: $password
            )
            .disabled(authState.isLoading)
            
            Spacer()
            
            // Register Button
            Button(action: {
                Task {
                    await authState.register(
                        email: email,
                        username: username,
                        password: password,
                        name: name
                    )
                    
                    if authState.isAuthenticated {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            dismiss()
                        }
                    }
                }
            }) {
                HStack {
                    if authState.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing, 8)
                    }
                    
                    Text(authState.isLoading ? "注册中..." : "注册")
                        .foregroundColor(.white)
                        .font(.title3)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    isFormValid && !authState.isLoading
                        ? Color("BG")
                        : Color.gray
                )
                .clipShape(Capsule())
            }
            .disabled(!isFormValid || authState.isLoading)
            .padding(.horizontal)
            .padding(.bottom, 48)
        }
        .toolbar(.hidden)
        .enableInjection()
        .disabled(authState.isLoading)
        .animation(.easeInOut, value: authState.isLoading)
        .alert("注册失败", isPresented: .init(
            get: { authState.error != nil },
            set: { if !$0 { authState.error = nil } }
        )) {
            Button("确定", role: .cancel) {
                authState.error = nil
            }
        } message: {
            Text(authState.error ?? "未知错误")
        }
        
    // 成功提示覆盖层
            if showSuccessOverlay {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.green)
                    
                    Text("注册成功！")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .transition(.scale.combined(with: .opacity))
            }

    }
    }
    // 表单验证
    private var isFormValid: Bool {
        !name.isEmpty && 
        !username.isEmpty && 
        !email.isEmpty && 
        !password.isEmpty &&
        email.contains("@") &&
        password.count >= 6
    }
}


// MARK: - Features/Auth/Views/SecureAuthTextField.swift

import SwiftUI

struct SecureAuthTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            SecureField("", text: $text)
                .placeholder(when: text.isEmpty) {
                    Text(placeholder)
                        .foregroundColor(.gray)
                }
                .frame(height: 45)

            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(.horizontal, 20)
    }
}


// MARK: - Features/Auth/Views/WelcomeView.swift

import SwiftUI

struct WelcomeView: View {
   

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Top Logo Area
                    HStack {
                        Spacer()
                        Image("X")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                        Spacer()
                    }
                    .padding(.top, 60)
                    Spacer()

                    // Main Title
                    Text("See what's happening in the world right now.")
                        .font(.system(size: 30, weight: .black))
                        .padding(.top, 40)
                        .padding(.horizontal, 20)

                    Spacer()

                    // Buttons Area
                    VStack(spacing: 16) {
                        // Google Sign In Button
                        Button(action: {}) {
                            HStack {
                                Image("GoogleLogo")
                                    .resizable()
                                    .frame(width: 24, height: 24)

                                Text("Continue with Google")
                                    .font(.title3)
                            }
                            .frame(width: geometry.size.width * 0.8, height: 52)
                        }

                        .background(Color.white)
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(Color.gray.opacity(0.6), lineWidth: 3)
                        )

                        .foregroundColor(.black)
                        .clipShape(Capsule(style: .continuous))

                        // Apple Sign In Button
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "applelogo")
                                Text("Continue with Apple")
                                    .font(.title3)
                            }
                            .frame(width: geometry.size.width * 0.8, height: 52)
                        }
                        .background(Color.white)
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(Color.gray.opacity(0.6), lineWidth: 3)
                        )
                        .foregroundColor(.black)
                        .clipShape(Capsule(style: .continuous))

                        // Divider
                        ZStack {
                            Divider()
                                .frame(width: geometry.size.width * 0.8)
                            Text("Or")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                                .background {
                                    Color.white
                                        .frame(width: 25, height: 1)
                                }
                        }
                        .padding(.horizontal, 20)

                        // Create Account Button
                        NavigationLink {
                            RegisterView()
                        } label: {
                            Text("Create account")
                                .foregroundColor(.white)
                                .font(.title3)
                                .fontWeight(.medium)
                                .frame(width: geometry.size.width * 0.8, height: 52)
                        }
                        .background(Color("BG"))
                        .clipShape(Capsule(style: .continuous))
                    }

                    Spacer()

                    // Bottom Disclaimer
                    VStack(spacing: 4) {
                        Group {
                            Text("By signing up, you agree to our ")
                                .foregroundColor(.gray) +
                                Text("Terms")
                                .foregroundColor(Color("BG"))
                                .fontWeight(.bold) +
                                Text(", ")
                                .foregroundColor(.gray) +
                                Text("Privacy Policy")
                                .foregroundColor(Color("BG"))
                                .fontWeight(.bold) +
                                Text(", and ")
                                .foregroundColor(.gray) +
                                Text("Cookie Use")
                                .foregroundColor(Color("BG"))
                                .fontWeight(.bold)
                        }
                        .font(.caption)
                        .multilineTextAlignment(.leading)

                        HStack(spacing: 4) {
                            Text("Have an account already?")
                                .foregroundColor(.gray)
                            NavigationLink {
                                LoginView()
                            } label: {
                                Text("Log in")
                                    .foregroundColor(Color("BG"))
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    .font(.caption)
                    .padding(.bottom, 48)
                }

                .frame(width: geometry.size.width)
            }
        }
        .toolbar(.hidden)
     
        .ignoresSafeArea()
    }
}

#Preview {
    WelcomeView()
}


// MARK: - Features/Feed/Models/Tweet.swift

import Foundation

struct Tweet: Identifiable, Decodable, Equatable {
    // MongoDB 的 _id 字段
    let _id: String
    let text: String
    let userId: String
    /// 用户昵称，如为空则显示默认值
    let username: String
    /// 用户真实姓名，如为空则显示默认值
    let user: String

    // 可选字段，后续预留扩展（例如是否带图片）
    var image: Bool?
    /// 点赞列表：存储点赞的用户 id 数组
    var likes: [String]?

    // 满足 Identifiable 协议
    var id: String {
        _id
    }

    enum CodingKeys: String, CodingKey {
        case _id, text, userId, username, user, image, likes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        _id = try container.decode(String.self, forKey: ._id)
        text = try container.decode(String.self, forKey: .text)
        
        // 如果 userId 是嵌套对象，则解析其中的用户信息
        if let userInfo = try? container.decode([String: String].self, forKey: .userId) {
            userId = userInfo["_id"] ?? ""
            user = userInfo["name"] ?? ""
            username = userInfo["username"] ?? ""
        } else {
            // 否则直接解码，并对 user 与 username 采用 decodeIfPresent，若缺失则提供默认值
            userId = try container.decode(String.self, forKey: .userId)
            user = try container.decodeIfPresent(String.self, forKey: .user) ?? ""
            username = try container.decodeIfPresent(String.self, forKey: .username) ?? ""
        }
        
        image = try? container.decode(Bool.self, forKey: .image)
        likes = try? container.decode([String].self, forKey: .likes)
    }
}

// MARK: - Features/Feed/Services/TweetService.swift

//
//  TweetService.swift
//  CloneTwitter
//
//  Created by 潘令川 on 2025/2/5.
//
import Foundation

struct ImageUploadResponse: Codable {
    let message: String
}





import Foundation
import UIKit

protocol TweetServiceProtocol {
    
  func fetchTweets() async throws -> [Tweet]
  func createTweet(text: String, userId: String) async throws -> Tweet
  func likeTweet(tweetId: String) async throws -> Tweet
  func unlikeTweet(tweetId: String) async throws -> Tweet
  func uploadImage(tweetId: String, image: UIImage) async throws -> ImageUploadResponse

}

final class TweetService: TweetServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchTweets() async throws -> [Tweet] {
        let endpoint = TweetEndpoint.fetchTweets
        return try await apiClient.sendRequest(endpoint)
    }

    func createTweet(text: String, userId: String) async throws -> Tweet {
        let endpoint = TweetEndpoint.createTweet(text: text, userId: userId)
        return try await apiClient.sendRequest(endpoint)
    }

    func likeTweet(tweetId: String) async throws -> Tweet {
        let endpoint = TweetEndpoint.likeTweet(tweetId: tweetId)
        return try await apiClient.sendRequest(endpoint)
    }

    func unlikeTweet(tweetId: String) async throws -> Tweet {
        let endpoint = TweetEndpoint.unlikeTweet(tweetId: tweetId)
        return try await apiClient.sendRequest(endpoint)
    }

    func uploadImage(tweetId: String, image: UIImage) async throws -> ImageUploadResponse {
        return try await withCheckedThrowingContinuation { continuation in
            ImageUploader.uploadImage(
                paramName: "image",
                fileName: "tweet.jpg",
                image: image,
                urlPath: "/tweets/\(tweetId)/image"
            ) { result in
                switch result {
                case .success(let response):
                    if let data = try? JSONSerialization.data(withJSONObject: response),
                       let uploadResponse = try? JSONDecoder().decode(ImageUploadResponse.self, from: data) {
                        continuation.resume(returning: uploadResponse)
                    } else {
                        continuation.resume(throwing: NetworkError.decodingError(NSError(domain: "", code: -1)))
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

#if DEBUG
    final class MockTweetService: TweetServiceProtocol {
        var shouldSucceed = true

        func fetchTweets() async throws -> [Tweet] {
            if shouldSucceed {
                return [.mock, .mock]
            } else {
                throw NetworkError.serverError
            }
        }

        func createTweet(text _: String, userId _: String) async throws -> Tweet {
            if shouldSucceed {
                return .mock
            } else {
                throw NetworkError.serverError
            }
        }

        func likeTweet(tweetId _: String) async throws -> Tweet {
            if shouldSucceed {
                return .mock
            } else {
                throw NetworkError.serverError
            }
        }

        func unlikeTweet(tweetId _: String) async throws -> Tweet {
            if shouldSucceed {
                return .mock
            } else {
                throw NetworkError.serverError
            }
        }

      func uploadImage(tweetId _: String, image _: UIImage) async throws -> ImageUploadResponse {
          if shouldSucceed {
              return ImageUploadResponse(message: "Tweet image uploaded successfully")
          } else {
              throw NetworkError.serverError
          }
      }
    }

    // Mock 实现修正

#if DEBUG
extension Tweet {
    static var mock: Tweet {
        let json = """
        {
            "_id": "mock_id",
            "text": "This is a mock tweet",
            "userId": "mock_user_id",
            "username": "mock_username",
            "user": "Mock User"
        }
        """.data(using: .utf8)!
        
        return try! JSONDecoder().decode(Tweet.self, from: json)
    }
}
#endif
#endif


// MARK: - Features/Feed/ViewModels/CreateTweetViewModel.swift


import SwiftUI 

@MainActor
final class CreateTweetViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: Error?
    
    private let tweetService: TweetServiceProtocol
    
    init(tweetService: TweetServiceProtocol) {
        self.tweetService = tweetService
    }
    
    func createTweet(text: String, image: UIImage? = nil, currentUser: User?) async {
        guard let user = currentUser else {
            error = NetworkError.custom("未登录用户")
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            let tweet = try await tweetService.createTweet(
                text: text,
                userId: user.id
            )
            
            if let image = image {
                try await tweetService.uploadImage(
                    tweetId: tweet.id,
                    image: image
                )
            }
            
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
            print("发送推文失败: \(error)")
        }
    }
}

#if DEBUG
extension CreateTweetViewModel {
    static var preview: CreateTweetViewModel {
        CreateTweetViewModel(tweetService: MockTweetService())
    }
}
#endif

// MARK: - Features/Feed/ViewModels/FeedViewModel.swift



import SwiftUI
import Combine

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var tweets: [Tweet] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let tweetService: TweetServiceProtocol
    private var refreshTask: Task<Void, Never>?
    
    init(tweetService: TweetServiceProtocol) {
        self.tweetService = tweetService
    }
    
    func fetchTweets() {
        isLoading = true
        error = nil
        
        refreshTask?.cancel()
        refreshTask = Task {
            do {
                tweets = try await tweetService.fetchTweets()
            } catch {
                self.error = error
                print("获取推文失败: \(error)")
            }
            isLoading = false
        }
    }
    
    // 提供一个更新单个推文的方法，供 TweetCellViewModel 调用
    func updateTweet(_ updatedTweet: Tweet) {
        if let index = tweets.firstIndex(where: { $0.id == updatedTweet.id }) {
            tweets[index] = updatedTweet
        }
    }
}

// MARK: - Features/Feed/ViewModels/TweetCellViewModel.swift

import SwiftUI

@MainActor
final class TweetCellViewModel: ObservableObject {
    @Published var tweet: Tweet
    @Published var isLikeActionLoading: Bool = false
    @Published var error: Error?
    
    private let tweetService: TweetServiceProtocol
    private let notificationService: NotificationServiceProtocol
    private let currentUserId: String
    private let onTweetUpdated: ((Tweet) -> Void)?
    
    init(
        tweet: Tweet,
        tweetService: TweetServiceProtocol,
        notificationService: NotificationServiceProtocol,
        currentUserId: String,
        onTweetUpdated: ((Tweet) -> Void)? = nil
    ) {
        self.tweet = tweet
        self.tweetService = tweetService
        self.notificationService = notificationService
        self.currentUserId = currentUserId
        self.onTweetUpdated = onTweetUpdated
    }
    
    /// 判断当前用户是否已点赞
    var isLiked: Bool {
        tweet.likes?.contains(currentUserId) ?? false
    }
    
    /// 点赞数量
    var likesCount: Int {
        tweet.likes?.count ?? 0
    }
    
    /// 点赞操作（乐观更新）
    func likeTweet() {
        guard !isLikeActionLoading else { return }
        if isLiked {
            unlikeTweet()
            return
        }
        
        // 乐观更新：先在本地添加当前用户
        if tweet.likes == nil {
            tweet.likes = [currentUserId]
        } else if !(tweet.likes!.contains(currentUserId)) {
            tweet.likes!.append(currentUserId)
        }
        
        isLikeActionLoading = true
        
        Task {
            do {
                let updatedTweet = try await tweetService.likeTweet(tweetId: tweet.id)
                self.tweet = updatedTweet
                onTweetUpdated?(updatedTweet)
                // 同时发送通知（如需要）
                try await notificationService.createNotification(
                    username: tweet.username,
                    receiverId: tweet.userId,
                    type: .like,
                    postText: tweet.text
                )
            } catch {
                // 回滚本地状态
                if var likes = tweet.likes {
                    likes.removeAll { $0 == currentUserId }
                    tweet.likes = likes
                }
                self.error = error
            }
            isLikeActionLoading = false
        }
    }
    
    /// 取消点赞操作（乐观更新）
    func unlikeTweet() {
        guard !isLikeActionLoading else { return }
        if var likes = tweet.likes {
            likes.removeAll { $0 == currentUserId }
            tweet.likes = likes
        }
        isLikeActionLoading = true
        
        Task {
            do {
                let updatedTweet = try await tweetService.unlikeTweet(tweetId: tweet.id)
                self.tweet = updatedTweet
                onTweetUpdated?(updatedTweet)
            } catch {
                // 回滚：将当前用户重新加回去
                if tweet.likes == nil {
                    tweet.likes = [currentUserId]
                } else if !(tweet.likes!.contains(currentUserId)) {
                    tweet.likes!.append(currentUserId)
                }
                self.error = error
            }
            isLikeActionLoading = false
        }
    }
    
    /// 根据传入的全局 AuthState 生成头像 URL（带时间戳以避免缓存问题）
    func getUserAvatarURL(from authState: AuthState) -> URL? {
        // 如果当前 tweet 用户与全局 currentUser 相同，则附加时间戳
        if authState.currentUser?.id == tweet.userId {
            let timestamp = Int(Date().timeIntervalSince1970)
            return URL(string: "http://localhost:3000/users/\(tweet.userId)/avatar?t=\(timestamp)")
        } else {
            return URL(string: "http://localhost:3000/users/\(tweet.userId)/avatar")
        }
    }
}

// MARK: - Features/Feed/Views/CreateTweetView.swift

import SwiftUI

struct CreateTweetView: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss
    @Environment(\.diContainer) private var container
    @EnvironmentObject private var authState: AuthState
    
    @State private var tweetText: String = ""
    @State private var imagePickerPresented = false
    @State private var selectedImage: UIImage?
    @State private var postImage: Image?
    @State private var width = UIScreen.main.bounds.width
    
    // Move viewModel to a computed property
    @StateObject private var viewModel: CreateTweetViewModel = {
        let container = DIContainer.defaultContainer()
        let tweetService: TweetServiceProtocol = container.resolve(.tweetService) ?? 
            TweetService(apiClient: APIClient(baseURL: APIConfig.baseURL))
        return CreateTweetViewModel(tweetService: tweetService)
    }()
    
    init() {
        let tweetService: TweetServiceProtocol = container.resolve(.tweetService) ?? 
            TweetService(apiClient: APIClient(baseURL: APIConfig.baseURL))
        _viewModel = StateObject(wrappedValue: CreateTweetViewModel(
            tweetService: tweetService
        ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部操作栏
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    guard !tweetText.isEmpty else { return }
                    Task {
                        await viewModel.createTweet(
                            text: tweetText,
                            image: selectedImage,
                            currentUser: authState.currentUser
                        )
                        dismiss()
                    }
                }) {
                    Text("Tweet")
                }
                .buttonStyle(.borderedProminent)
                .cornerRadius(40)
                .disabled(tweetText.isEmpty || viewModel.isLoading)
            }
            .padding()
            
            MultilineTextField(text: $tweetText, placeholder: "有什么新鲜事？")
                .padding(.horizontal)
            
            // 图片预览
            if let image = postImage {
                VStack {
                    HStack(alignment: .top) {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: width * 0.9)
                            .cornerRadius(10)
                            .clipped()
                            .padding(.horizontal)
                    }
                    Spacer()
                }
            }
            
            Spacer()
            
            // 底部工具栏
            HStack(spacing: 20) {
                Button(action: {
                    imagePickerPresented.toggle()
                }) {
                    Image(systemName: "photo")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
                .disabled(viewModel.isLoading)
                
                Spacer()
                
                Text("\(tweetText.count)/280")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .alert("发送失败", isPresented: .constant(viewModel.error != nil)) {
            Button("确定") {
                viewModel.error = nil
            }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "未知错误")
        }
        .sheet(isPresented: $imagePickerPresented) {
            loadImage()
        } content: {
            ImagePicker(image: $selectedImage)
                .presentationDetents([.large])
                .edgesIgnoringSafeArea(.all)
        }
        .enableInjection()
    }
}

// 图片处理扩展
extension CreateTweetView {
    func loadImage() {
        if let image = selectedImage {
            postImage = Image(uiImage: image)
        }
    }
}



// MARK: - Features/Feed/Views/FeedView.swift

import SwiftUI

struct FeedView: View {
    @ObserveInjection var inject
    @Environment(\.diContainer) private var container
    @StateObject private var viewModel: FeedViewModel
    @EnvironmentObject private var authViewModel: AuthState

    init(container: DIContainer) {
        let tweetService: TweetServiceProtocol = container.resolve(.tweetService)
            ?? TweetService(apiClient: APIClient(baseURL: APIConfig.baseURL))
        _viewModel = StateObject(wrappedValue: FeedViewModel(tweetService: tweetService))
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.tweets) { tweet in
                    TweetCellView(
                        viewModel: TweetCellViewModel(
                            tweet: tweet,
                            tweetService: container.resolve(.tweetService)
                                ?? TweetService(apiClient: APIClient(baseURL: APIConfig.baseURL)),
                            notificationService: container.resolve(.notificationService)
                                ?? NotificationService(apiClient: APIClient(baseURL: APIConfig.baseURL)),
                            currentUserId: authViewModel.currentUser?.id ?? "",
                            onTweetUpdated: { updatedTweet in
                                viewModel.updateTweet(updatedTweet)
                            }
                        )
                    )

                    .padding(.horizontal)
                    Divider()
                }
            }
        }
        .refreshable {
            viewModel.fetchTweets()
        }
        .onAppear {
            viewModel.fetchTweets()
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .enableInjection()
    }
}


// MARK: - Features/Feed/Views/TweetCellView.swift

import Kingfisher
import SwiftUI

struct TweetCellView: View {
    @ObserveInjection var inject
    @ObservedObject var viewModel: TweetCellViewModel
    @Environment(\.diContainer) private var container
    @EnvironmentObject var authState: AuthState  // 直接获取全局 AuthState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 如果点赞数大于 0，则显示点赞数
            if viewModel.likesCount > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.gray)
                    Text("\(viewModel.likesCount) likes")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 16)
            }
            
            HStack(alignment: .top, spacing: 12) {
                // 头像区域：点击跳转到对应用户的个人主页
                NavigationLink {
                    ProfileView(userId: viewModel.tweet.userId, diContainer: container)
                } label: {
                    avatarView
                }
                
                // 推文内容区域
                VStack(alignment: .leading, spacing: 4) {
                    // 用户信息
                    HStack {
                        Text(viewModel.tweet.user)
                            .fontWeight(.semibold)
                        Text("@\(viewModel.tweet.username)")
                            .foregroundColor(.gray)
                        Text("·")
                            .foregroundColor(.gray)
                        Text("11h")
                            .foregroundColor(.gray)
                    }
                    .font(.system(size: 16))
                    
                    // 推文文本
                    Text(viewModel.tweet.text)
                        .font(.system(size: 16))
                        .frame(maxHeight: 100)
                        .lineSpacing(4)
                    
                    // 推文图片（如果存在）
                    if viewModel.tweet.image == true {
                        GeometryReader { proxy in
                            KFImage(URL(string: "http://localhost:3000/tweets/\(viewModel.tweet.id)/image"))
                                .resizable()
                                .scaledToFill()
                                .frame(width: proxy.size.width, height: 200)
                                .cornerRadius(15)
                        }
                        .frame(height: 200)
                        .zIndex(0)
                    }
                    
                    // 互动按钮区域
                    HStack(spacing: 40) {
                        InteractionButton(image: "message", count: 0)
                        InteractionButton(image: "arrow.2.squarepath", count: 0)
                        
                        Button(action: {
                            if viewModel.isLiked {
                                viewModel.unlikeTweet()
                            } else {
                                viewModel.likeTweet()
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                                    .foregroundColor(viewModel.isLiked ? .red : .gray)
                                if let likes = viewModel.tweet.likes {
                                    Text("\(likes.count)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .zIndex(1)
                        .padding(8)
                        .contentShape(Rectangle())
                        
                        InteractionButton(image: "square.and.arrow.up", count: nil)
                    }
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .contentShape(Rectangle())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
        .enableInjection()
    }
    
    // 使用全局 AuthState 重新计算头像 URL
    private var avatarView: some View {
        KFImage(getAvatarURL())
            .placeholder {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 44, height: 44)
            }
            .resizable()
            .scaledToFill()
            .frame(width: 44, height: 44)
            .clipShape(Circle())
            .onAppear {
                // 可选：在 onAppear 清除缓存，确保加载最新图片
                if let url = getAvatarURL() {
                    KingfisherManager.shared.cache.removeImage(forKey: url.absoluteString)
                }
            }
    }
    
    private func getAvatarURL() -> URL? {
        // 调用 TweetCellViewModel 中的方法，传入全局 authState
        return viewModel.getUserAvatarURL(from: authState)
    }
}

// MARK: - 子视图：互动按钮

private struct InteractionButton: View {
    let image: String
    let count: Int?
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: image)
                .foregroundColor(.gray)
            if let count = count {
                Text("\(count)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Features/Main/Views/Home.swift

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: AuthState
    @ObserveInjection var inject
    @Binding var selectedTab: Int
    @State private var showCreateTweetView = false
  @Binding var searchText:String
  @Binding  var isSearching:Bool
  @Environment(\.diContainer) private var container
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
              FeedView(container: container)
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .tag(0)

                SearchView(searchText: $searchText, isEditing: $isSearching)
             
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                    .tag(1)
                
                NotificationsView(
                    user: viewModel.currentUser ?? User.mock,
                    service: container.resolve(.notificationService) ?? NotificationService(apiClient:APIClient( baseURL: APIConfig.baseURL))
                )
                    .tabItem {
                        Image(systemName: "bell")
                        Text("Notifications")
                    }
                    .tag(2)

                MessagesView()
                    .tabItem {
                        Image(systemName: "envelope")
                        Text("Messages")
                    }
                    .tag(3)
            }
            .sheet(isPresented: $showCreateTweetView) {
                CreateTweetView()
            }
            .accentColor(Color("BG"))

            // 添加浮动发推按钮
            Button(action: {
                showCreateTweetView = true
            }) {
                Image(systemName: "plus")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color("BG"))
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding()
            .padding(.bottom, 60) // 调整按钮位置，避免与 TabBar 重叠
        }

        .enableInjection()
    }
}


// MARK: - Features/Main/Views/MainView.swift

import SwiftUI

struct MainView: View {
    @State private var navigationPath = NavigationPath()
    @State private var showMenu = false
    @State private var showProfile = false
    @State private var profileUserId: String? = nil  // 新增：用于存储用户 ID
    @State private var offset: CGFloat = 0
    @State private var selectedTab = 0 // 添加这行
    @EnvironmentObject private var viewModel: AuthState
    @Environment(\.diContainer) private var diContainer: DIContainer 

    // 侧边菜单宽度（为了方便修改）
    private var menuWidth: CGFloat {
        UIScreen.main.bounds.width - 90
    }

    @State private var searchText = ""
    @State private var isSearching = false

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .leading) {
                VStack(spacing: 0) {
                    TopBar(showMenu: $showMenu,
                           offset: $offset,
                           selectedTab: $selectedTab,
                           searchText: $searchText,
                           isSearching: $isSearching)

                    HomeView(selectedTab: $selectedTab,
                             searchText: $searchText,
                             isSearching: $isSearching)
                }
                // 根据 offset 偏移，用于把主界面往右推
                .offset(x: offset)
                // 当菜单展开时，若需要禁止主界面交互，可在此启用:
                // .disabled(showMenu)

                // 半透明蒙版，用于点击/拖拽关闭菜单
                Color.gray
                    .opacity(0.3 * min(offset / (UIScreen.main.bounds.width - 90), 1.0))
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showMenu = false
                            offset = 0
                        }
                    }
                    .allowsHitTesting(showMenu)

                // 2. 侧边菜单视图
                SlideMenu(onProfileTap: { userId in
                    // 当点击头像时，将传入的 userId 存储，并触发导航到 ProfileView
                    self.profileUserId = userId
                    self.showProfile = true
                })
                .frame(width: menuWidth)
                .background(Color.white)
                .offset(x: offset - menuWidth)
                .zIndex(2) // 添加最高层级

                // 3. 用于菜单拖拽手势的透明层
                if showMenu {
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .gesture(dragGesture)
                        .frame(width: UIScreen.main.bounds.width - menuWidth)
                        .offset(x: menuWidth) // 只覆盖非菜单区域
                        .zIndex(1)
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .frame(width: 30)
                        .gesture(dragGesture)
                        .zIndex(1)
                }
            }
            // 导航到 ProfileView 时传入 profileUserId（此处 profileUserId 为非 nil 的当前用户 ID）
            .navigationDestination(isPresented: $showProfile) {
                ProfileView(userId: profileUserId, diContainer: diContainer)
            }
            .toolbar(.hidden, for: .tabBar) // 只隐藏 tabBar
        }
    }

    /// 将 DragGesture 封装，给上面透明视图使用
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                // 计算当前手指移动量（根据是否已经在菜单展开状态，做相对位移）
                let translation = gesture.translation.width

                if !showMenu {
                    // 菜单未展开时，手势从左向右拉出
                    // offset 最大只能到 menuWidth
                    offset = max(0, min(translation, menuWidth))
                } else {
                    // 菜单已展开，手势可能关闭菜单
                    // 基准点为展开状态下 offset=menuWidth，所以要加上 menuWidth
                    offset = max(0, min(menuWidth, translation + menuWidth))
                }
            }
            .onEnded { gesture in
                let translation = gesture.translation.width
                // 计算手指在结束时的速度或位置
                let predictedEnd = gesture.predictedEndLocation.x - gesture.startLocation.x
                let threshold = menuWidth / 2

                withAnimation(.easeInOut(duration: 0.3)) {
                    if !showMenu {
                        // 原来是关闭状态
                        // 判断是否要展开
                        if predictedEnd > 200 || offset > threshold {
                            openMenu()
                        } else {
                            closeMenu()
                        }
                    } else {
                        // 原来是打开状态
                        // 判断是否要关闭
                        if predictedEnd < -200 || offset < threshold {
                            closeMenu()
                        } else {
                            openMenu()
                        }
                    }
                }
            }
    }

    private func openMenu() {
        offset = menuWidth
        showMenu = true
    }

    private func closeMenu() {
        offset = 0
        showMenu = false
    }
}

// MARK: - Features/Main/Views/MultilineTextField.swift

import SwiftUI
import UIKit 


struct MultilineTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 18)
        textView.backgroundColor = .clear
        textView.delegate = context.coordinator
        textView.text = placeholder
        textView.textColor = .gray
        return textView
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: MultilineTextField

        init(_ parent: MultilineTextField) {
            self.parent = parent
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == .gray {
                textView.text = ""
                textView.textColor = .black
            }
            
            parent.text = textView.text

        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text

        }

        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = .gray
            }
        }
    }


    func updateUIView(_ uiView: UITextView, context _: Context) {
       
    }

}


// MARK: - Features/Main/Views/SettingsView.swift

import SwiftUI

struct SettingsView: View {
   @Environment(\.dismiss) private var dismiss
   @EnvironmentObject private var authViewModel: AuthState
   
   var body: some View {
       NavigationView {
           List {
               Section {
                   Button(action: {
                       authViewModel.signOut()
                       dismiss()
                   }) {
                       Text("Log Out")
                           .foregroundColor(.red)
                   }
               }
           }
           .navigationTitle("Settings and Privacy")
           .navigationBarTitleDisplayMode(.inline)
           .toolbar {
               ToolbarItem(placement: .navigationBarLeading) {
                   Button("Cancel") {
                       dismiss()
                   }
               }
           }
       }
   }
}


// MARK: - Features/Main/Views/SlideMenu.swift

import Kingfisher
import SwiftUI

struct SlideMenu: View {
    @EnvironmentObject private var authViewModel: AuthState // 注入 AuthState
    @State private var showSettings = false // 添加这一行

    // 修改 onProfileTap，接收 String 参数
    var onProfileTap: (String) -> Void
    @State private var isExpanded = false
    @ObserveInjection var inject
  private var avatarURL: URL? {
      guard let user = authViewModel.currentUser else { return nil }
      // 这里直接使用当前时间戳，保证 URL 每次都不同（注意：如果担心每次重绘都刷新可考虑只在用户更新时刷新）
      let timestamp = Int(Date().timeIntervalSince1970)
      return URL(string: "http://localhost:3000/users/\(user.id)/avatar?t=\(timestamp)")
  }

    var body: some View {
        VStack(alignment: .leading) {
            // 顶部用户信息区域
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Button {
                        // 当点击头像时，如果当前用户存在，则将 user.id 传给 onProfileTap 回调
                        if let userId = authViewModel.currentUser?.id {
                            onProfileTap(userId)
                        }
                    } label: {
                        HStack {
                            KFImage(avatarURL)
                                .placeholder {
                                    Circle()
                                        .fill(.gray)
                                        .frame(width: 44, height: 44)
                                }
                                .resizable()
                                .scaledToFill()
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                                .onAppear {
                                    // 清除特定 URL 的缓存
                                    if let url = avatarURL {
                                        KingfisherManager.shared.cache.removeImage(forKey: url.absoluteString)
                                    }
                                }
                                .padding(.bottom, 12)

                            VStack(alignment: .leading, spacing: 0) {
                                Text(authViewModel.currentUser?.name ?? "")
                                    .font(.system(size: 14))
                                    .padding(.bottom, 4)
                                Text("@\(authViewModel.currentUser?.username ?? "")")
                                    .font(.system(size: 12))
                                    .bold()
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .contentShape(Rectangle())
                }
                Spacer()

                Button(action: {
                    isExpanded.toggle()
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 16))
                }
                .padding(.top, 12)
            }

            // 关注信息区域
            HStack(spacing: 0) {
                //    Text("\(authViewModel.user!.following.count) ")
                Text("324")
                    .font(.system(size: 14))
                    .bold()
                Text("Following")
                    .foregroundStyle(.gray)
                    .font(.system(size: 14))
                    .bold()
                    .padding(.trailing, 8)
                //    Text("\(authViewModel.user!.followers.count) ")
                Text("253")
                    .font(.system(size: 14))
                    .bold()
                Text("Followers")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                    .bold()
            }

            .padding(.top, 4)

            // 主菜单列表区域
            VStack(alignment: .leading, spacing: 0) {
                ForEach([
                    ("person", "Profile"),
                    ("list.bullet", "Lists"),
                    ("number", "Topics"),
                    ("bookmark", "Bookmarks"),
                    ("sparkles", "Moments"),
                ], id: \.1) { icon, text in
                    HStack {
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .padding(16)
                            .padding(.leading, -16)

                        Text(text)
                            .font(.system(size: 18))
                            .bold()
                    }
                }
            }
            .padding(.vertical, 12)

            Divider()
                .padding(.bottom, 12 + 16)

            // 底部区域
            VStack(alignment: .leading, spacing: 12) {
                Button {
                    showSettings = true
                } label: {
                    Text("Settings and privacy")
                        .font(.system(size: 14))
                        .bold()
                }

                Text("Help Center")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)

                HStack {
                    Image(systemName: "lightbulb")
                    Spacer()
                    Image(systemName: "qrcode")
                }
                .font(.title3)
                .padding(.vertical, 12)
                .bold()
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .padding(.top, 12)
        .padding(.horizontal, 24)
        .frame(maxHeight: .infinity, alignment: .top)
        .enableInjection()
    }
}


// MARK: - Features/Main/Views/TopBar.swift

import Kingfisher
import SwiftUI

struct TopBar: View {
    let width = UIScreen.main.bounds.width
    @ObserveInjection var inject
    @Binding var showMenu: Bool
    @Binding var offset: CGFloat
    @Binding var selectedTab: Int // 添加这行
    @EnvironmentObject private var authViewModel: AuthState
  @Binding var searchText: String
  @Binding var isSearching: Bool
    private var avatarURL: URL? {
        guard let user = authViewModel.currentUser else {
            return nil
        }
        return URL(string: "http://localhost:3000/users/\(user.id)/avatar")
    } 
    var body: some View {
        VStack {
            HStack {
                // 替换Circle为KFImage
                KFImage(avatarURL)
                    .placeholder {
                        Image("blankpp") // 使用默认头像作为占位图
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 35, height: 35)
                    .clipShape(Circle())
                    .opacity(1.0 - (offset / (UIScreen.main.bounds.width - 90)))
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showMenu.toggle()
                            if showMenu {
                                offset = UIScreen.main.bounds.width - 90
                            } else {
                                offset = 0
                            }
                        }
                    }

                Spacer()

                Image(systemName: "ellipsis")
                    .font(.system(size: 24))
                    .foregroundColor(.black)
            }
            .overlay(
                Group {
                    switch selectedTab {
                    case 0:
                        Image("X")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 25, height: 25)
                    case 1:
                        SearchBar(text: $searchText, isEditing: $isSearching)
                            .frame(width: width * 0.7)
                    case 2:
                        Text("Notifications")
                            .font(.headline)
                    case 3:
                        Text("Messages")
                            .font(.headline)
                    default:
                        EmptyView()
                    }
                },
                alignment: .center
            )
            .padding(.top, 6)
            .padding(.bottom, 8)
            .padding(.horizontal, 12)

            // 底部分隔线
            Rectangle()
                .frame(width: width, height: 1)
                .foregroundColor(.gray)
                .opacity(0.3)
        }
        .background(Color.white)
        .enableInjection()
    }
}


// MARK: - Features/Messages/MessageCell.swift

import SwiftUI

struct MessageCell: View {
    @State private var width = UIScreen.main.bounds.width
    @ObserveInjection var inject 
    var body: some View {
        VStack(alignment: .leading, spacing: nil) {
            // 1. 分隔线
            Rectangle()
                .frame(width: width, height: 1)
                .foregroundColor(.gray)
                .opacity(0.3)
            
            // 2. 主要内容区域
            HStack(alignment: .top) {
                // 头像
                Circle()
                    .fill(Color.gray)
                    .frame(width: 60, height: 60)
                    .padding(.leading)
                
                // 右侧信息区域
                VStack(alignment: .leading) {
                    // 用户信息行
                    HStack {
                        Text("Bruce Wayne")
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Text("@_bruce")
                                .foregroundColor(.gray)
                            
                            Spacer(minLength: 0)
                            
                            Text("6/28/21")
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 2)
                    }
                    
                    // 最后一条消息
                    Text("Hey, how's it going?")
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
                .padding(.trailing)
            } 
        }
        .frame(width: width, height: 84)
        .enableInjection()
    }
}

#Preview {
    MessageCell()
}

// MARK: - Features/Messages/MessagesView.swift

import SwiftUI

struct MessagesView: View {
    @ObserveInjection var inject
    var body: some View {
        VStack {
            ScrollView {
                ForEach(0..<10) { _ in
                    MessageCell()
                }
            }
        }
        .enableInjection()
    }
}

#Preview {
    MessagesView()
}


// MARK: - Features/Notifications/Models/Notification.swift

import Foundation

// 通知类型枚举
enum NotificationType: String, Codable {
    case like
    case follow
    
    var message: String {
        switch self {
        case .like: return "点赞了你的推文"
        case .follow: return "关注了你"
        }
    }
}

struct Notification: Identifiable, Codable {
    let id: String
    let notificationSenderId: String
    let notificationReceiverId: String
    let notificationType: NotificationType
    let postText: String?
    let createdAt: Date
    var senderUsername: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case notificationSenderId
        case notificationReceiverId
        case notificationType
        case postText
        case createdAt
    }
    
    // 定义内部用于解析发送者信息的 key
    enum SenderKeys: String, CodingKey {
        case id = "_id"
        case username
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        
        // 对 notificationSenderId 字段进行嵌套解码
        let senderContainer = try container.nestedContainer(keyedBy: SenderKeys.self, forKey: .notificationSenderId)
        notificationSenderId = try senderContainer.decode(String.self, forKey: .id)
        senderUsername = try senderContainer.decode(String.self, forKey: .username)
        
        notificationReceiverId = try container.decode(String.self, forKey: .notificationReceiverId)
        notificationType = try container.decode(NotificationType.self, forKey: .notificationType)
        postText = try container.decodeIfPresent(String.self, forKey: .postText)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
}

// MARK: - Features/Notifications/Services/NotificationEndpoint.swift

import Foundation

enum NotificationEndpoint: APIEndpoint {
    case fetchNotifications(userId: String)
    case createNotification(username: String, receiverId: String, type: NotificationType, postText: String?)
    
    var path: String {
        switch self {
        case .fetchNotifications(let userId):
            return "/notifications/\(userId)"
        case .createNotification:
            return "/notifications"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchNotifications:
            return .get
        case .createNotification:
            return .post
        }
    }
    
    var body: Data? {
        switch self {
        case .fetchNotifications:
            return nil
        case let .createNotification(username, receiverId, type, postText):
            var params: [String: Any] = [
                "username": username,
                "notificationReceiverId": receiverId,
                "notificationType": type.rawValue
            ]
            if let postText = postText {
                params["postText"] = postText
            }
            return try? JSONSerialization.data(withJSONObject: params)
        }
    }
    
    var headers: [String: String]? {
        var headers = ["Content-Type": "application/json"]
        if let token = UserDefaults.standard.string(forKey: "jwt") {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }
    
    var queryItems: [URLQueryItem]? {
        return nil
    }
}

// MARK: - Features/Notifications/Services/NotificationService.swift

import Foundation

protocol NotificationServiceProtocol {
    func fetchNotifications(userId: String) async throws -> [Notification]
    func createNotification(username: String, receiverId: String, type: NotificationType, postText: String?) async throws -> Notification
}

final class NotificationService: NotificationServiceProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func fetchNotifications(userId: String) async throws -> [Notification] {
        let endpoint = NotificationEndpoint.fetchNotifications(userId: userId)
        return try await apiClient.sendRequest(endpoint)
    }
    
    func createNotification(username: String, receiverId: String, type: NotificationType, postText: String?) async throws -> Notification {
        let endpoint = NotificationEndpoint.createNotification(
            username: username,
            receiverId: receiverId,
            type: type,
            postText: postText
        )
        return try await apiClient.sendRequest(endpoint)
    }
}


// MARK: - Features/Notifications/ViewModels/NotificationsViewModel.swift

import Foundation

@MainActor
final class NotificationsViewModel: ObservableObject {
    // 发布数据和状态
    @Published private(set) var notifications: [Notification] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    // 依赖注入
    private let service: NotificationServiceProtocol
    private let user: User

    init(user: User, service: NotificationServiceProtocol) {
        self.user = user
        self.service = service
    }
    
    /// 获取通知列表，每次调用都会重新加载数据
    func fetchNotifications() async {
        // 如果正在加载，则直接返回，防止并发调用
        guard !isLoading else { return }
        isLoading = true
        error = nil
        do {
            let newNotifications = try await service.fetchNotifications(userId: user.id)
            notifications = newNotifications
        } catch {
            // 如果错误是任务取消，则忽略错误，不赋值 error
            if error is CancellationError {
                print("Fetch notifications cancelled. Ignoring cancellation error.")
            } else {
                self.error = error
                print("Failed to fetch notifications: \(error)")
            }
        }
        isLoading = false
    }
    
    /// 刷新通知列表，直接调用 fetchNotifications()
    func refreshNotifications() async {
        await fetchNotifications()
    }
    
    /// 创建新通知
    func createNotification(receiverId: String, type: NotificationType, postText: String? = nil) {
        Task {
            do {
                let newNotification = try await service.createNotification(
                    username: user.username,
                    receiverId: receiverId,
                    type: type,
                    postText: postText
                )
                // 新通知插入列表最前面
                notifications.insert(newNotification, at: 0)
            } catch {
                if error is CancellationError {
                    print("Create notification cancelled. Ignoring cancellation error.")
                } else {
                    self.error = error
                    print("Failed to create notification: \(error)")
                }
            }
        }
    }
    
    /// 清除错误状态
    func clearError() {
        error = nil
    }
}

// MARK: - Features/Notifications/Views/NotificationCell.swift


import SwiftUI
import Kingfisher

struct NotificationCell: View {
    
    @State var width = UIScreen.main.bounds.width
    
    let notification: Notification
    
    var body: some View {
        VStack {
            Rectangle()
                .frame(width: width, height: 1, alignment: .center)
                .foregroundColor(.gray)
                .opacity(0.3)
            
            HStack(alignment: .top) {
                Image(systemName: "person.fill")
                    .resizable()
                    .foregroundColor(.blue)
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                
                VStack(alignment: .leading, spacing: 5, content: {
                    KFImage(URL(string: "http://localhost:3000/users/\(notification.notificationSenderId)/avatar"))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .cornerRadius(18)
                    
                    
                    Text(notification.senderUsername ?? "")
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    + Text(" ")
                    + Text(notification.notificationType.message)
                        .foregroundColor(.black)
                    
                })
                
                Spacer(minLength: 0)
                
            }
            .padding(.leading, 30)
        }
    }
}



// MARK: - Features/Notifications/Views/NotificationsView.swift

import SwiftUI

struct NotificationsView: View {
    @StateObject private var viewModel: NotificationsViewModel

    init(user: User, service: NotificationServiceProtocol) {
        _viewModel = StateObject(wrappedValue: NotificationsViewModel(user: user, service: service))
    }

    var body: some View {
        ZStack {
            // 如果数据正在加载且列表为空，则显示加载指示器，否则显示内容
            if viewModel.isLoading && viewModel.notifications.isEmpty {
                ProgressView()
            } else {
                content
            }
        }
//        // 通过 Alert 显示错误信息
//        .alert("错误", isPresented: Binding(
//            get: { viewModel.error != nil },
//            set: { _ in viewModel.clearError() }
//        )) {
//            Button("确定") {
//                viewModel.clearError()
//            }
//        } message: {
//            if let error = viewModel.error {
//                Text(error.localizedDescription)
//            }
//        }
        // 视图首次加载时调用一次
        .task {
            await viewModel.fetchNotifications()
        }
        // 每隔 5 秒自动刷新一次（避免多次并发刷新）
        .onReceive(Timer.publish(every: 5, on: .main, in: .common).autoconnect()) { _ in
            if !viewModel.isLoading {
                Task {
                    await viewModel.fetchNotifications()
                }
            }
        }
    }

    private var content: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if viewModel.notifications.isEmpty {
                    emptyView
                } else {
                    ForEach(viewModel.notifications) { notification in
                        NotificationCell(notification: notification)
                        Divider()
                    }
                }
            }
        }
        // 下拉刷新时调用 refreshNotifications()
        .refreshable {
            await viewModel.refreshNotifications()
        }
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Text("暂无通知")
                .font(.title3)
                .fontWeight(.semibold)
            Text("新的通知将会显示在这里")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 32)
    }
}


// MARK: - Features/Profile/Services/ProfileServiceProtocol..swift

//
//  ProfileServiceProtocol..swift
//  CloneTwitter
//
//  Created by 潘令川 on 2025/2/6.
//

import Foundation


import Foundation

protocol ProfileServiceProtocol {
    func fetchUserProfile(userId: String) async throws -> User
    func updateProfile(data: [String: Any]) async throws -> User
    func fetchUserTweets(userId: String) async throws -> [Tweet]
    func uploadAvatar(imageData: Data) async throws -> User
    func uploadBanner(imageData: Data) async throws -> User
  
}

final class ProfileService: ProfileServiceProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func fetchUserProfile(userId: String) async throws -> User {
        let endpoint = ProfileEndpoint.fetchUserProfile(userId: userId)
        return try await apiClient.sendRequest(endpoint)
    }
    
    func updateProfile(data: [String: Any]) async throws -> User {
        let endpoint = ProfileEndpoint.updateProfile(data: data)
        return try await apiClient.sendRequest(endpoint)
    }
    
    func fetchUserTweets(userId: String) async throws -> [Tweet] {
        let endpoint = ProfileEndpoint.fetchUserTweets(userId: userId)
        return try await apiClient.sendRequest(endpoint)
    }
    
    /// 修改后的上传头像逻辑  
    /// 第一步调用 sendRequestWithoutDecoding 上传图片（不解码响应），
    /// 第二步调用 fetchUserProfile 获取更新后的用户数据
    func uploadAvatar(imageData: Data) async throws -> User {
        let uploadEndpoint = ProfileEndpoint.uploadAvatar(imageData: imageData)
        try await apiClient.sendRequestWithoutDecoding(uploadEndpoint)
        // 上传成功后获取最新用户数据
        return try await fetchUserProfile(userId: "me")
    }

    func uploadBanner(imageData: Data) async throws -> User {
        let uploadEndpoint = ProfileEndpoint.uploadBanner(imageData: imageData)
        try await apiClient.sendRequestWithoutDecoding(uploadEndpoint)
        return try await fetchUserProfile(userId: "me")
    }
}




#if DEBUG
final class MockProfileService: ProfileServiceProtocol {
    var shouldSucceed = true
    
    func fetchUserProfile(userId: String) async throws -> User {
        if shouldSucceed {
            return User.mock
        } else {
            throw NetworkError.unauthorized
        }
    }
    
    func updateProfile(data: [String: Any]) async throws -> User {
        if shouldSucceed {
            return User.mock
        } else {
            throw NetworkError.unauthorized
        }
    }
    
    func fetchUserTweets(userId: String) async throws -> [Tweet] {
        if shouldSucceed {
            return [.mock]
        } else {
            throw NetworkError.unauthorized
        }
    }
    
    func uploadAvatar(imageData: Data) async throws -> User {
        if shouldSucceed {
            return User.mock
        } else {
            throw NetworkError.unauthorized
        }
    }
    
    func uploadBanner(imageData: Data) async throws -> User {
        if shouldSucceed {
            return User.mock
        } else {
            throw NetworkError.unauthorized
        }
    }
}

//private extension Tweet {
//    static var mock: Tweet {
//        Tweet(
//            _id: "mock_tweet_id",
//            text: "This is a mock tweet",
//            userId: "mock_user_id",
//            username: "mock_user",
//            user: "Mock User"
//        )
//    }
//}
#endif


// MARK: - Features/Profile/ViewModels/EditProfileViewModel.swift

// import Combine
// import Kingfisher
// import SwiftUI

// // 在 class EditProfileViewModel 之前添加 AuthenticationError 枚举
// enum AuthenticationError: Error {
//     case custom(String)
// }

// class EditProfileViewModel: ObservableObject {
//     @Published var user: User
//     @Published var isSaving = false
//     @Published var error: Error?
//     @Published var uploadComplete = false

//     // 图片相关状态
//     @Published var profileImage: UIImage?
//     @Published var bannerImage: UIImage?
//     @Published var isUploadingImage = false

//     private var cancellables = Set<AnyCancellable>()

//     init(user: User) {
//         self.user = user

//         // 可以选择是否也订阅 AuthViewModel 的变化
//         AuthViewModel.shared.$user
//             .compactMap { $0 }
//             .receive(on: DispatchQueue.main)
//             .sink { [weak self] updatedUser in
//                 self?.user = updatedUser
//             }
//             .store(in: &cancellables)
//     }

//     func save(name: String, bio: String, website: String, location: String) {
//         guard !name.isEmpty else { return }

//         isSaving = true
//         uploadComplete = false // 重置状态

//         Task {
//             do {
//                 // 1. 如果有新的头像图片，先上传头像
//                 if let newProfileImage = profileImage {
//                     try await uploadProfileImage(image: newProfileImage)
//                     // 清除特定URL的缓存
//                     if let avatarURL = URL(string: "http://localhost:3000/users/\(user.id)/avatar") {
//                         try? await KingfisherManager.shared.cache.removeImage(forKey: avatarURL.absoluteString)
//                     }
//                 }

//                 // 2. 如果有新的横幅图片，上传横幅
//                 if bannerImage != nil {
//                     // TODO: 添加上传横幅的方法
//                 }

//                 // 3. 上传用户文本数据
//                 let updatedUser = try await uploadUserData(
//                     name: name,
//                     bio: bio.isEmpty ? nil : bio,
//                     website: website.isEmpty ? nil : website,
//                     location: location.isEmpty ? nil : location
//                 )

//                 // 4. 如果有图片更新，清除缓存
//                 if profileImage != nil || bannerImage != nil {
//                     try? await KingfisherManager.shared.cache.clearCache()
//                 }

//                 // 5. 在主线程更新状态
//                 await MainActor.run {
//                     // 更新用户数据
//                     self.user = updatedUser
//                     AuthViewModel.shared.updateUser(updatedUser)

//                     // 清除已上传的图片状态
//                     self.profileImage = nil
//                     self.bannerImage = nil

//                     // 最后更新完成状态
//                     self.isSaving = false
//                     self.uploadComplete = true
//                 }
//             } catch {
//                 await MainActor.run {
//                     print("Error saving profile: \(error)")
//                     self.error = error
//                     self.isSaving = false
//                     self.uploadComplete = false
//                 }
//             }
//         }
//     }

//     // MARK: - 上传用户信息 （真正使用 async/await，而不是在里面套闭包）

//     func uploadUserData(
//         name: String?,
//         bio: String?,
//         website: String?,
//         location: String?
//     ) async throws -> User {
//         // 1. 获取 token
//         guard let token = UserDefaults.standard.string(forKey: "jwt") else {
//             throw AuthenticationError.custom("No token found")
//         }

//         // 2. 构建请求体 - 只包含非空值
//         var requestBody: [String: Any] = [:]
//         if let name = name { requestBody["name"] = name }
//         if let bio = bio { requestBody["bio"] = bio }
//         if let website = website { requestBody["website"] = website }
//         if let location = location { requestBody["location"] = location }

//         print("Uploading user data:", requestBody) // 添加日志

//         // 3. 构建 URL
//         let urlString = "http://localhost:3000/users/me"

//         // 4. 发送请求
//         return try await withCheckedThrowingContinuation { continuation in
//             AuthService.makePatchRequestWithAuth(
//                 urlString: urlString,
//                 requestBody: requestBody,
//                 token: token
//             ) { result in
//                 switch result {
//                 case let .success(data):
//                     do {
//                         print("Received response data:", String(data: data, encoding: .utf8) ?? "") // 添加日志
//                         let updatedUser = try JSONDecoder().decode(User.self, from: data)
//                         continuation.resume(returning: updatedUser)
//                     } catch {
//                         print("Failed to decode user data:", error) // 添加日志
//                         continuation.resume(throwing: error)
//                     }

//                 case let .failure(error):
//                     print("Network request failed:", error) // 添加日志
//                     continuation.resume(throwing: error)
//                 }
//             }
//         }
//     }

//     // MARK: - 上传头像 (也改成 async)

//     func uploadProfileImage(image: UIImage) async throws {
//         // 1. 定义 URL 路径
//         let urlPath = "/users/me/avatar"

//         // 2. 用 continuation 等到上传结束
//         try await withCheckedThrowingContinuation { continuation in
//             ImageUploader.uploadImage(
//                 paramName: "avatar",
//                 fileName: "profile_image.jpeg",
//                 image: image,
//                 urlPath: urlPath
//             ) { [weak self] result in
//                 guard let self = self else { return }

//                 switch result {
//                 case let .success(json):
//                     print("Profile image uploaded successfully: \(json)")
//                     // 清除 Kingfisher 缓存以更新 UI
//                     KingfisherManager.shared.cache.clearCache()
//                     // 不要在这里 toggle self.uploadComplete，因为还要等文本信息一起更新
//                     continuation.resume(returning: ())

//                 case let .failure(error):
//                     print("Failed to upload profile image: \(error)")
//                     DispatchQueue.main.async {
//                         self.error = error
//                     }
//                     continuation.resume(throwing: error)
//                 }
//             }
//         }
//     }
// }


// MARK: - Features/Profile/ViewModels/ProfileViewModel.swift

import SwiftUI
import Foundation
import Kingfisher

// Fix notification name definition
extension NSNotification.Name {
    static let didUpdateProfile = NSNotification.Name("didUpdateProfile")
}

@MainActor
final class ProfileViewModel: ObservableObject {
    private let profileService: ProfileServiceProtocol
    private let userId: String?
    
    @Published var user: User?
    @Published var tweets: [Tweet] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var shouldRefreshImage = false
    
    private(set) var lastImageRefreshTime: TimeInterval = Date().timeIntervalSince1970
    
    var isCurrentUser: Bool {
        guard let profileUserId = user?.id else { return false }
        return userId == nil || userId == profileUserId
    }
    
    init(profileService: ProfileServiceProtocol, userId: String? = nil) {
        self.profileService = profileService
        self.userId = userId
        
        Task {
            await fetchProfile()
        }
    }
    
    func fetchProfile() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let targetUserId = userId ?? self.user?.id ?? "me"
            async let profile = profileService.fetchUserProfile(userId: targetUserId)
            async let userTweets = profileService.fetchUserTweets(userId: targetUserId)
            let (fetchedProfile, fetchedTweets) = try await (profile, userTweets)
            self.user = fetchedProfile
            self.tweets = fetchedTweets
        } catch let networkError as NetworkError {
            errorMessage = networkError.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateProfile(data: [String: Any]) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let updatedUser = try await profileService.updateProfile(data: data)
            self.user = updatedUser
            self.lastImageRefreshTime = Date().timeIntervalSince1970
            self.shouldRefreshImage.toggle()
            // 发布通知，传递最新的用户数据
            NotificationCenter.default.post(name: .didUpdateProfile, object: updatedUser)
        } catch let networkError as NetworkError {
            errorMessage = networkError.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func uploadAvatar(imageData: Data) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let updatedUser = try await profileService.uploadAvatar(imageData: imageData)
            self.user = updatedUser
            self.lastImageRefreshTime = Date().timeIntervalSince1970
            self.shouldRefreshImage.toggle()
            if let url = getAvatarURL() {
                try await KingfisherManager.shared.cache.removeImage(forKey: url.absoluteString)
            }
            // 发布通知，全局更新
            NotificationCenter.default.post(name: .didUpdateProfile, object: updatedUser)
            try await fetchProfile()
        } catch let networkError as NetworkError {
            errorMessage = networkError.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func getAvatarURL() -> URL? {
        guard let userId = user?.id else { return nil }
        let baseURL = "\(APIConfig.baseURL)/users/\(userId)/avatar"
        return URL(string: "\(baseURL)?t=\(Int(lastImageRefreshTime))")
    }
}


// MARK: - Features/Profile/Views/BlurView.swift

// import SwiftUI
// import UIKit 


// struct BlurView: UIViewRepresentable {
//     func makeUIView(context: Context) -> UIVisualEffectView {
//         let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
//         return view
//     }
    
//     func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
//         // No update needed
//     }



// }


// MARK: - Features/Profile/Views/CustomProfileTextField.swift


import SwiftUI 

struct CustomProfileTextField: View {
    // 绑定的文本值
    @Binding var message: String
    // placeholder文本
    let placeholder: String

    var body: some View {
        ZStack(alignment: .leading) {
            // 只在文本为空时显示placeholder
            if message.isEmpty {
                HStack {
                    Text(placeholder)
                        .foregroundColor(.gray)
                    Spacer()
                }
            }

            // 文本输入框
            TextField("", text: $message)
                .foregroundColor(.blue)
        }
    }
}

struct CustomProfileBioTextField: View {
    // 绑定的文本值
    @Binding var bio: String

    var body: some View {
        VStack(alignment: .leading) {
            // 使用ZStack实现placeholder的叠加效果
            ZStack(alignment: .topLeading) {
                // 只在bio为空时显示placeholder
                if bio.isEmpty {
                    HStack {
                        Text("Add bio to your profile")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding([.top, .leading], 8)
                    .zIndex(1)
                }

                // 多行文本编辑器
                TextEditor(text: $bio)
                    .foregroundColor(.blue)
            }
        }
        .frame(height: 90)
    }
}


// MARK: - Features/Profile/Views/EditProfileView.swift

import Kingfisher
import SwiftUI

struct EditProfileView: View {
    @Environment(\.presentationMode) var mode
    @EnvironmentObject private var authState: AuthState // 若需要访问全局登录状态
    @ObservedObject var viewModel: ProfileViewModel // 使用同一个 ProfileViewModel

    // 用户输入的状态变量
    @State private var name: String = ""
    @State private var location: String = ""
    @State private var bio: String = ""
    @State private var website: String = ""

    // 图片相关状态
    @State private var profileImage: UIImage?
    @State private var bannerImage: UIImage?
    @State private var showError = false
    @State private var errorMessage: String?

    // 图片选择器相关状态
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var imagePickerType: ImagePickerType = .profile

    enum ImagePickerType {
        case banner
        case profile
    }

    // 初始化，从 ProfileViewModel.user 中读取现有数据
    init(viewModel: ProfileViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)

        // 若 user 还没加载成功，可以在这里做安全处理
        if let user = viewModel.user {
            _name = State(initialValue: user.name)
            _location = State(initialValue: user.location ?? "")
            _bio = State(initialValue: user.bio ?? "")
            _website = State(initialValue: user.website ?? "")
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            // 主内容区域
            ScrollView {
                VStack {
                    // 图片编辑区域
                    VStack {
                        // Banner图片区域
                        ZStack {
                            if let bannerImage = bannerImage {
                                Image(uiImage: bannerImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 180)
                                    .clipShape(Rectangle())
                            } else {
                                Rectangle()
                                    .fill(Color(.systemGray6))
                                    .frame(height: 180)
                            }

                            // Banner编辑按钮
                            Button(action: {
                                imagePickerType = .banner
                                showImagePicker = true
                            }) {
                                Image(systemName: "camera")
                                    .renderingMode(.template)
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.black.opacity(0.75))
                                    .clipShape(Circle())
                            }
                        }

                        // 头像编辑区域
                        HStack {
                            Button(action: {
                                imagePickerType = .profile
                                showImagePicker = true
                            }) {
                                if let profileImage = profileImage {
                                    Image(uiImage: profileImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 75, height: 75)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: 2)
                                        )
                                } else {
                                    Circle()
                                        .fill(Color(.systemGray6))
                                        .frame(width: 75, height: 75)
                                        .overlay(
                                            Image(systemName: "camera")
                                                .foregroundColor(.white)
                                                .padding(8)
                                                .background(Color.black.opacity(0.75))
                                                .clipShape(Circle())
                                        )
                                }
                            }
                            Spacer()
                        }
                        .padding(.top, -25)
                        .padding(.bottom, -10)
                        .padding(.leading)
                        .padding(.top, -12)
                        .padding(.bottom, 12)
                    }

                    // 个人信息编辑区域
                    VStack {
                        Divider()

                        // Name字段
                        HStack {
                            ZStack {
                                HStack {
                                    Text("Name")
                                        .foregroundColor(.black)
                                        .fontWeight(.heavy)
                                    Spacer()
                                }

                                CustomProfileTextField(
                                    message: $name,
                                    placeholder: "Add your name"
                                )
                                .padding(.leading, 90)
                            }
                        }
                        .padding(.horizontal)

                        Divider()

                        // Location字段
                        HStack {
                            ZStack {
                                HStack {
                                    Text("Location")
                                        .foregroundColor(.black)
                                        .fontWeight(.heavy)
                                    Spacer()
                                }

                                CustomProfileTextField(
                                    message: $location,
                                    placeholder: "Add your location"
                                )
                                .padding(.leading, 90)
                            }
                        }
                        .padding(.horizontal)

                        Divider()

                        // Bio字段
                        HStack {
                            ZStack(alignment: .topLeading) {
                                HStack {
                                    Text("Bio")
                                        .foregroundColor(.black)
                                        .fontWeight(.heavy)
                                    Spacer()
                                }

                                CustomProfileBioTextField(bio: $bio)
                                    .padding(.leading, 86)
                                    .padding(.top, -6)
                            }
                        }
                        .padding(.horizontal)

                        Divider()

                        // Website字段
                        HStack {
                            ZStack {
                                HStack {
                                    Text("Website")
                                        .foregroundColor(.black)
                                        .fontWeight(.heavy)
                                    Spacer()
                                }

                                CustomProfileTextField(
                                    message: $website,
                                    placeholder: "Add your website"
                                )
                                .padding(.leading, 90)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 50)
            }

            // 顶部导航栏
            VStack {
                HStack {
                    Button("Cancel") {
                        mode.wrappedValue.dismiss()
                    }
                    Spacer()
                    Button(action: {
                        Task {
                            await viewModel.updateProfile(data: [
                                "name": name,
                                "bio": bio,
                                "website": website,
                                "location": location,
                            ])
                            authState.currentUser = viewModel.user
                            mode.wrappedValue.dismiss()
                        }
                    }) {
                        Text("Save")
                            .bold()
                    }
                    .disabled(viewModel.isLoading)
                }
                .padding()
                .background(Material.ultraThin)
                .compositingGroup()

                Spacer()
            }

            // ImagePicker 弹窗部分
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
                    .presentationDetents([.large])
                    .edgesIgnoringSafeArea(.all)
                    .onDisappear {
                        Task {
                            await handleSelectedImage()
                        }
                    }
            }
            .alert("上传失败", isPresented: $showError) {
                Button("确定", role: .cancel) {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "未知错误")
            }
        }
//      .onReceive(viewModel.$shouldRefreshImage) { _ in
//     // mode.wrappedValue.dismiss()
        // }
//         .onReceive(viewModel.$user) { updatedUser in
//             // 可选：若 updatedUser != nil，说明资料更新完毕
//         }
        .onAppear {
            // 可选：清除缓存或其他逻辑
            KingfisherManager.shared.cache.clearCache()
        }
    }
}

extension EditProfileView {
  private func handleSelectedImage() async {
        guard let image = selectedImage else { return }

        // 根据选择类型判断上传头像或banner
        if imagePickerType == .profile {
            profileImage = image

            // 注意：字段名称需要与后端保持一致，此处传 "avatar"
            ImageUploader.uploadImage(
                paramName: "avatar", // 修改前为 "image"，现改为 "avatar"
                fileName: "avatar.jpg",
                image: image,
                urlPath: "/users/me/avatar"
            ) { result in
                Task { @MainActor in
                    switch result {
                    case .success:
                        // 上传成功后刷新个人资料
                        await viewModel.fetchProfile()
                    case let .failure(error):
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            }

            await viewModel.uploadAvatar(imageData: image.jpegData(compressionQuality: 0.8)!)

            // 清除所有头像缓存
            await KingfisherManager.shared.cache.clearMemoryCache()
            await KingfisherManager.shared.cache.clearDiskCache()

        } else if imagePickerType == .banner {
            bannerImage = image
            // 如果需要上传 banner，可类似实现：
            /*
             ImageUploader.uploadImage(
                 paramName: "banner",
                 fileName: "banner.jpg",
                 image: image,
                 urlPath: "/users/me/banner"
             ) { result in
                 Task { @MainActor in
                     switch result {
                     case .success(_):
                         await viewModel.fetchProfile()
                     case .failure(let error):
                         errorMessage = error.localizedDescription
                         showError = true
                     }
                 }
             }
             */
        }

        selectedImage = nil
    }
}


// MARK: - Features/Profile/Views/ProfileView.swift

//
//  ProfileView.swift
//  twitter-clone (iOS)
//  Created by cem on 7/31/21.
//

import SwiftUI
import Kingfisher

// MARK: - BlurView 实现
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style = .light
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) { }
}

// MARK: - PreferenceKey 用于传递滚动偏移
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - ProfileView 主界面
struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    var isCurrentUser: Bool { viewModel.isCurrentUser }
    
    // For Dark Mode Adoption
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.diContainer) private var diContainer: DIContainer

    @State var currentTab = "Tweets"
    
    // For Smooth Slide Animation...
    @Namespace var animation
    @State var offset: CGFloat = 0            // 记录 Header 的滚动偏移（由 PreferenceKey 更新）
    @State var titleOffset: CGFloat = 0         // 用于计算标题上移量
    @State var tabBarOffset: CGFloat = 0

    // 头像及其它状态
    @State private var selectedImage: UIImage?
    @State var profileImage: Image?
    @State var imagePickerRepresented = false
    @State var editProfileShow = false

    @State var width = UIScreen.main.bounds.width
    
    // 初始化：若 userId 为 nil，则显示当前用户；否则显示指定用户的信息
    init(userId: String? = nil, diContainer: DIContainer) {
        guard let service: ProfileServiceProtocol = diContainer.resolve(.profileService) else {
            fatalError("ProfileService 未在 DIContainer 中注册")
        }
        _viewModel = StateObject(wrappedValue: ProfileViewModel(profileService: service, userId: userId))
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 15) {
                // Header (Banner) View
                GeometryReader { proxy -> AnyView in
                    // 使用命名坐标空间 "scroll" 得到准确的偏移
                    let minY = proxy.frame(in: .named("scroll")).minY
                  AnyView(
                        ZStack {
                            // Banner 图片：高度为 180，下拉时高度增加
                            Image("SSC_banner")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: getRect().width, height: minY > 0 ? 180 + minY : 180)
                                .clipped()
                            
                            // 模糊效果：从 20 点开始逐渐出现，到 80 点全模糊
                            BlurView(style: .light)
                                .opacity(blurViewOpacity())
                            
                            // 标题文本：显示用户名和 "150 Tweets"
                            VStack(spacing: 5) {
                                Text(viewModel.user?.name ?? "")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text("150 Tweets")
                                    .foregroundColor(.white)
                            }
                            // 初始偏移为 120，向上滚动时上移一定距离（使用 textOffset）
                            .offset(y: 120 - getTitleTextOffset())
                            // 当向上滚动超过 80 点时，文本开始淡出
                            .opacity(max(1 - ((max(-offset, 0) - 80) / 70), 0))
                        }
                        .frame(height: minY > 0 ? 180 + minY : 180)
                        // Sticky & Stretchy 效果
                        .offset(y: minY > 0 ? -minY : (-minY < 80 ? 0 : -minY - 80))
                        // 通过 Preference 将 minY 传递出去
                        .background(Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: minY))
                    )
                }
                .frame(height: 180)
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    self.offset = value
                    // 这里直接使用 -value 作为向上滚动距离（正值）
                    self.titleOffset = max(-value, 0)
                }
                .zIndex(1)
                
                // Profile Image 及其它信息部分
                VStack {
                    HStack {
                        VStack {
                            if profileImage == nil {
                                Button {
                                    self.imagePickerRepresented.toggle()
                                } label: {
                                    KFImage(viewModel.getAvatarURL())
                                        .placeholder {
                                            Image("blankpp")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 75, height: 75)
                                                .clipShape(Circle())
                                        }
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 75, height: 75)
                                        .clipShape(Circle())
                                        .padding(8)
                                        .background(colorScheme == .dark ? Color.black : Color.white)
                                        .clipShape(Circle())
                                        // 根据滚动偏移调整头像垂直位置与缩放
                                        .offset(y: offset < 0 ? getAvatarOffset() : -20)
                                        .scaleEffect(getAvatarScale())
                                }
                            } else if let image = profileImage {
                                VStack {
                                    HStack(alignment: .top) {
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 75, height: 75)
                                            .clipShape(Circle())
                                            .padding(8)
                                            .background(colorScheme == .dark ? Color.black : Color.white)
                                            .clipShape(Circle())
                                            .offset(y: offset < 0 ? getAvatarOffset() : -20)
                                    }
                                    .padding()
                                    Spacer()
                                }
                            }
                        }
                        Spacer()
                        if self.isCurrentUser {
                            Button(action: {
                                editProfileShow.toggle()
                            }, label: {
                                Text("Edit Profile")
                                    .foregroundColor(.blue)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal)
                                    .background(
                                        Capsule().stroke(Color.blue, lineWidth: 1.5)
                                    )
                            })
                            .onAppear {
                                KingfisherManager.shared.cache.clearCache()
                            }
                            .sheet(isPresented: $editProfileShow, onDismiss: {
                                KingfisherManager.shared.cache.clearCache()
                            }, content: {
                              EditProfileView(viewModel: viewModel)
                              
                            })
                        }
                    }
                    .padding(.top, -25)
                    .padding(.bottom, -10)
                    
                    // Profile Data 区域
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(viewModel.user?.name ?? "")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Text("@\(viewModel.user?.username ?? "")")
                                .foregroundColor(.gray)
                            Text(viewModel.user?.bio ?? "Make education not fail! 4️⃣2️⃣ Founder @TurmaApp soon.. @ProbableApp")
                            HStack(spacing: 8) {
                                if let userLocation = viewModel.user?.location, !userLocation.isEmpty {
                                    HStack(spacing: 2) {
                                        Image(systemName: "mappin.circle.fill")
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(.gray)
                                        Text(userLocation)
                                            .foregroundColor(.gray)
                                            .font(.system(size: 14))
                                    }
                                }
                                if let userWebsite = viewModel.user?.website, !userWebsite.isEmpty {
                                    HStack(spacing: 2) {
                                        Image(systemName: "link")
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(.gray)
                                        Text(userWebsite)
                                            .foregroundColor(Color("twitter"))
                                            .font(.system(size: 14))
                                    }
                                }
                            }
                            HStack(spacing: 5) {
                                Text("4,560")
                                    .foregroundColor(.primary)
                                    .fontWeight(.semibold)
                                Text("Followers")
                                    .foregroundColor(.gray)
                                Text("680")
                                    .foregroundColor(.primary)
                                    .fontWeight(.semibold)
                                    .padding(.leading, 10)
                                Text("Following")
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 8)
                        }
                        .padding(.leading, 8)
                        .overlay(
                            GeometryReader { proxy -> Color in
                                let minY = proxy.frame(in: .global).minY
                                // 此处可以根据需要更新 titleOffset（或其他状态）
                                DispatchQueue.main.async {
                                    self.titleOffset = max(-minY, 0)
                                }
                                return Color.clear
                            }
                            .frame(width: 0, height: 0),
                            alignment: .top
                        )
                        Spacer()
                    }
                    
                    // 分段菜单
                    VStack(spacing: 0) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                TabButton(title: "Tweets", currentTab: $currentTab, animation: animation)
                                TabButton(title: "Tweets & Likes", currentTab: $currentTab, animation: animation)
                                TabButton(title: "Media", currentTab: $currentTab, animation: animation)
                                TabButton(title: "Likes", currentTab: $currentTab, animation: animation)
                            }
                        }
                        Divider()
                    }
                    .padding(.top, 30)
                    .background(colorScheme == .dark ? Color.black : Color.white)
                    .offset(y: tabBarOffset < 90 ? -tabBarOffset + 90 : 0)
                    .overlay(
                        GeometryReader { reader -> Color in
                            let minY = reader.frame(in: .global).minY
                            DispatchQueue.main.async {
                                self.tabBarOffset = minY
                            }
                            return Color.clear
                        }
                        .frame(width: 0, height: 0),
                        alignment: .top
                    )
                    .zIndex(1)
                    
                    // 推文列表
                    TweetListView(tweets: viewModel.tweets, viewModel: viewModel)
                        .zIndex(0)
                }
                .padding(.horizontal)
                .zIndex(-offset > 80 ? 0 : 1)
            }
        }
        .coordinateSpace(name: "scroll")
        // .toolbarBackground(.hidden, for: .navigationBar)
        .ignoresSafeArea(.all, edges: .top)
    }
    
    // MARK: - 辅助函数
    
    func getRect() -> CGRect {
        UIScreen.main.bounds
    }
    
    // 头像缩放效果：向上滚动时从 1.0 缩放到 0.8
    func getAvatarScale() -> CGFloat {
        let currentOffset = max(-offset, 0)
        let maxOffset: CGFloat = 80
        let minScale: CGFloat = 0.8
        let progress = min(currentOffset / maxOffset, 1)
        return 1.0 - progress * (1.0 - minScale)
    }
    
    // 头像垂直偏移：向上滚动时最多平移 20 点
    func getAvatarOffset() -> CGFloat {
        let currentOffset = max(-offset, 0)
        let maxOffset: CGFloat = 20
        let progress = min(currentOffset / 80, 1)
        return progress * maxOffset
    }
    
    // 标题文本上移：这里采用简单公式：上移量 = (-offset) * 0.5
    func getTitleTextOffset() -> CGFloat {
        return max(-offset, 0) * 0.5
    }
    
    // 模糊透明度：初始完全清晰，当向上滚动超过 20 点后开始模糊，到 80 点时全模糊
    func blurViewOpacity() -> Double {
        let currentOffset = max(-offset, 0)
        let startBlur: CGFloat = 20
        let fullBlur: CGFloat = 80
        if currentOffset < startBlur {
            return 0
        } else {
            let progress = min((currentOffset - startBlur) / (fullBlur - startBlur), 1)
            return Double(progress)
        }
    }
}

extension View {
    func getRect() -> CGRect {
        UIScreen.main.bounds
    }
}

// MARK: - TabButton
struct TabButton: View {
    var title: String
    @Binding var currentTab: String
    var animation: Namespace.ID
    
    var body: some View {
        Button(action: {
            withAnimation {
                currentTab = title
            }
        }, label: {
            LazyVStack(spacing: 12) {
                Text(title)
                    .fontWeight(.semibold)
                    .foregroundColor(currentTab == title ? .blue : .gray)
                    .padding(.horizontal)
                if currentTab == title {
                    Capsule()
                        .fill(Color.blue)
                        .frame(height: 1.2)
                        .matchedGeometryEffect(id: "TAB", in: animation)
                } else {
                    Capsule()
                        .fill(Color.clear)
                        .frame(height: 1.2)
                }
            }
        })
    }
}

// MARK: - TweetListView
struct TweetListView: View {
    var tweets: [Tweet]
    var viewModel: ProfileViewModel
    @Environment(\.diContainer) private var container
    @EnvironmentObject private var authViewModel: AuthState 
    var body: some View {
        VStack(spacing: 18) {
            ForEach(tweets) { tweet in
                TweetCellView(
                    viewModel: TweetCellViewModel(
                        tweet: tweet,
                        tweetService: container.resolve(.tweetService) ?? TweetService(apiClient: APIClient(baseURL: APIConfig.baseURL)),   notificationService:container.resolve(.notificationService) ?? NotificationService(apiClient:APIClient( baseURL: APIConfig.baseURL)), currentUserId: authViewModel.currentUser?.id ?? ""
                    )
                 
                )
                Divider()
            }
        }
        .padding(.top)
        .zIndex(0)
    }
}


// MARK: - Features/Search/ViewModels/SearchViewModel.swift



import SwiftUI

class SearchViewModel: ObservableObject {
    
    @Published var users = [User]()
    
    init() {
        fetchUsers()
    }
    
    func fetchUsers() {
//        AuthService.requestDomain = "http://localhost:3000/users"
//        
//        AuthService.fetchUsers { res in
//            switch res {
//                case .success(let data):
//                guard let users = try? JSONDecoder().decode([User].self, from: data!) else {
//                        return
//                    }
//                    DispatchQueue.main.async {
//                        self.users = users
//                    }
//
//                case .failure(let error):
//                    print(error.localizedDescription)
//            }
//        }
    }
    
    func filteredUsers(_ query: String) -> [User] {
        let lowercasedQuery = query.lowercased()
        return users.filter({ $0.name.lowercased().contains(lowercasedQuery) || $0.username.lowercased().contains(lowercasedQuery) })
    }
    
}


// MARK: - Features/Search/Views/SearchBar.swift

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @Binding var isEditing: Bool
    @ObserveInjection var inject

    var body: some View {
        ZStack {
            if isEditing {
                HStack {
                    // 搜索框
                    TextField("", text: $text)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        .overlay(
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.black)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 10)
                                    .opacity(text.isEmpty ? 1 : 0)
                                    .animation(nil, value: text.isEmpty)
                            }
                        )
                        .onTapGesture {
                            isEditing = true
                        }

                    // 取消按钮
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isEditing = false
                            text = ""
                            UIApplication.shared.endEditing()
                        }
                    }) {
                        Text("Cancel")
                            .foregroundColor(.black)
                    }
                }
                .transition(.opacity)
            } else {
                HStack {
                    TextField("", text: $text)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        .overlay(
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.black)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                    .padding(.leading, 10)
                            }
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isEditing = true
                            }
                        }
                }
                .transition(.opacity)
            }
        }
        .enableInjection()
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


// MARK: - Features/Search/Views/SearchCell.swift


import SwiftUI
import Kingfisher

struct SearchUserCell: View {
    
    let user: User
    
    var body: some View {
        HStack {
            KFImage(URL(string: "http://localhost:3000/users/\(self.user.id)/avatar"))
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text(user.name)
                    .fontWeight(.heavy)
                    .foregroundColor(.black)
                Text(user.username)
                    .foregroundColor(.black)
                
            }
            
            Spacer(minLength: 0)
        }
    }
}



// MARK: - Features/Search/Views/SearchView.swift

import Kingfisher
import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var authViewModel: AuthState
    @ObservedObject var viewModel = SearchViewModel()
    @ObserveInjection var inject
  @Environment(\.diContainer) private var container
    // 从 TopBar 传入的搜索状态
    @Binding var searchText: String
    @Binding var isEditing: Bool
    
    var users: [User] {
        return searchText.isEmpty ? viewModel.users : viewModel.filteredUsers(searchText)
    }

    var body: some View {
        ScrollView {
            VStack {
                LazyVStack {
                    ForEach(users) { user in
                      NavigationLink(destination: ProfileView(userId: user.id, diContainer: container)) {
                            SearchUserCell(user: user)
                                .padding(.leading)
                        }
                    }
                }
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    )
                )
            }
            .animation(
                .spring(
                    response: 0.4,
                    dampingFraction: 0.7,
                    blendDuration: 0.2
                ),
                value: isEditing
            )
        }
        .enableInjection()
    }
}


// MARK: - Resources/Resources.swift

//
//  Resources.swift
//  Demo
//
//  Created by 潘令川 on 2024/9/24.
//

import Foundation


// MARK: - Tests/UITests/AuthUITests.swift





// MARK: - Tests/UnitTests/App/DIContainerTests.swift

import XCTest
@testable import CloneTwitter

final class DIContainerTests: XCTestCase {
    var container: DIContainer!
    
    override func setUp() {
        super.setUp()
        container = DIContainer()
    }
    
    override func tearDown() {
        container.reset()
        container = nil
        super.tearDown()
    }
    
    // 测试通过字符串 key 注册和解析基本类型
    func testRegisterAndResolve_SimpleType() {
        let testString = "测试字符串"
        container.register(testString, for: "testKey")
        
        let resolved: String? = container.resolve("testKey")
        XCTAssertEqual(resolved, testString, "解析的字符串应与注册的字符串一致")
    }
    
    // 测试通过 ServiceType 枚举注册和解析协议类型
    func testRegisterAndResolve_ProtocolType() {
        let mockAPIClient = MockAPIClient()
        container.register(mockAPIClient, type: .apiClient)
        
        let resolvedClient: APIClientProtocol? = container.resolve(.apiClient)
        XCTAssertNotNil(resolvedClient, "通过 .apiClient 注册的依赖应能正确解析")
    }
    
    // 测试解析未注册的依赖时返回 nil
    func testResolveNonexistentKey() {
        let resolved: String? = container.resolve("nonexistentKey")
        XCTAssertNil(resolved, "未注册的 key 应返回 nil")
    }
    
    // 测试调用 reset() 后，所有依赖均被清除
    func testResetContainer() {
        container.register("testValue", for: "testKey")
        container.reset()
        
        let resolved: String? = container.resolve("testKey")
        XCTAssertNil(resolved, "reset() 后容器中不应存在已注册的依赖")
    }
}


// MARK: - Tests/UnitTests/AuthTests.swift


import XCTest
@testable import CloneTwitter

// MARK: - 模拟 APIClient

final class MockAPIClient: APIClientProtocol {
    // 用于控制模拟返回的数据或错误
    var resultData: Data?
    var resultError: Error?
    
    func sendRequest<T>(_ endpoint: APIEndpoint) async throws -> T where T: Decodable {
        if let error = resultError {
            throw error
        }
        guard let data = resultData else {
            throw NetworkError.invalidResponse
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }
}

// MARK: - 单元测试

final class AuthServiceTests: XCTestCase {
    
    var authService: AuthService1!
    var mockAPIClient: MockAPIClient!
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        authService = AuthService1(apiClient: mockAPIClient)
        // 清除 UserDefaults 中的 token 测试数据
        UserDefaults.standard.removeObject(forKey: "jwt")
    }
    
    override func tearDown() {
        authService = nil
        mockAPIClient = nil
        UserDefaults.standard.removeObject(forKey: "jwt")
        super.tearDown()
    }
    
    // 测试 login 成功返回
    func testLoginSuccess() async throws {
        // 构造一个模拟的 APIResponse JSON
        let jsonString = """
        {
            "user": {
                "_id": "12345",
                "username": "testuser",
                "name": "Test User",
                "email": "test@example.com",
                "followers": [],
                "following": []
            },
            "token": "test_token"
        }
        """
        mockAPIClient.resultData = jsonString.data(using: .utf8)
        
        // 调用 login 方法
        let response = try await authService.login(email: "test@example.com", password: "password")
        
        // 验证返回值
        XCTAssertEqual(response.token, "test_token")
        XCTAssertEqual(response.user.id, "12345")
        XCTAssertEqual(response.user.username, "testuser")
        
        // 检查 token 是否保存到了 UserDefaults
        let savedToken = UserDefaults.standard.string(forKey: "jwt")
        XCTAssertEqual(savedToken, "test_token")
    }
    
    // 测试 register 成功返回
    func testRegisterSuccess() async throws {
        // 构造一个模拟的 User JSON
        let jsonString = """
        {
            "_id": "54321",
            "username": "newuser",
            "name": "New User",
            "email": "new@example.com",
            "followers": [],
            "following": []
        }
        """
        mockAPIClient.resultData = jsonString.data(using: .utf8)
        
        let user = try await authService.register(
            email: "new@example.com",
            username: "newuser",
            password: "password",
            name: "New User"
        )
        
        XCTAssertEqual(user.id, "54321")
        XCTAssertEqual(user.username, "newuser")
        XCTAssertEqual(user.name, "New User")
        XCTAssertEqual(user.email, "new@example.com")
    }
    
    // 测试 fetchCurrentUser 成功返回
    func testFetchCurrentUserSuccess() async throws {
        let jsonString = """
        {
            "_id": "12345",
            "username": "currentuser",
            "name": "Current User",
            "email": "current@example.com",
            "followers": [],
            "following": []
        }
        """
        mockAPIClient.resultData = jsonString.data(using: .utf8)
        
        let user = try await authService.fetchCurrentUser()
        
        XCTAssertEqual(user.id, "12345")
        XCTAssertEqual(user.username, "currentuser")
        XCTAssertEqual(user.email, "current@example.com")
    }
    
    // 测试 updateProfile 成功返回
    func testUpdateProfileSuccess() async throws {
        // 模拟更新后的用户 JSON
        let jsonString = """
        {
            "_id": "12345",
            "username": "currentuser",
            "name": "Updated User",
            "email": "current@example.com",
            "bio": "New bio",
            "followers": [],
            "following": []
        }
        """
        mockAPIClient.resultData = jsonString.data(using: .utf8)
        
        let updateData: [String: Any] = ["name": "Updated User", "bio": "New bio"]
        let user = try await authService.updateProfile(data: updateData)
        
        XCTAssertEqual(user.name, "Updated User")
        XCTAssertEqual(user.bio, "New bio")
    }
    
    // 测试 login 失败（例如返回 401）
    func testLoginFailure() async {
        // 设置模拟错误
        mockAPIClient.resultError = NetworkError.unauthorized
        
        do {
            _ = try await authService.login(email: "test@example.com", password: "password")
            XCTFail("Expected login to throw unauthorized error")
        } catch NetworkError.unauthorized {
            // 正常捕获 401 错误
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}


// MARK: - Tests/UnitTests/Network/APIClientTests.swift


import XCTest

@testable import CloneTwitter

final class APIClientTests: XCTestCase {
    var sut: APIClient!
    var mockSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        sut = APIClient(baseURL: URL(string: "http://localhost:3000")!, session: mockSession)

    }
    
    override func tearDown() {
        sut = nil
        mockSession = nil
        super.tearDown()
    }
    
    func testSendRequestSuccess() async throws {
        // Arrange（准备）
        let mockData = """
        {
            "_id": "123",
            "username": "test",
            "email": "test@example.com",
            "name": "Test User"
        }
        """.data(using: .utf8)!
        
        // 设置 Mock 响应
        let httpResponse = HTTPURLResponse(
            url: URL(string: "http://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        mockSession.mockResult = .success((mockData, httpResponse))
        let endpoint = MockEndpoint(path: "/test", method: .get)
        
        // Act（执行）
        let user: User = try await sut.sendRequest(endpoint)
        
        // Assert（断言）
        XCTAssertEqual(user.id, "123")
        XCTAssertEqual(user.username, "test")
        XCTAssertEqual(user.email, "test@example.com")
    }
    
    func testSendRequestFailure() async {
        // Arrange（准备）
        let httpResponse = HTTPURLResponse(
            url: URL(string: "http://test.com")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )!
        mockSession.mockResult = .success((Data(), httpResponse))
        let endpoint = MockEndpoint(path: "/test", method: .get)
        
        // Act & Assert（执行和断言）
        do {
            let _: User = try await sut.sendRequest(endpoint)
            XCTFail("应该抛出错误")
        } catch {
            XCTAssertEqual(error as? NetworkError, .unauthorized)
        }
    }
}

// MARK: - MockURLSession 实现

class MockURLSession: URLSessionProtocol {
    /// 用于注入预设的返回值，格式为 Result<(Data, URLResponse), Error>
    var mockResult: Result<(Data, URLResponse), Error>?
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let result = mockResult {
            return try result.get()
        }
        // 若未设置 mockResult，则返回空数据与默认 URLResponse
        return (Data(), URLResponse())
    }
}
extension NetworkError: Equatable {
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.noData, .noData),
             (.unauthorized, .unauthorized),
             (.noToken, .noToken),
             (.serverError, .serverError),
             (.maxRetriesExceeded, .maxRetriesExceeded):
            return true
        case (.httpError(let l), .httpError(let r)):
            return l == r
        case (.clientError(let l), .clientError(let r)):
            return l?.message == r?.message
        case (.custom(let l), .custom(let r)):
            return l == r
        default:
            return false
        }
    }
}
/// 用于测试的 MockEndpoint
struct MockEndpoint: APIEndpoint {
    var path: String
    var method: HTTPMethod
    var queryItems: [URLQueryItem]? = nil
    var headers: [String: String]? = nil
    var body: Data? = nil
}


// MARK: - Tests/UnitTests/NetworkTests.swift



// MARK: - Tests/UnitTests/ViewModels/AuthStateTests.swift

import XCTest
@testable import CloneTwitter


@MainActor
final class AuthStateTests: XCTestCase {
    var sut: AuthState!
    var mockAuthService: MockAuthService!
    
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        sut = AuthState(authService: mockAuthService)
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "jwt")
        sut = nil
        mockAuthService = nil
        super.tearDown()
    }
    
    // MARK: - 登录测试
    
    func testLoginSuccess() async {
        // 准备
        mockAuthService.shouldSucceed = true
        
        // 执行
        await sut.login(email: "test@example.com", password: "password")
        
        // 验证
        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertNotNil(sut.currentUser)
        XCTAssertNil(sut.error)
        XCTAssertFalse(sut.isLoading)
    }
    
    func testLoginFailure() async {
        // 准备
        mockAuthService.shouldSucceed = false
        
        // 执行
        await sut.login(email: "test@example.com", password: "wrong")
        
        // 验证
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNil(sut.currentUser)
        XCTAssertNotNil(sut.error)
        XCTAssertFalse(sut.isLoading)
    }
    
    // MARK: - 注册测试
    
    func testRegisterSuccess() async {
        // 准备
        mockAuthService.shouldSucceed = true
        
        // 执行
        await sut.register(
            email: "new@example.com",
            username: "newuser",
            password: "password",
            name: "New User"
        )
        
        // 验证
        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertNotNil(sut.currentUser)
        XCTAssertNil(sut.error)
        XCTAssertFalse(sut.isLoading)
    }
    
    func testRegisterFailure() async {
        // 准备
        mockAuthService.shouldSucceed = false
        
        // 执行
        await sut.register(
            email: "invalid@example.com",
            username: "invalid",
            password: "password",
            name: "Invalid User"
        )
        
        // 验证
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNil(sut.currentUser)
        XCTAssertNotNil(sut.error)
        XCTAssertFalse(sut.isLoading)
    }
    
    // MARK: - 登出测试
    
    func testSignOut() {
        // 准备：先设置认证状态
        sut.currentUser = User.mock
        sut.isAuthenticated = true
        UserDefaults.standard.set("test_token", forKey: "jwt")
        
        // 执行
        sut.signOut()
        
        // 验证
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNil(sut.currentUser)
        XCTAssertNil(UserDefaults.standard.string(forKey: "jwt"))
    }
    
    // MARK: - 状态检查测试
    
    func testCheckAuthStatusWithValidToken() async {
        // 准备
        mockAuthService.shouldSucceed = true
        UserDefaults.standard.set("valid_token", forKey: "jwt")
        
        // 执行：创建新的 AuthState 实例会自动调用 checkAuthStatus
        let authState = AuthState(authService: mockAuthService)
        // 等待异步操作完成
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // 验证
        XCTAssertTrue(authState.isAuthenticated)
        XCTAssertNotNil(authState.currentUser)
        XCTAssertNil(authState.error)
    }
    
    func testCheckAuthStatusWithInvalidToken() async {
        // 准备
        mockAuthService.shouldSucceed = false
        UserDefaults.standard.set("invalid_token", forKey: "jwt")
        
        // 执行：创建新的 AuthState 实例会自动调用 checkAuthStatus
        let authState = AuthState(authService: mockAuthService)
        // 等待异步操作完成
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // 验证
        XCTAssertFalse(authState.isAuthenticated)
        XCTAssertNil(authState.currentUser)
        XCTAssertNotNil(authState.error)
    }
    
    // MARK: - 更新个人资料测试
    
    func testUpdateProfileSuccess() async {
        // 准备
        mockAuthService.shouldSucceed = true
        
        // 执行
        await sut.updateProfile(data: ["name": "Updated Name", "bio": "New bio"])
        
        // 验证
        XCTAssertNotNil(sut.currentUser)
        XCTAssertNil(sut.error)
        XCTAssertFalse(sut.isLoading)
    }
    
    func testUpdateProfileFailure() async {
        // 准备
        mockAuthService.shouldSucceed = false
        
        // 执行
        await sut.updateProfile(data: ["name": "Updated Name"])
        
        // 验证
        XCTAssertNotNil(sut.error)
        XCTAssertFalse(sut.isLoading)
    }
}

