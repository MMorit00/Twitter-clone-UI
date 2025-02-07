import Foundation

struct Tweet: Identifiable, Decodable, Equatable {
    // MongoDB 的 _id 字段
    let _id: String
    let text: String
    let userId: String
    /// 用户昵称，如为空则显示默认值
    let username: String
    /// 用户真实姓名，如为空则显示默认值
    let user: String

    // 可选字段，后续预留扩展（例如是否带图片）
    var image: Bool?
    /// 点赞列表：存储点赞的用户 id 数组
    var likes: [String]?

    // 满足 Identifiable 协议
    var id: String {
        _id
    }

    enum CodingKeys: String, CodingKey {
        case _id, text, userId, username, user, image, likes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        _id = try container.decode(String.self, forKey: ._id)
        text = try container.decode(String.self, forKey: .text)
        
        // 如果 userId 是嵌套对象，则解析其中的用户信息
        if let userInfo = try? container.decode([String: String].self, forKey: .userId) {
            userId = userInfo["_id"] ?? ""
            user = userInfo["name"] ?? ""
            username = userInfo["username"] ?? ""
        } else {
            // 否则直接解码，并对 user 与 username 采用 decodeIfPresent，若缺失则提供默认值
            userId = try container.decode(String.self, forKey: .userId)
            user = try container.decodeIfPresent(String.self, forKey: .user) ?? ""
            username = try container.decodeIfPresent(String.self, forKey: .username) ?? ""
        }
        
        image = try? container.decode(Bool.self, forKey: .image)
        likes = try? container.decode([String].self, forKey: .likes)
    }
}