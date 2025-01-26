import Foundation

protocol UserServiceProtocol {
    func getUser(by id: UUID) async throws -> User?
}

class UserService: UserServiceProtocol {
    func getUser(by _: UUID) async throws -> User? {
        // TODO: 实现用户获取逻辑
        return nil
    }
}
