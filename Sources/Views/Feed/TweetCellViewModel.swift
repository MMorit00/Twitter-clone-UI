import SwiftUI

// import Kingfisher

class TweetCellViewModel: ObservableObject {
    @Published var tweet: Tweet
    @Published var user: User?
    @Published var isLoading = false

    init(tweet: Tweet) {
        self.tweet = tweet
        fetchUser()
    }

    private func fetchUser() {
        isLoading = true

        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            return
        }

        let urlString = "http://localhost:3000/users/\(tweet.userId)"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                guard let data = data else { return }

                do {
                    let user = try JSONDecoder().decode(User.self, from: data)
                    self?.user = user
                } catch {
                    print("Error decoding user: \(error)")
                }
            }
        }.resume()
    }

    func getUserAvatarURL() -> URL? {
        guard let userId = user?.id else { return nil }
        return URL(string: "http://localhost:3000/users/\(userId)/avatar")
    }

    var imageUrl: URL? {
        guard tweet.image == true else { return nil }
        return URL(string: "http://localhost:3000/tweets/\(tweet.id)/image")
    }
}
