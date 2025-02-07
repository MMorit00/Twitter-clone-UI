import SwiftUI

struct NotificationsView: View {
    @StateObject private var viewModel: NotificationsViewModel

    init(user: User, service: NotificationServiceProtocol) {
        _viewModel = StateObject(wrappedValue: NotificationsViewModel(user: user, service: service))
    }

    var body: some View {
        ZStack {
            // 如果没有加载过数据，并且正在加载时显示 ProgressView，否则显示内容
            if viewModel.isLoading && viewModel.notifications.isEmpty {
                ProgressView()
            } else {
                content
            }
        }
        // 使用动态绑定控制 Alert 的显示
        .alert("错误", isPresented: Binding(
            get: { viewModel.error != nil },
            set: { _ in viewModel.clearError() }
        )) {
            Button("确定") {
                viewModel.clearError()
            }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
        // 视图首次出现时加载通知
        .task {
            await viewModel.fetchNotifications()
        }
    }

    private var content: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if viewModel.notifications.isEmpty {
                    emptyView
                } else {
                    ForEach(viewModel.notifications) { notification in
                        NotificationCell(notification: notification)
                        Divider()
                    }
                }
            }
        }
        // 下拉刷新时重新加载数据
        .refreshable {
            await viewModel.refreshNotifications()
        }
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Text("暂无通知")
                .font(.title3)
                .fontWeight(.semibold)
            Text("新的通知将会显示在这里")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 32)
    }
}