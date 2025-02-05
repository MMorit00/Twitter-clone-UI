import Foundation

protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

protocol APIClientProtocol {
    func sendRequest<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}

final class APIClient: APIClientProtocol {
    private let baseURL: URL
    private let session: URLSessionProtocol

    init(baseURL: URL, session: URLSessionProtocol = URLSession.shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func sendRequest<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        // 1. 构建完整的URL
        var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path),
                                       resolvingAgainstBaseURL: true)
        components?.queryItems = endpoint.queryItems

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        // 2. 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body

        // 3. 添加默认headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        // 4. 发送请求
        let (data, response) = try await session.data(for: request)

        // 5. 验证响应
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        // 6. 检查状态码
        switch httpResponse.statusCode {
        case 200 ... 299:
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError(error)
            }
        case 401:
            throw NetworkError.unauthorized
        case 400 ... 499:
            throw NetworkError.httpError(httpResponse.statusCode)
        case 500 ... 599:
            throw NetworkError.serverError("服务器错误: \(httpResponse.statusCode)")
        default:
            throw NetworkError.httpError(httpResponse.statusCode)
        }
    }
}
