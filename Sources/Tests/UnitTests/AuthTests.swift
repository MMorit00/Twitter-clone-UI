
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
