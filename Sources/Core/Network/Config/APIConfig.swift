import Foundation

enum APIConfig {
    static let baseURL = URL(string: "http://localhost:3000")!
    
    enum Path {
        static let login = "/users/login"
        static let register = "/users"
        static let tweets = "/tweets"
        static let users = "/users"
    }
}