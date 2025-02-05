
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
             (.noToken, .noToken):
            return true
        case (.httpError(let l), .httpError(let r)):
            return l == r
        case (.serverError(let l), .serverError(let r)):
            return l == r
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
