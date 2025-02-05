//
//  TweetService.swift
//  CloneTwitter
//
//  Created by 潘令川 on 2025/2/5.
//
import Foundation

struct ImageUploadResponse: Codable {
    let message: String
}





import Foundation
import UIKit

protocol TweetServiceProtocol {
    
  func fetchTweets() async throws -> [Tweet]
  func createTweet(text: String, userId: String) async throws -> Tweet
  func likeTweet(tweetId: String) async throws -> Tweet
  func unlikeTweet(tweetId: String) async throws -> Tweet
  func uploadImage(tweetId: String, image: UIImage) async throws -> ImageUploadResponse

}

final class TweetService: TweetServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchTweets() async throws -> [Tweet] {
        let endpoint = TweetEndpoint.fetchTweets
        return try await apiClient.sendRequest(endpoint)
    }

    func createTweet(text: String, userId: String) async throws -> Tweet {
        let endpoint = TweetEndpoint.createTweet(text: text, userId: userId)
        return try await apiClient.sendRequest(endpoint)
    }

    func likeTweet(tweetId: String) async throws -> Tweet {
        let endpoint = TweetEndpoint.likeTweet(tweetId: tweetId)
        return try await apiClient.sendRequest(endpoint)
    }

    func unlikeTweet(tweetId: String) async throws -> Tweet {
        let endpoint = TweetEndpoint.unlikeTweet(tweetId: tweetId)
        return try await apiClient.sendRequest(endpoint)
    }

    func uploadImage(tweetId: String, image: UIImage) async throws -> ImageUploadResponse {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NetworkError.custom("Failed to convert image to data")
        }
        
        let endpoint = TweetEndpoint.uploadImage(tweetId: tweetId, imageData: imageData)
        return try await apiClient.sendRequest(endpoint)
    }
}

#if DEBUG
    final class MockTweetService: TweetServiceProtocol {
        var shouldSucceed = true

        func fetchTweets() async throws -> [Tweet] {
            if shouldSucceed {
                return [.mock, .mock]
            } else {
                throw NetworkError.serverError
            }
        }

        func createTweet(text _: String, userId _: String) async throws -> Tweet {
            if shouldSucceed {
                return .mock
            } else {
                throw NetworkError.serverError
            }
        }

        func likeTweet(tweetId _: String) async throws -> Tweet {
            if shouldSucceed {
                return .mock
            } else {
                throw NetworkError.serverError
            }
        }

        func unlikeTweet(tweetId _: String) async throws -> Tweet {
            if shouldSucceed {
                return .mock
            } else {
                throw NetworkError.serverError
            }
        }

      func uploadImage(tweetId _: String, image _: UIImage) async throws -> ImageUploadResponse {
          if shouldSucceed {
              return ImageUploadResponse(message: "Tweet image uploaded successfully")
          } else {
              throw NetworkError.serverError
          }
      }
    }

    // Mock 实现修正

#if DEBUG
extension Tweet {
    static var mock: Tweet {
        let json = """
        {
            "_id": "mock_id",
            "text": "This is a mock tweet",
            "userId": "mock_user_id",
            "username": "mock_username",
            "user": "Mock User"
        }
        """.data(using: .utf8)!
        
        return try! JSONDecoder().decode(Tweet.self, from: json)
    }
}
#endif
#endif
