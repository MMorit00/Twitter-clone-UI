@_exported import Inject
import SwiftUI

@main
struct TwitterCloneApp: App {
    // 创建容器
    @StateObject private var authViewModel = AuthViewModel.shared
    let container: DIContainer = {
        let container = DIContainer()

        // 配置 APIClient
        let apiClient = APIClient(baseURL: APIConfig.baseURL)
        container.register(apiClient, type: .apiClient)

        #if DEBUG
            // 打印调试信息
            if let client: APIClientProtocol = container.resolve(.apiClient) {
                print("成功注册 APIClient")
            } else {
                print("APIClient 注册失败")
            }
        #endif

        return container
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.diContainer, container)
                .environmentObject(authViewModel)
        }
    }
}

// 环境值扩展
private struct DIContainerKey: EnvironmentKey {
    static let defaultValue = DIContainer()
}

extension EnvironmentValues {
    var diContainer: DIContainer {
        get { self[DIContainerKey.self] }
        set { self[DIContainerKey.self] = newValue }
    }
}
