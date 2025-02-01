import SwiftUI
//import Kingfisher 

class TweetCellViewModel: ObservableObject {
    @Published var tweet: Tweet

    init(tweet: Tweet) {
        self.tweet = tweet
    }

    var imageUrl: URL? {
        guard tweet.image == true else { return nil }
        return URL(string: "http://localhost:3000/tweets/\(tweet.id)/image")
    }
}
