import Foundation
import SwiftUI

struct Tweet: Identifiable, Decodable,Equatable {
    // MongoDB的_id字段
    let _id: String
    let text: String
    let userId: String
    let username: String
    let user: String

    // 可选字段,后续功能预留
    var image: Bool?
    var likes: [String]?

    // 满足Identifiable协议
    var id: String {
        _id
    }

    // 处理JSON字段映射
    enum CodingKeys: String, CodingKey {
        case _id
        case text
        case userId
        case username
        case user
        case image
        case likes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        _id = try container.decode(String.self, forKey: ._id)
        text = try container.decode(String.self, forKey: .text)

        // 处理嵌套的用户信息
        if let userId = try? container.decode([String: String].self, forKey: .userId) {
            self.userId = userId["_id"] ?? ""
            user = userId["name"] ?? ""
            username = userId["username"] ?? ""
        } else {
            // 兼容直接字符串形式的 userId
            userId = try container.decode(String.self, forKey: .userId)
            user = try container.decode(String.self, forKey: .user)
            username = try container.decode(String.self, forKey: .username)
        }

        image = try? container.decode(Bool.self, forKey: .image)
        likes = try? container.decode([String].self, forKey: .likes)
    }
}
