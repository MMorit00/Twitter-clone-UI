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
    var isFollowed: Bool = false
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

       // 自定义解码，缺失字段使用默认值
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.username = try container.decode(String.self, forKey: .username)
        self.name = try container.decode(String.self, forKey: .name)
        self.email = try container.decode(String.self, forKey: .email)
        self.location = try container.decodeIfPresent(String.self, forKey: .location)
        self.bio = try container.decodeIfPresent(String.self, forKey: .bio)
        self.website = try container.decodeIfPresent(String.self, forKey: .website)
        self.avatarExists = try container.decodeIfPresent(Bool.self, forKey: .avatarExists)
        self.followers = try container.decodeIfPresent([String].self, forKey: .followers) ?? []
        self.following = try container.decodeIfPresent([String].self, forKey: .following) ?? []
        self.isFollowed = false
    }
    
    // 编码方法（若需要将 User 编码为 JSON，可保留此方法）
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(username, forKey: .username)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encodeIfPresent(location, forKey: .location)
        try container.encodeIfPresent(bio, forKey: .bio)
        try container.encodeIfPresent(website, forKey: .website)
        try container.encodeIfPresent(avatarExists, forKey: .avatarExists)
        try container.encode(followers, forKey: .followers)
        try container.encode(following, forKey: .following)
    }
    
    

    
}
