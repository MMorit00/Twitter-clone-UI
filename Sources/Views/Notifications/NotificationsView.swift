import SwiftUI

struct NotificationsView: View {
    let user: User
    @ObservedObject var viewModel: NotificationsViewModel
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    init(user: User) {
        self.user = user
        self.viewModel = NotificationsViewModel(user: user)
    }
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("加载中...")
                    .onAppear {
                        // 5秒后如果还在加载就显示错误
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            if isLoading {
                                errorMessage = "加载超时，请检查网络连接"
                                isLoading = false
                            }
                        }
                    }
            } else if let error = errorMessage {
                VStack(spacing: 20) {
                    Text(error)
                        .foregroundColor(.red)
                    Button("重试") {
                        isLoading = true
                        errorMessage = nil
                        viewModel.fetchNotifications()
                    }
                }
            } else {
                ScrollView {
                    if viewModel.notifications.isEmpty {
                        VStack(spacing: 20) {
                            Text("暂无通知")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Text("新的通知将会显示在这里")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        LazyVStack {
                            ForEach(viewModel.notifications) { notification in
                                NotificationCell(notification: notification)
                            }
                        }
                    }
                }
                .refreshable {
                    viewModel.fetchNotifications()
                }
            }
        }
        .onAppear {
            viewModel.fetchNotifications()
            // 2秒后关闭加载状态
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isLoading = false
            }
        }
    }
}
