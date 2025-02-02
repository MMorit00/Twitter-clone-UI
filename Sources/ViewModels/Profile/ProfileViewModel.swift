import Combine
import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var tweets = [Tweet]()
    @Published var user: User
    @Published var shouldRefreshImage = false

    private var lastImageRefreshTime: TimeInterval = 0
    private var cancellables = Set<AnyCancellable>()

    init() {
        user = AuthViewModel.shared.user!

        AuthViewModel.shared.$user
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedUser in
                self?.user = updatedUser
                // 只在距离上次刷新超过1秒时才触发图片刷新
                let currentTime = Date().timeIntervalSince1970
                if currentTime - (self?.lastImageRefreshTime ?? 0) > 1.0 {
                    self?.shouldRefreshImage.toggle()
                    self?.lastImageRefreshTime = currentTime
                }
            }
            .store(in: &cancellables)
    }

    // 获取带时间戳的头像URL
    func getAvatarURL() -> URL? {
        let baseURL = "http://localhost:3000/users/\(user.id)/avatar"
        // 使用lastImageRefreshTime而不是当前时间
        return URL(string: "\(baseURL)?t=\(Int(lastImageRefreshTime))")
    }
}
