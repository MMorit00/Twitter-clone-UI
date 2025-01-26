import Foundation

struct User: Codable {
    let id: UUID
    let username: String
    let email: String

    init(id: UUID = UUID(), username: String, email: String) {
        self.id = id
        self.username = username
        self.email = email
    }
}
