//
//  ProfileServiceProtocol..swift
//  CloneTwitter
//
//  Created by 潘令川 on 2025/2/6.
//

import Foundation


import Foundation

protocol ProfileServiceProtocol {
    func fetchUserProfile(userId: String) async throws -> User
    func updateProfile(data: [String: Any]) async throws -> User
    func fetchUserTweets(userId: String) async throws -> [Tweet]
    func uploadAvatar(imageData: Data) async throws -> User
    func uploadBanner(imageData: Data) async throws -> User
  
}

final class ProfileService: ProfileServiceProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func fetchUserProfile(userId: String) async throws -> User {
        let endpoint = ProfileEndpoint.fetchUserProfile(userId: userId)
        return try await apiClient.sendRequest(endpoint)
    }
    
    func updateProfile(data: [String: Any]) async throws -> User {
        let endpoint = ProfileEndpoint.updateProfile(data: data)
        return try await apiClient.sendRequest(endpoint)
    }
    
    func fetchUserTweets(userId: String) async throws -> [Tweet] {
        let endpoint = ProfileEndpoint.fetchUserTweets(userId: userId)
        return try await apiClient.sendRequest(endpoint)
    }
    
    /// 修改后的上传头像逻辑  
    /// 第一步调用 sendRequestWithoutDecoding 上传图片（不解码响应），
    /// 第二步调用 fetchUserProfile 获取更新后的用户数据
    func uploadAvatar(imageData: Data) async throws -> User {
        let uploadEndpoint = ProfileEndpoint.uploadAvatar(imageData: imageData)
        try await apiClient.sendRequestWithoutDecoding(uploadEndpoint)
        // 上传成功后获取最新用户数据
        return try await fetchUserProfile(userId: "me")
    }

    func uploadBanner(imageData: Data) async throws -> User {
        let uploadEndpoint = ProfileEndpoint.uploadBanner(imageData: imageData)
        try await apiClient.sendRequestWithoutDecoding(uploadEndpoint)
        return try await fetchUserProfile(userId: "me")
    }
}




#if DEBUG
final class MockProfileService: ProfileServiceProtocol {
    var shouldSucceed = true
    
    func fetchUserProfile(userId: String) async throws -> User {
        if shouldSucceed {
            return User.mock
        } else {
            throw NetworkError.unauthorized
        }
    }
    
    func updateProfile(data: [String: Any]) async throws -> User {
        if shouldSucceed {
            return User.mock
        } else {
            throw NetworkError.unauthorized
        }
    }
    
    func fetchUserTweets(userId: String) async throws -> [Tweet] {
        if shouldSucceed {
            return [.mock]
        } else {
            throw NetworkError.unauthorized
        }
    }
    
    func uploadAvatar(imageData: Data) async throws -> User {
        if shouldSucceed {
            return User.mock
        } else {
            throw NetworkError.unauthorized
        }
    }
    
    func uploadBanner(imageData: Data) async throws -> User {
        if shouldSucceed {
            return User.mock
        } else {
            throw NetworkError.unauthorized
        }
    }
}

//private extension Tweet {
//    static var mock: Tweet {
//        Tweet(
//            _id: "mock_tweet_id",
//            text: "This is a mock tweet",
//            userId: "mock_user_id",
//            username: "mock_user",
//            user: "Mock User"
//        )
//    }
//}
#endif
