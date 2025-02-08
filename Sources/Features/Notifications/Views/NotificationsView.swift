import SwiftUI

struct NotificationsView: View {
    @StateObject private var viewModel: NotificationsViewModel

    init(user: User, service: NotificationServiceProtocol) {
        _viewModel = StateObject(wrappedValue: NotificationsViewModel(user: user, service: service))
    }

    var body: some View {
        ZStack {
            // 如果数据正在加载且列表为空，则显示加载指示器，否则显示内容
            if viewModel.isLoading && viewModel.notifications.isEmpty {
                ProgressView()
            } else {
                content
            }
        }
//        // 通过 Alert 显示错误信息
//        .alert("错误", isPresented: Binding(
//            get: { viewModel.error != nil },
//            set: { _ in viewModel.clearError() }
//        )) {
//            Button("确定") {
//                viewModel.clearError()
//            }
//        } message: {
//            if let error = viewModel.error {
//                Text(error.localizedDescription)
//            }
//        }
        // 视图首次加载时调用一次
        .task {
            await viewModel.fetchNotifications()
        }
        // 每隔 5 秒自动刷新一次（避免多次并发刷新）
        .onReceive(Timer.publish(every: 5, on: .main, in: .common).autoconnect()) { _ in
            if !viewModel.isLoading {
                Task {
                    await viewModel.fetchNotifications()
                }
            }
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
        // 下拉刷新时调用 refreshNotifications()
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
