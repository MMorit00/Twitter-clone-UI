import Foundation

struct User: Codable, Identifiable {
    // 对应MongoDB的_id
    let id: String
    let username: String
    let name: String
    let email: String
    
    // 可选字段
    let location: String?
    let bio: String?
    let website: String?
    let avatarExists: Bool?
    
    // 关注关系
    let followers: [String]
    let following: [String]
    
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
         following: [String] = []) {
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
}
