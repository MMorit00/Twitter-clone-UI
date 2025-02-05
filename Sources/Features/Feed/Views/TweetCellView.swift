import Kingfisher
import SwiftUI

struct TweetCellView: View {
    @ObserveInjection var inject
    @ObservedObject var viewModel: TweetCellViewModel

    // 添加计算属性
    private var didLike: Bool {
        viewModel.tweet.didLike ?? false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 点赞信息 - 如果有点赞则显示
            if let likes = viewModel.tweet.likes, !likes.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.gray)
                    Text("\(likes.count) likes")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 16)
            }

            // 主要内容
            HStack(alignment: .top, spacing: 12) {
                // 头像部分
                NavigationLink {
                    if let user = viewModel.user {
                        ProfileView(userId: user.id)
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(width: 44, height: 44)
                    } else {
                        KFImage(viewModel.getUserAvatarURL())
                            .placeholder {
                                Circle()
                                    .fill(.gray)
                                    .frame(width: 44, height: 44)
                            }
                            .resizable()
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                    }
                }

                // 推文内容
                VStack(alignment: .leading, spacing: 4) {
                    // 用户信息
                    HStack {
                        Text(viewModel.tweet.user)
                            .fontWeight(.semibold)
                        Text("@\(viewModel.tweet.username)")
                            .foregroundColor(.gray)
                        Text("·")
                            .foregroundColor(.gray)
                        // TODO: 添加时间格式化显示
                        Text("11h")
                            .foregroundColor(.gray)
                    }
                    .font(.system(size: 16))

                    // 推文文本
                    Text(viewModel.tweet.text)
                        .font(.system(size: 16))
                        .frame(maxHeight: 100)
                        .lineSpacing(4)

                    // Tweet Image (if exists)
                    if viewModel.tweet.image == true {
                        GeometryReader { proxy in
                            KFImage(URL(string: "http://localhost:3000/tweets/\(viewModel.tweet.id)/image"))
                                .resizable()
                                .scaledToFill()
                                .frame(width: proxy.size.width, height: 200)
                                .cornerRadius(15)
                        }
                        .frame(height: 200)
                        .zIndex(0)
                    }

                    // 互动按钮
                    HStack(spacing: 40) {
                        InteractionButton(image: "message", count: 0)
                        InteractionButton(image: "arrow.2.squarepath", count: 0)

                        Button(action: {
                            viewModel.likeTweet()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: didLike ? "heart.fill" : "heart")
                                    .foregroundColor(didLike ? .red : .gray)
                                if let likes = viewModel.tweet.likes {
                                    Text("\(likes.count)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .zIndex(1)
                        .padding(8)
                        .contentShape(Rectangle())

                        InteractionButton(image: "square.and.arrow.up", count: nil)
                    }
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .contentShape(Rectangle())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
        .enableInjection()
    }
}

// MARK: - 子视图

private struct InteractionButton: View {
    let image: String
    let count: Int?

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: image)
                .foregroundColor(.gray)
            if let count = count {
                Text("\(count)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Preview
