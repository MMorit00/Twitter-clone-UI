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
