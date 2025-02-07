import Foundation

protocol NotificationServiceProtocol {
    func fetchNotifications(userId: String) async throws -> [Notification]
    func createNotification(username: String, receiverId: String, type: NotificationType, postText: String?) async throws -> Notification
}

final class NotificationService: NotificationServiceProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func fetchNotifications(userId: String) async throws -> [Notification] {
        let endpoint = NotificationEndpoint.fetchNotifications(userId: userId)
        return try await apiClient.sendRequest(endpoint)
    }
    
    func createNotification(username: String, receiverId: String, type: NotificationType, postText: String?) async throws -> Notification {
        let endpoint = NotificationEndpoint.createNotification(
            username: username,
            receiverId: receiverId,
            type: type,
            postText: postText
        )
        return try await apiClient.sendRequest(endpoint)
    }
}
