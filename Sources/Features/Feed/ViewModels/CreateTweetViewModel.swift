
import SwiftUI 

@MainActor
final class CreateTweetViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: Error?
    
    private let tweetService: TweetServiceProtocol
    
    init(tweetService: TweetServiceProtocol) {
        self.tweetService = tweetService
    }
    
    func createTweet(text: String, image: UIImage? = nil, currentUser: User?) async {
        guard let user = currentUser else {
            error = NetworkError.custom("未登录用户")
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            let tweet = try await tweetService.createTweet(
                text: text,
                userId: user.id
            )
            
            if let image = image {
                try await tweetService.uploadImage(
                    tweetId: tweet.id,
                    image: image
                )
            }
            
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
            print("发送推文失败: \(error)")
        }
    }
}

#if DEBUG
extension CreateTweetViewModel {
    static var preview: CreateTweetViewModel {
        CreateTweetViewModel(tweetService: MockTweetService())
    }
}
#endif