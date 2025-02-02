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

    // 登录方法
    func login(email: String, password: String) {
        AuthService.login(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(response):
                    // 保存token和userId
                    self?.token = response.token
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
    func register(name: String, username: String, email: String, password: String) {
        // 调用 AuthService 的 register 方法
        AuthService.register(
            email: email,
            username: username,
            password: password,
            name: name
        ) { [weak self] result in
            // 确保在主线程更新 UI
            DispatchQueue.main.async {
                switch result {
                case let .success(response):
                    // 处理成功响应
                    self?.user = response.user
                    // 可以保存 token 等其他操作

                case let .failure(error):
                    // 处理错误
                    switch error {
                    case .invalidCredentials:
                        print("Invalid credentials")
                    case let .custom(message):
                        print("Error: \(message)")
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
}
