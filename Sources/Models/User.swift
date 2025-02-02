import Foundation

struct User: Codable, Identifiable, Hashable {
    // 对应MongoDB的_id
    let id: String
    var username: String
    var name: String
    var email: String

    // 可选字段
    var location: String?
    var bio: String?
    var website: String?
    var avatarExists: Bool?

    // 关注关系
    var followers: [String]
    var following: [String]

    // CodingKeys用于处理MongoDB的_id映射
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case username, name, email
        case location, bio, website
        case avatarExists
        case followers, following
    }

    init(id: String = UUID().uuidString,
         username: String,
         name: String,
         email: String,
         location: String? = nil,
         bio: String? = nil,
         website: String? = nil,
         avatarExists: Bool? = false,
         followers: [String] = [],
         following: [String] = [])
    {
        self.id = id
        self.username = username
        self.name = name
        self.email = email
        self.location = location
        self.bio = bio
        self.website = website
        self.avatarExists = avatarExists
        self.followers = followers
        self.following = following
    }

    // 添加以下内容实现 Hashable（编译器会自动合成）
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(username)
        hasher.combine(email)
    }

    // 可选：实现 == 运算符（编译器也会自动合成）
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id &&
            lhs.username == rhs.username &&
            lhs.email == rhs.email
    }
}
