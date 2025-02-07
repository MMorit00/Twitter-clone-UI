import Foundation

enum NotificationEndpoint: APIEndpoint {
    case fetchNotifications(userId: String)
    case createNotification(username: String, receiverId: String, type: NotificationType, postText: String?)
    
    var path: String {
        switch self {
        case .fetchNotifications(let userId):
            return "/notifications/\(userId)"
        case .createNotification:
            return "/notifications"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchNotifications:
            return .get
        case .createNotification:
            return .post
        }
    }
    
    var body: Data? {
        switch self {
        case .fetchNotifications:
            return nil
        case let .createNotification(username, receiverId, type, postText):
            var params: [String: Any] = [
                "username": username,
                "notificationReceiverId": receiverId,
                "notificationType": type.rawValue
            ]
            if let postText = postText {
                params["postText"] = postText
            }
            return try? JSONSerialization.data(withJSONObject: params)
        }
    }
    
    var headers: [String: String]? {
        var headers = ["Content-Type": "application/json"]
        if let token = UserDefaults.standard.string(forKey: "jwt") {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }
    
    var queryItems: [URLQueryItem]? {
        return nil
    }
}