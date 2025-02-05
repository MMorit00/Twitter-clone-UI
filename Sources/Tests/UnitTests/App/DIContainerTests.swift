import XCTest
@testable import CloneTwitter

final class DIContainerTests: XCTestCase {
    var container: DIContainer!
    
    override func setUp() {
        super.setUp()
        container = DIContainer()
    }
    
    override func tearDown() {
        container = nil
        super.tearDown()
    }
    
    func testRegisterAndResolve() {
        // 1. 测试注册和解析基本类型
        let testString = "测试字符串"
        container.register(testString, for: "testKey")
        
        let resolved: String? = container.resolve("testKey")
        XCTAssertEqual(resolved, testString)
        
        // 2. 测试注册和解析协议类型
        let mockAPIClient = MockAPIClient()
        container.register(mockAPIClient, type: .apiClient)
        
        let resolvedClient: APIClientProtocol? = container.resolve(.apiClient)
        XCTAssertNotNil(resolvedClient)
    }
    
    func testResolveNonexistent() {
        let resolved: String? = container.resolve("nonexistentKey")
        XCTAssertNil(resolved)
    }
    
    func testReset() {
        // 1. 注册一些依赖
        container.register("test", for: "testKey")
        
        // 2. 重置容器
        container.reset()
        
        // 3. 验证依赖已被清除
        let resolved: String? = container.resolve("testKey")
        XCTAssertNil(resolved)
    }
}

// Mock APIClient for testing
private class MockAPIClient: APIClientProtocol {
    func sendRequest<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        throw NetworkError.invalidURL // 简单实现
    }
}
