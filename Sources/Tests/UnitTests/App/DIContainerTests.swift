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
