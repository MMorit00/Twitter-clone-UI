import Foundation

/// 定义网络请求协议，用于依赖注入和测试
protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

/// API客户端协议
protocol APIClientProtocol {
    func sendRequest<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
    func sendRequestWithoutDecoding(_ endpoint: APIEndpoint) async throws
}

/// API客户端实现，处理所有网络请求
final class APIClient: APIClientProtocol {
    private let baseURL: URL
    private let session: URLSessionProtocol
    private let maxRetries: Int

    init(baseURL: URL,
         session: URLSessionProtocol = URLSession.shared,
         maxRetries: Int = 3)
    {
        self.baseURL = baseURL
        self.session = session
        self.maxRetries = maxRetries
    }

    /// 发送网络请求，支持自动重试机制
    func sendRequest<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        var attempts = 0

        while attempts < maxRetries {
            do {
                return try await performRequest(endpoint)
            } catch NetworkError.unauthorized {
                throw NetworkError.unauthorized
            } catch NetworkError.serverError {
                attempts += 1
                if attempts == maxRetries {
                    throw NetworkError.maxRetriesExceeded
                }
                // 指数退避重试
                try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempts))) * 1_000_000_000)
                continue
            }
        }

        throw NetworkError.maxRetriesExceeded
    }

    /// 执行实际的网络请求并处理响应
    private func performRequest<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path),
                                       resolvingAgainstBaseURL: true)
        components?.queryItems = endpoint.queryItems

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        // 添加：避免使用缓存
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        #if DEBUG
            logRequest(request)
        #endif

        let (data, response) = try await session.data(for: request)

        #if DEBUG
            logResponse(response, data: data)
        #endif

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200 ... 299:
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                // 创建自定义的 ISO8601 格式化器，并支持毫秒
                let isoFormatter = ISO8601DateFormatter()
                isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

                // 设置自定义日期解码策略
                decoder.dateDecodingStrategy = .custom { decoder -> Date in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    if let date = isoFormatter.date(from: dateString) {
                        return date
                    }
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "无法解析日期字符串: \(dateString)")
                }

                return try decoder.decode(T.self, from: data)
            } catch {
                #if DEBUG
                    print("解码错误: \(error)")
                    if let json = String(data: data, encoding: .utf8) {
                        print("原始JSON: \(json)")
                    }
                #endif
                throw NetworkError.decodingError(error)
            }
        case 401:
            throw NetworkError.unauthorized
        case 400 ... 499:
            throw NetworkError.clientError(try? decodeErrorResponse(from: data))
        case 500 ... 599:
            throw NetworkError.serverError
        default:
            throw NetworkError.httpError(httpResponse.statusCode)
        }
    }

  /// 新增方法：发送请求但不对响应内容进行解码，用于图片上传等返回数据格式不确定的接口
   func sendRequestWithoutDecoding(_ endpoint: APIEndpoint) async throws {
       var attempts = 0

       while attempts < maxRetries {
           do {
               try await performRequestWithoutDecoding(endpoint)
               return
           } catch NetworkError.serverError {
               attempts += 1
               if attempts == maxRetries {
                   throw NetworkError.maxRetriesExceeded
               }
               try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempts))) * 1_000_000_000)
           }
       }

       throw NetworkError.maxRetriesExceeded
   }

   /// 执行实际网络请求但不进行数据解码
   private func performRequestWithoutDecoding(_ endpoint: APIEndpoint) async throws {
       var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path),
                                      resolvingAgainstBaseURL: true)
       components?.queryItems = endpoint.queryItems

       guard let url = components?.url else {
           throw NetworkError.invalidURL
       }

       var request = URLRequest(url: url)
       request.httpMethod = endpoint.method.rawValue
       request.httpBody = endpoint.body
       request.cachePolicy = .reloadIgnoringLocalCacheData
        
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return  // 成功，不解析返回数据
        case 401:
            throw NetworkError.unauthorized
        case 400...499:
            throw NetworkError.clientError(try? decodeErrorResponse(from: data))
        case 500...599:
            throw NetworkError.serverError
        default:
            throw NetworkError.httpError(httpResponse.statusCode)
        }
   }
  
  
    #if DEBUG
        private func logRequest(_ request: URLRequest) {
            print("🚀 发送请求: \(request.httpMethod ?? "Unknown") \(request.url?.absoluteString ?? "")")
            if let headers = request.allHTTPHeaders {
                print("📋 Headers: \(headers)")
            }
            if let body = request.httpBody,
               let json = String(data: body, encoding: .utf8)
            {
                print("📦 Body: \(json)")
            }
        }

        private func logResponse(_ response: URLResponse, data: Data) {
            guard let httpResponse = response as? HTTPURLResponse else { return }
            print("📥 收到响应: \(httpResponse.statusCode)")
            if let json = String(data: data, encoding: .utf8) {
                print("📄 Response: \(json)")
            }
        }
    #endif

    private func decodeErrorResponse(from data: Data) throws -> APIError {
        return try JSONDecoder().decode(APIError.self, from: data)
    }
}

// 扩展 URLRequest 以方便访问所有 headers
private extension URLRequest {
    var allHTTPHeaders: [String: String]? {
        return allHTTPHeaderFields
    }
}

// API 错误响应模型
struct APIError: Codable {
    let message: String
    let code: String?
}
