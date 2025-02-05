// import SwiftUI

// // import Kingfisher

// class TweetCellViewModel: ObservableObject {
//     @Published var tweet: Tweet
//     @Published var user: User?
//     @Published var isLoading = false
//     let currentUser: User

//     init(tweet: Tweet, currentUser: User = AuthViewModel.shared.user!) {
//         self.tweet = tweet
//         self.currentUser = currentUser
//         checkIfUserLikedTweet()
//         fetchUser()
//     }

//     private func fetchUser() {
//         isLoading = true

//         guard let token = UserDefaults.standard.string(forKey: "jwt") else {
//             return
//         }

//         let urlString = "http://localhost:3000/users/\(tweet.userId)"
//         guard let url = URL(string: urlString) else { return }

//         var request = URLRequest(url: url)
//         request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

//         URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
//             DispatchQueue.main.async {
//                 self?.isLoading = false

//                 guard let data = data else { return }

//                 do {
//                     let user = try JSONDecoder().decode(User.self, from: data)
//                     self?.user = user
//                 } catch {
//                     print("Error decoding user: \(error)")
//                 }
//             }
//         }.resume()
//     }

//     func getUserAvatarURL() -> URL? {
//         guard let userId = user?.id else { return nil }
//         return URL(string: "http://localhost:3000/users/\(userId)/avatar")
//     }

//     var imageUrl: URL? {
//         guard tweet.image == true else { return nil }
//         return URL(string: "http://localhost:3000/tweets/\(tweet.id)/image")
//     }

//     func checkIfUserLikedTweet() {
//         if let likes = tweet.likes {
//             tweet.didLike = likes.contains(currentUser.id)
//         }
//     }

//     func likeTweet() {
//         let isLiked = tweet.didLike ?? false

//         RequestServices.likeTweet(tweetId: tweet.id, isLiked: isLiked) { [weak self] result in
//             DispatchQueue.main.async {
//                 switch result {
//                 case .success:
//                     self?.tweet.didLike?.toggle()

//                     if isLiked {
//                         self?.tweet.likes?.removeAll(where: { $0 == self?.currentUser.id })

//                     } else {
//                         self?.tweet.likes = (self?.tweet.likes ?? []) + [self?.currentUser.id ?? ""]
//                         RequestServices.requestDomain = "http://localhost:3000"
//                         print("Sending notification: Username: \(self?.currentUser.username ?? ""), Sender ID: \(self?.currentUser.id ?? ""), Receiver ID: \(self?.tweet.userId ?? "")")
//                         RequestServices.sendNotification(
//                             username: self?.currentUser.username ?? "",
//                             notSenderId: self?.currentUser.id ?? "",
//                             notReceiverId: self?.tweet.userId ?? "",
//                             notificationType: NotificationType.like.rawValue,
//                             postText: self?.tweet.text ?? ""
//                         ) { result in
//                             print("Notification result: \(result)")
//                         }
//                     }

//                 case let .failure(error):
//                     print("Error liking tweet: \(error)")
//                 }
//             }
//         }
//     }
// }


import SwiftUI

@MainActor
final class TweetCellViewModel: ObservableObject {
    @Published var tweet: Tweet
    @Published var isLoading = false
    @Published var error: Error?
    
    private let tweetService: TweetServiceProtocol
    private let onTweetUpdated: ((Tweet) -> Void)?
    
    init(
        tweet: Tweet,
        tweetService: TweetServiceProtocol,
        onTweetUpdated: ((Tweet) -> Void)? = nil
    ) {
        self.tweet = tweet
        self.tweetService = tweetService
        self.onTweetUpdated = onTweetUpdated
    }
    
    func likeTweet() {
        guard !isLoading else { return }
        isLoading = true
        
        Task {
            do {
                let updatedTweet = try await tweetService.likeTweet(tweetId: tweet.id)
                self.tweet = updatedTweet
                onTweetUpdated?(updatedTweet)
            } catch {
                self.error = error
                print("点赞失败: \(error)")
            }
            isLoading = false
        }
    }
    
    func unlikeTweet() {
        guard !isLoading else { return }
        isLoading = true
        
        Task {
            do {
                let updatedTweet = try await tweetService.unlikeTweet(tweetId: tweet.id)
                self.tweet = updatedTweet
                onTweetUpdated?(updatedTweet)
            } catch {
                self.error = error
                print("取消点赞失败: \(error)")
            }
            isLoading = false
        }
    }
    
    var imageUrl: URL? {
        guard tweet.image == true else { return nil }
        return URL(string: "http://localhost:3000/tweets/\(tweet.id)/image")
    }
    
    var isLiked: Bool {
        tweet.didLike ?? false
    }
    
    var likesCount: Int {
        tweet.likes?.count ?? 0
    }
}