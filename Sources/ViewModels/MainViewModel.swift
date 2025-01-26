import Foundation

@MainActor
final class MainViewModel: ObservableObject {
    private let userService: UserServiceProtocol

    @Published var isLoading = false
    @Published var errorMessage: String?

    init(userService: UserServiceProtocol = UserService()) {
        self.userService = userService
    }

    func handleButtonTap() {
        // TODO: 实现按钮点击逻辑
    }
}
