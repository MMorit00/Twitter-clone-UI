-- a/Sources/App/DIContainer.swift
+++ b/Sources/App/DIContainer.swift
@@ -50,7 +50,7 @@ final class DIContainer {
         container.register(apiClient, type: .apiClient)
         
         // 配置 AuthService
+        let authService = AuthService1(apiClient: apiClient)
         container.register(authService, type: .authService)
         
         // 配置业务服务
--- a/Sources/Features/Auth/Services/authService.swift
+++ b/Sources/Features/Auth/Services/authService.swift
@@ -14,45 +14,45 @@ struct APIResponse: Codable {
     let token: String
 }
 
+import Foundation
+
+final class AuthService1: AuthServiceProtocol {
+    private let apiClient: APIClientProtocol
+
+    init(apiClient: APIClientProtocol) {
+        self.apiClient = apiClient
+    }
+
+    func login(email: String, password: String) async throws -> APIResponse {
+        let endpoint = AuthEndpoint.login(email: email, password: password)
+        let response: APIResponse = try await apiClient.sendRequest(endpoint)
+
+        // 保存 token
+        UserDefaults.standard.set(response.token, forKey: "jwt")
+
+        return response
+    }
+
+    func register(email: String, username: String, password: String, name: String) async throws -> User {
+        let endpoint = AuthEndpoint.register(
+            email: email,
+            username: username,
+            password: password,
+            name: name
+        )
+        return try await apiClient.sendRequest(endpoint)
+    }
+
+    func fetchCurrentUser() async throws -> User {
+        let endpoint = AuthEndpoint.fetchCurrentUser
+        return try await apiClient.sendRequest(endpoint)
+    }
+
+    func updateProfile(data: [String: Any]) async throws -> User {
+        let endpoint = AuthEndpoint.updateProfile(data: data)
+        return try await apiClient.sendRequest(endpoint)
+    }
+}
 
 // MARK: - Mock 实现，用于测试
 
--- a/Sources/Tests/UnitTests/App/DIContainerTests.swift
+++ b/Sources/Tests/UnitTests/App/DIContainerTests.swift
@@ -10,47 +10,41 @@ final class DIContainerTests: XCTestCase {
     }
     
     override func tearDown() {
+        container.reset()
         container = nil
         super.tearDown()
     }
     
+    // 测试通过字符串 key 注册和解析基本类型
+    func testRegisterAndResolve_SimpleType() {
         let testString = "测试字符串"
         container.register(testString, for: "testKey")
         
         let resolved: String? = container.resolve("testKey")
+        XCTAssertEqual(resolved, testString, "解析的字符串应与注册的字符串一致")
+    }
+    
+    // 测试通过 ServiceType 枚举注册和解析协议类型
+    func testRegisterAndResolve_ProtocolType() {
         let mockAPIClient = MockAPIClient()
         container.register(mockAPIClient, type: .apiClient)
         
         let resolvedClient: APIClientProtocol? = container.resolve(.apiClient)
+        XCTAssertNotNil(resolvedClient, "通过 .apiClient 注册的依赖应能正确解析")
     }
     
+    // 测试解析未注册的依赖时返回 nil
+    func testResolveNonexistentKey() {
         let resolved: String? = container.resolve("nonexistentKey")
+        XCTAssertNil(resolved, "未注册的 key 应返回 nil")
     }
     
+    // 测试调用 reset() 后，所有依赖均被清除
+    func testResetContainer() {
+        container.register("testValue", for: "testKey")
         container.reset()
         
         let resolved: String? = container.resolve("testKey")
+        XCTAssertNil(resolved, "reset() 后容器中不应存在已注册的依赖")
     }
 }
