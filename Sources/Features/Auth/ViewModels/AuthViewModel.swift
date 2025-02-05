import Foundation
import SwiftUI

class AuthViewModel: ObservableObject {
    // 添加静态共享实例
    static let shared = AuthViewModel()

    @Published var isAuthenticated: Bool = false
    @Published var user: User?
    @Published var error: Error?

    // 用于存储用户凭证
    @AppStorage("jwt") var token: String = ""
    @AppStorage("userId") var userId: String = ""

    // 将 init() 改为私有,确保只能通过 shared 访问
    private init() {
        // 初始化时检查认证状态
        checkAuthStatus()
    }

    private func checkAuthStatus() {
        // 如果有token和userId,尝试获取用户信息
        if !token.isEmpty && !userId.isEmpty {
            fetchUser()
        }
    }

   // 在 AuthViewModel 的 login 方法中
func login(email: String, password: String) {
    AuthService.login(email: email, password: password) { [weak self] result in
        DispatchQueue.main.async {
            switch result {
            case let .success(response):
                // 保存 token 和 userId (如果 token 为 nil，则赋值为空字符串)
                self?.token = response.token ?? ""
                self?.userId = response.user.id
                // 保存用户信息
                self?.user = response.user
                // 更新认证状态
                self?.isAuthenticated = true
                print("Logged in successfully")

            case let .failure(error):
                // 处理错误
                self?.error = error
                print("Login error: \(error)")
            }
        }
    }
}

    // 注册方法
   func register(name: String, username: String, email: String, password: String) async throws {
     try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
        AuthService.register(
            email: email,
            username: username,
            password: password,
            name: name
        ) { [weak self] result in
            guard let self = self else {
                continuation.resume(throwing: AuthService.AuthenticationError.custom("Self is nil"))
                return
            }
            
            switch result {
            case let .success(user):
                // 更新用户信息（此时还没有 token, 所以接下来调用 login 获取 token）
                DispatchQueue.main.async {
                    self.user = user
                    // 进行登录来获取 token
                    self.login(email: email, password: password)
                    continuation.resume()
                }
                
            case let .failure(error):
                DispatchQueue.main.async {
                    self.error = error
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

    // 登出方法
    func signOut() {
        // 清除用户数据和token
        isAuthenticated = false
        user = nil
        token = ""
        userId = ""
    }

    // 验证token是否有效
    func validateToken() {
        // TODO: 实现token验证
    }

    private func fetchUser() {
        guard !token.isEmpty && !userId.isEmpty else { return }

        AuthService.fetchUser(userId: userId, token: token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(user): // 直接使用返回的 user 对象
                    self?.user = user
                    self?.isAuthenticated = true
                case let .failure(error):
                    self?.error = error
                    self?.signOut() // 如果获取用户信息失败,清除认证状态
                }
            }
        }
    }

    // 添加更新用户方法
    func updateUser(_ updatedUser: User) {
        DispatchQueue.main.async {
            self.user = updatedUser
            // 可以在这里添加持久化逻辑
        }
    }

    // 修改更新方法,添加 transaction 支持
    func updateCurrentUser(_ updatedUser: User, transaction: Transaction = .init()) {
        withTransaction(transaction) {
            // 只更新 following/followers 相关数据
            if let currentUser = self.user {
                var newUser = currentUser
                newUser.following = updatedUser.following
                newUser.followers = updatedUser.followers
                self.user = newUser
            }
        }
    }

    // 添加静默更新方法
    func silentlyUpdateFollowing(_ following: [String]) {
        if var currentUser = user {
            currentUser.following = following
            // 直接更新，不触发 objectWillChange
            user = currentUser
        }
    }
}
