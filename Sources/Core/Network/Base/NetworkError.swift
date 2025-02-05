import Foundation

// 删除旧的定义，使用统一的 NetworkError
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    case serverError(String)
    case noData
    case unauthorized
    case unknown(Error)
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
        case .serverError(let message):
            return "服务器错误: \(message)"
        case .noData:
            return "没有数据"
        case .unauthorized:
            return "未授权访问"
        case .unknown(let error):
            return "未知错误: \(error.localizedDescription)"
        case .noToken:
            return "缺少认证令牌"
        case .custom(let message):
            return message
        }
    }
}