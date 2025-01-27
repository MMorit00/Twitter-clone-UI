import SwiftUI

struct TweetCellView: View {
    @ObserveInjection var inject
    var tweetImage: String? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 点赞信息
            HStack(spacing: 8) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.gray)
                Text("Kieron Dotson and Zack John liked")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.trailing, 16)

            // 主要内容
            HStack(alignment: .top, spacing: 12) {
                // 头像
                Circle()
                    .fill(.gray)
                    .frame(width: 44, height: 44)

                // 推文内容
                VStack(alignment: .leading, spacing: 4) {
                    // 用户信息
                    HStack {
                        Text("Martha Craig")
                            .fontWeight(.semibold)
                        Text("@craig_love")
                            .foregroundColor(.gray)
                        Text("·")
                            .foregroundColor(.gray)
                        Text("11h")
                            .foregroundColor(.gray)
                    }
                    .font(.system(size: 16))

                    // 推文文本
                    Text("UXR/UX: You can only bring one item to a remote island to assist your research of native use of tools and usability. What do you bring? #TellMeAboutYou")
                        .font(.system(size: 16))
                        .frame(maxHeight: 100)
                        .lineSpacing(4)

                    if let tweetImage = tweetImage {
                        GeometryReader { geometry in
                            Image(tweetImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.frame(in: .global).width, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .frame(height: 200)
                        .zIndex(0)
                    }

                    // 互动按钮
                    HStack(spacing: 40) {
                        InteractionButton(image: "message", count: 28)
                        InteractionButton(image: "arrow.2.squarepath", count: 5)
                        InteractionButton(image: "heart", count: 21)
                        InteractionButton(image: "square.and.arrow.up", count: nil)
                    }
                    .padding(.top, 8)
                }
                // .padding(.trailing, 16)
            }
        }

        // .padding()

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

#Preview {
    TweetCellView()
}
