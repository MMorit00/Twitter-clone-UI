//
//  ProfileEndpoint.swift
//  CloneTwitter
//
//  Created by 潘令川 on 2025/2/6.
//

import Foundation


enum ProfileEndpoint: APIEndpoint {
    case fetchUserProfile(userId: String)
    case updateProfile(data: [String: Any])
    case fetchUserTweets(userId: String)
    case uploadAvatar(imageData: Data)
    case uploadBanner(imageData: Data)
    
    var path: String {
        switch self {
        case .fetchUserProfile(let userId):
            return "/users/\(userId)"
        case .updateProfile:
            return "/users/me"
        case .fetchUserTweets(let userId):
            return "/tweets/user/\(userId)"
        case .uploadAvatar:
            return "/users/me/avatar"
        case .uploadBanner:
            return "/users/me/banner"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchUserProfile, .fetchUserTweets:
            return .get
        case .updateProfile:
            return .patch
        case .uploadAvatar, .uploadBanner:
            return .post
        }
    }
    
    var body: Data? {
        switch self {
        case .updateProfile(let data):
            return try? JSONSerialization.data(withJSONObject: data)
        case .uploadAvatar(let imageData), .uploadBanner(let imageData):
            return imageData
        default:
            return nil
        }
    }
    
    var headers: [String: String]? {
        var headers = ["Content-Type": "application/json"]
        
        switch self {
        case .uploadAvatar, .uploadBanner:
            headers["Content-Type"] = "image/jpeg"
        default: break
        }
        
        if let token = UserDefaults.standard.string(forKey: "jwt") {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return headers
    }
    
    var queryItems: [URLQueryItem]? {
        return nil
    }
}