--- a/Sources/Tests/UnitTests/AuthTests.swift
+++ b/Sources/Tests/UnitTests/AuthTests.swift
@@ -0,0 +1,164 @@
+
+import XCTest
+@testable import CloneTwitter
+
+// MARK: - 模拟 APIClient
+
+final class MockAPIClient: APIClientProtocol {
+    // 用于控制模拟返回的数据或错误
+    var resultData: Data?
+    var resultError: Error?
+    
+    func sendRequest<T>(_ endpoint: APIEndpoint) async throws -> T where T: Decodable {
+        if let error = resultError {
+            throw error
+        }
+        guard let data = resultData else {
+            throw NetworkError.invalidResponse
+        }
+        let decoder = JSONDecoder()
+        decoder.keyDecodingStrategy = .convertFromSnakeCase
+        return try decoder.decode(T.self, from: data)
+    }
+}
+
+// MARK: - 单元测试
+
+final class AuthServiceTests: XCTestCase {
+    
+    var authService: AuthService1!
+    var mockAPIClient: MockAPIClient!
+    
+    override func setUp() {
+        super.setUp()
+        mockAPIClient = MockAPIClient()
+        authService = AuthService1(apiClient: mockAPIClient)
+        // 清除 UserDefaults 中的 token 测试数据
+        UserDefaults.standard.removeObject(forKey: "jwt")
+    }
+    
+    override func tearDown() {
+        authService = nil
+        mockAPIClient = nil
+        UserDefaults.standard.removeObject(forKey: "jwt")
+        super.tearDown()
+    }
+    
+    // 测试 login 成功返回
+    func testLoginSuccess() async throws {
+        // 构造一个模拟的 APIResponse JSON
+        let jsonString = """
+        {
+            "user": {
+                "_id": "12345",
+                "username": "testuser",
+                "name": "Test User",
+                "email": "test@example.com",
+                "followers": [],
+                "following": []
+            },
+            "token": "test_token"
+        }
+        """
+        mockAPIClient.resultData = jsonString.data(using: .utf8)
+        
+        // 调用 login 方法
+        let response = try await authService.login(email: "test@example.com", password: "password")
+        
+        // 验证返回值
+        XCTAssertEqual(response.token, "test_token")
+        XCTAssertEqual(response.user.id, "12345")
+        XCTAssertEqual(response.user.username, "testuser")
+        
+        // 检查 token 是否保存到了 UserDefaults
+        let savedToken = UserDefaults.standard.string(forKey: "jwt")
+        XCTAssertEqual(savedToken, "test_token")
+    }
+    
+    // 测试 register 成功返回
+    func testRegisterSuccess() async throws {
+        // 构造一个模拟的 User JSON
+        let jsonString = """
+        {
+            "_id": "54321",
+            "username": "newuser",
+            "name": "New User",
+            "email": "new@example.com",
+            "followers": [],
+            "following": []
+        }
+        """
+        mockAPIClient.resultData = jsonString.data(using: .utf8)
+        
+        let user = try await authService.register(
+            email: "new@example.com",
+            username: "newuser",
+            password: "password",
+            name: "New User"
+        )
+        
+        XCTAssertEqual(user.id, "54321")
+        XCTAssertEqual(user.username, "newuser")
+        XCTAssertEqual(user.name, "New User")
+        XCTAssertEqual(user.email, "new@example.com")
+    }
+    
+    // 测试 fetchCurrentUser 成功返回
+    func testFetchCurrentUserSuccess() async throws {
+        let jsonString = """
+        {
+            "_id": "12345",
+            "username": "currentuser",
+            "name": "Current User",
+            "email": "current@example.com",
+            "followers": [],
+            "following": []
+        }
+        """
+        mockAPIClient.resultData = jsonString.data(using: .utf8)
+        
+        let user = try await authService.fetchCurrentUser()
+        
+        XCTAssertEqual(user.id, "12345")
+        XCTAssertEqual(user.username, "currentuser")
+        XCTAssertEqual(user.email, "current@example.com")
+    }
+    
+    // 测试 updateProfile 成功返回
+    func testUpdateProfileSuccess() async throws {
+        // 模拟更新后的用户 JSON
+        let jsonString = """
+        {
+            "_id": "12345",
+            "username": "currentuser",
+            "name": "Updated User",
+            "email": "current@example.com",
+            "bio": "New bio",
+            "followers": [],
+            "following": []
+        }
+        """
+        mockAPIClient.resultData = jsonString.data(using: .utf8)
+        
+        let updateData: [String: Any] = ["name": "Updated User", "bio": "New bio"]
+        let user = try await authService.updateProfile(data: updateData)
+        
+        XCTAssertEqual(user.name, "Updated User")
+        XCTAssertEqual(user.bio, "New bio")
+    }
+    
+    // 测试 login 失败（例如返回 401）
+    func testLoginFailure() async {
+        // 设置模拟错误
+        mockAPIClient.resultError = NetworkError.unauthorized
+        
+        do {
+            _ = try await authService.login(email: "test@example.com", password: "password")
+            XCTFail("Expected login to throw unauthorized error")
+        } catch NetworkError.unauthorized {
+            // 正常捕获 401 错误
+        } catch {
+            XCTFail("Unexpected error: \(error)")
+        }
+    }
+}