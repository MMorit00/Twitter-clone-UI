import Kingfisher
import SwiftUI

struct TweetCellView: View {
    @ObserveInjection var inject
    @ObservedObject var viewModel: TweetCellViewModel
    @Environment(\.diContainer) private var container
    @EnvironmentObject var authState: AuthState  // 直接获取全局 AuthState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 如果点赞数大于 0，则显示点赞数
            if viewModel.likesCount > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.gray)
                    Text("\(viewModel.likesCount) likes")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 16)
            }
            
            HStack(alignment: .top, spacing: 12) {
                // 头像区域：点击跳转到对应用户的个人主页
                NavigationLink {
                    ProfileView(userId: viewModel.tweet.userId, diContainer: container)
                } label: {
                    avatarView
                }
                
                // 推文内容区域
                VStack(alignment: .leading, spacing: 4) {
                    // 用户信息
                    HStack {
                        Text(viewModel.tweet.user)
                            .fontWeight(.semibold)
                        Text("@\(viewModel.tweet.username)")
                            .foregroundColor(.gray)
                        Text("·")
                            .foregroundColor(.gray)
                        Text("11h")
                            .foregroundColor(.gray)
                    }
                    .font(.system(size: 16))
                    
                    // 推文文本
                    Text(viewModel.tweet.text)
                        .font(.system(size: 16))
                        .frame(maxHeight: 100)
                        .lineSpacing(4)
                    
                    // 推文图片（如果存在）
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
                    
                    // 互动按钮区域
                    HStack(spacing: 40) {
                        InteractionButton(image: "message", count: 0)
                        InteractionButton(image: "arrow.2.squarepath", count: 0)
                        
                        Button(action: {
                            if viewModel.isLiked {
                                viewModel.unlikeTweet()
                            } else {
                                viewModel.likeTweet()
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                                    .foregroundColor(viewModel.isLiked ? .red : .gray)
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
    
    // 使用全局 AuthState 重新计算头像 URL
    private var avatarView: some View {
        KFImage(getAvatarURL())
            .placeholder {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 44, height: 44)
            }
            .resizable()
            .scaledToFill()
            .frame(width: 44, height: 44)
            .clipShape(Circle())
            .onAppear {
                // 可选：在 onAppear 清除缓存，确保加载最新图片
                if let url = getAvatarURL() {
                    KingfisherManager.shared.cache.removeImage(forKey: url.absoluteString)
                }
            }
    }
    
    private func getAvatarURL() -> URL? {
        // 调用 TweetCellViewModel 中的方法，传入全局 authState
        return viewModel.getUserAvatarURL(from: authState)
    }
}

// MARK: - 子视图：互动按钮

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