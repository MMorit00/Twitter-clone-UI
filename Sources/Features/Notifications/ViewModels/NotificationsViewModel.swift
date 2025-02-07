import Foundation

@MainActor
final class NotificationsViewModel: ObservableObject {
    // 发布数据和状态
    @Published private(set) var notifications: [Notification] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?

    // 依赖注入
    private let service: NotificationServiceProtocol
    private let user: User
    // 标志，防止重复加载
    private var didFetch = false

    init(user: User, service: NotificationServiceProtocol) {
        self.user = user
        self.service = service
    }

    /// 获取通知列表（首次加载时调用）
    func fetchNotifications() async {
        // 若正在加载或已经加载过则直接返回
        guard !isLoading, !didFetch else { return }
        isLoading = true
        error = nil
        do {
            notifications = try await service.fetchNotifications(userId: user.id)
            didFetch = true
        } catch {
            self.error = error
            print("Failed to fetch notifications: \(error)")
        }
        isLoading = false
    }
    
    /// 刷新通知列表（下拉刷新时调用）
    func refreshNotifications() async {
        // 清除标志后重新加载数据
        didFetch = false
        await fetchNotifications()
    }
    
    /// 创建新通知
    func createNotification(receiverId: String, type: NotificationType, postText: String? = nil) {
        Task {
            do {
                let newNotification = try await service.createNotification(
                    username: user.username,
                    receiverId: receiverId,
                    type: type,
                    postText: postText
                )
                // 新通知插入列表最前面
                notifications.insert(newNotification, at: 0)
            } catch {
                self.error = error
                print("Failed to create notification: \(error)")
            }
        }
    }
    
    /// 清除错误状态
    func clearError() {
        error = nil
    }
}