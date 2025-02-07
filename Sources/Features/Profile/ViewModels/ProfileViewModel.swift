import SwiftUI
import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    private let profileService: ProfileServiceProtocol
    private let userId: String?  // 外部传入的目标用户ID；若为 nil，则表示显示当前用户
    
    @Published var user: User?
    @Published var tweets: [Tweet] = []
    @Published var isLoading = false
    @Published var errorMessage: String?  // 重命名为 errorMessage
    @Published var shouldRefreshImage = false
    
    private var lastImageRefreshTime: TimeInterval = 0
    
    // 如果 userId 为 nil，则表示显示当前用户的资料
    var isCurrentUser: Bool {
        guard let profileUserId = user?.id else { return false }
        return userId == nil || userId == profileUserId
    }
    
    init(profileService: ProfileServiceProtocol, userId: String? = nil) {
        self.profileService = profileService
        self.userId = userId
        
        Task {
            await fetchProfile()
        }
    }
    
    func fetchProfile() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            // 如果 userId 为 nil，则使用当前已加载的 user 的 id（或者你可以通过父视图传入当前用户ID）
            let targetUserId = userId ?? self.user?.id
            guard let targetUserId = targetUserId else {
                throw NetworkError.custom("No user ID available")
            }
            
            async let profile = self.profileService.fetchUserProfile(userId: targetUserId)
            async let userTweets = self.profileService.fetchUserTweets(userId: targetUserId)
           
            let (fetchedProfile, fetchedTweets) = try await (profile, userTweets)
          
     
            self.user = fetchedProfile
            self.tweets = fetchedTweets
            
        } catch let networkError as NetworkError {
            errorMessage = networkError.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateProfile(data: [String: Any]) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let updatedUser = try await self.profileService.updateProfile(data: data)
            self.user = updatedUser
        } catch let networkError as NetworkError {
            errorMessage = networkError.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func uploadAvatar(imageData: Data) async {
        await performImageUpload {
            try await self.profileService.uploadAvatar(imageData: imageData)
        }
    }
    
    // 如果后端不支持上传 Banner，建议移除此方法或返回错误
    func uploadBanner(imageData: Data) async {
        await performImageUpload {
            try await self.profileService.uploadBanner(imageData: imageData)
        }
    }
    
    private func performImageUpload(_ upload: @escaping () async throws -> User) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let updatedUser = try await upload()
            self.user = updatedUser
            self.lastImageRefreshTime = Date().timeIntervalSince1970
            self.shouldRefreshImage.toggle()
        } catch let networkError as NetworkError {
            errorMessage = networkError.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func getAvatarURL() -> URL? {
        guard let userId = user?.id else { return nil }
        let baseURL = "\(APIConfig.baseURL)/users/\(userId)/avatar"
        return URL(string: "\(baseURL)?t=\(Int(lastImageRefreshTime))")
    }
}

#if DEBUG
extension ProfileViewModel {
    static var preview: ProfileViewModel {
        ProfileViewModel(profileService: MockProfileService())
    }
}
#endif
