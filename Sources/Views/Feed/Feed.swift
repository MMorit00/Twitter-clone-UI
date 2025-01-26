import SwiftUI

struct FeedView: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                TweetCellView(tweetImage: "TweetImage")
                 .padding(.horizontal, 10)
                Divider()
                .padding()
                ForEach(0 ..< 10) { _ in
                    TweetCellView()
                    .padding(.horizontal, 10)
                    Divider()
                    .padding()
                }
                
                
            }
        }
    }
}

#Preview {
    FeedView()
}
