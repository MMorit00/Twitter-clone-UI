import Foundation

// 删除旧的定义，使用统一的 NetworkError
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    case serverError
    case clientError(APIError?)
    case unauthorized
    case noData
    case maxRetriesExceeded
    case noToken
    case custom(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .invalidResponse:
            return "无效的响应"
        case .httpError(let code):
            return "HTTP错误: \(code)"
        case .decodingError(let error):
            return "数据解析错误: \(error.localizedDescription)"
        case .serverError:
            return "服务器错误"
        case .clientError(let apiError):
            return apiError?.message ?? "客户端错误"
        case .unauthorized:
            return "未授权访问"
        case .noData:
            return "没有数据"
        case .maxRetriesExceeded:
            return "超过最大重试次数"
        case .noToken:
            return "未找到访问令牌"
        case .custom(let message):
            return message
        }
    }
}