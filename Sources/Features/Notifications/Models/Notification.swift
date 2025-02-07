import Foundation

// 通知类型枚举
enum NotificationType: String, Codable {
    case like
    case follow
    
    var message: String {
        switch self {
        case .like: return "点赞了你的推文"
        case .follow: return "关注了你"
        }
    }
}

struct Notification: Identifiable, Codable {
    let id: String
    let notificationSenderId: String
    let notificationReceiverId: String
    let notificationType: NotificationType
    let postText: String?
    let createdAt: Date
    var senderUsername: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case notificationSenderId
        case notificationReceiverId
        case notificationType
        case postText
        case createdAt
    }
    
    // 定义内部用于解析发送者信息的 key
    enum SenderKeys: String, CodingKey {
        case id = "_id"
        case username
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        
        // 对 notificationSenderId 字段进行嵌套解码
        let senderContainer = try container.nestedContainer(keyedBy: SenderKeys.self, forKey: .notificationSenderId)
        notificationSenderId = try senderContainer.decode(String.self, forKey: .id)
        senderUsername = try senderContainer.decode(String.self, forKey: .username)
        
        notificationReceiverId = try container.decode(String.self, forKey: .notificationReceiverId)
        notificationType = try container.decode(NotificationType.self, forKey: .notificationType)
        postText = try container.decodeIfPresent(String.self, forKey: .postText)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
}