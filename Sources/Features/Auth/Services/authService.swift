
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

// import Foundation

// final class AuthService: AuthServiceProtocol {
//     private let apiClient: APIClientProtocol

//     init(apiClient: APIClientProtocol) {
//         self.apiClient = apiClient
//     }

//     func login(email: String, password: String) async throws -> APIResponse {
//         let endpoint = AuthEndpoint.login(email: email, password: password)
//         let response: APIResponse = try await apiClient.sendRequest(endpoint)

//         // 保存 token
//         UserDefaults.standard.set(response.token, forKey: "jwt")

//         return response
//     }

//     func register(email: String, username: String, password: String, name: String) async throws -> User {
//         let endpoint = AuthEndpoint.register(
//             email: email,
//             username: username,
//             password: password,
//             name: name
//         )
//         return try await apiClient.sendRequest(endpoint)
//     }

//     func fetchCurrentUser() async throws -> User {
//         let endpoint = AuthEndpoint.fetchCurrentUser
//         return try await apiClient.sendRequest(endpoint)
//     }

//     func updateProfile(data: [String: Any]) async throws -> User {
//         let endpoint = AuthEndpoint.updateProfile(data: data)
//         return try await apiClient.sendRequest(endpoint)
//     }
// }

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

    private extension User {
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
