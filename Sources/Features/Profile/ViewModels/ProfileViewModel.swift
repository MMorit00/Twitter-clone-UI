import SwiftUI
import Foundation
import Kingfisher

// Fix notification name definition
extension NSNotification.Name {
    static let didUpdateProfile = NSNotification.Name("didUpdateProfile")
}

@MainActor
final class ProfileViewModel: ObservableObject {
    private let profileService: ProfileServiceProtocol
    private let userId: String?
    
    @Published var user: User?
    @Published var tweets: [Tweet] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var shouldRefreshImage = false
    
    private(set) var lastImageRefreshTime: TimeInterval = Date().timeIntervalSince1970
    
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
            let targetUserId = userId ?? self.user?.id ?? "me"
            async let profile = profileService.fetchUserProfile(userId: targetUserId)
            async let userTweets = profileService.fetchUserTweets(userId: targetUserId)
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
            let updatedUser = try await profileService.updateProfile(data: data)
            self.user = updatedUser
            self.lastImageRefreshTime = Date().timeIntervalSince1970
            self.shouldRefreshImage.toggle()
            // 发布通知，传递最新的用户数据
            NotificationCenter.default.post(name: .didUpdateProfile, object: updatedUser)
        } catch let networkError as NetworkError {
            errorMessage = networkError.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func uploadAvatar(imageData: Data) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let updatedUser = try await profileService.uploadAvatar(imageData: imageData)
            self.user = updatedUser
            self.lastImageRefreshTime = Date().timeIntervalSince1970
            self.shouldRefreshImage.toggle()
            if let url = getAvatarURL() {
                try await KingfisherManager.shared.cache.removeImage(forKey: url.absoluteString)
            }
            // 发布通知，全局更新
            NotificationCenter.default.post(name: .didUpdateProfile, object: updatedUser)
            try await fetchProfile()
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
