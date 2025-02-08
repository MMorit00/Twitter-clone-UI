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

    init(user: User, service: NotificationServiceProtocol) {
        self.user = user
        self.service = service
    }
    
    /// 获取通知列表，每次调用都会重新加载数据
    func fetchNotifications() async {
        // 如果正在加载，则直接返回，防止并发调用
        guard !isLoading else { return }
        isLoading = true
        error = nil
        do {
            let newNotifications = try await service.fetchNotifications(userId: user.id)
            notifications = newNotifications
        } catch {
            // 如果错误是任务取消，则忽略错误，不赋值 error
            if error is CancellationError {
                print("Fetch notifications cancelled. Ignoring cancellation error.")
            } else {
                self.error = error
                print("Failed to fetch notifications: \(error)")
            }
        }
        isLoading = false
    }
    
    /// 刷新通知列表，直接调用 fetchNotifications()
    func refreshNotifications() async {
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
                if error is CancellationError {
                    print("Create notification cancelled. Ignoring cancellation error.")
                } else {
                    self.error = error
                    print("Failed to create notification: \(error)")
                }
            }
        }
    }
    
    /// 清除错误状态
    func clearError() {
        error = nil
    }
}