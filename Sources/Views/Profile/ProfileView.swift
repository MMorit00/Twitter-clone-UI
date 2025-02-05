// 添加在文件顶部
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// 添加在文件顶部
struct TabBarOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

import SwiftUI
import Kingfisher
struct ProfileView: View {
    // MARK: - Properties

    @StateObject private var viewModel: ProfileViewModel
    @ObserveInjection var inject
    @State var offset: CGFloat = 0 // 监测最顶端 Banner 的滚动偏移
    @State var titleOffset: CGFloat = 0 // 监测 Profile Data 或标题区域的滚动偏移
    @State var tabBarOffset: CGFloat = 0 // 监测 TabBar 的滚动偏移
    @State private var showEditProfile = false // 添加导航状态
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State var currentTab = "Tweets"
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss

    // 初始化方法
    init(userId: String? = nil) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(userId: userId))
    }

    // MARK: - Body

    var body: some View {
        Group {
            if let error = viewModel.error {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text(error.localizedDescription)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 15) {
                        // MARK: - 1) Banner + Title

                        GeometryReader { proxy -> AnyView in
                            let minY = proxy.frame(in: .global).minY

                            return AnyView(
                                ZStack {
                                    // 背景 Banner
                                    Image("SC_banner")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(
                                            width: getRect().width,
                                            height: minY > 0 ? 180 + minY : 180
                                        )
                                        .cornerRadius(0)
                                        .offset(y: minY > 0 ? -minY : 0)

                                    // Blur
                                    BlurView()
                                        .opacity(blurViewOpacity())

                                    // Title
                                    VStack(spacing: 5) {
                                        Text(viewModel.user.name)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        Text("\(viewModel.user.followers.count) Followers")
                                            .foregroundColor(.white)
                                    }
                                    .offset(y: 120)
                                    .offset(y: titleOffset > 100 ? 0 : -getTitleTextOffset())
                                    .opacity(titleOffset < 100 ? 1 : 0)
                                }
                                .clipped()
                                .frame(height: minY > 0 ? 180 + minY : nil)
                                .offset(y: minY > 0 ? -minY : -minY < 80 ? 0 : -minY - 80)
                                .onAppear {
                                    DispatchQueue.main.async {
                                        offset = minY
                                    }
                                }
                            )
                        }

                        .frame(height: 180)
                        .zIndex(1)

                        // MARK: - 2) Profile Image + Profile Info

                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                KFImage(viewModel.getAvatarURL())
                                    .placeholder {
                                        Image("blankpp")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    }
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 75, height: 75)
                                    .clipShape(Circle())
                                    .padding(8)
                                    .background(.white)
                                    .clipShape(Circle())
                                    .offset(y: -20)

                                Spacer()

                                // 将按钮包装在 ZStack 中以确保它在最上层
                                ZStack {
                                    if viewModel.isCurrentUser {
                                        Button {
                                            showEditProfile.toggle()
                                        } label: {
                                            Text("Edit Profile")
                                                .font(.system(size: 14))
                                                .fontWeight(.semibold)
                                                .foregroundColor(.black)
                                                .padding(.vertical, 6)
                                                .padding(.horizontal, 12)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(Color.gray, lineWidth: 1)
                                                )
                                        }
                                        .zIndex(2) // 确保按钮在最上层
                                    } else {
                                        FollowButton()
                                            .zIndex(2)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .contentShape(Rectangle()) // 确保整个区域可以接收点击
                            .zIndex(2) // 给整个 HStack 一个较高的 zIndex

                            // User Info
                            VStack(alignment: .leading, spacing: 4) {
                                Text(viewModel.user.name)
                                    .font(.title2)
                                    .fontWeight(.bold)

                                Text("@\(viewModel.user.username)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)

                            // User Bio & Details
                            if let bio = viewModel.user.bio, !bio.isEmpty {
                                Text(bio)
                                    .font(.subheadline)
                                    .padding(.horizontal)
                                    .padding(.vertical, 4)
                            }

                            // Location & Website
                            HStack(spacing: 24) {
                                if let location = viewModel.user.location, !location.isEmpty {
                                    HStack(spacing: 4) {
                                        Image(systemName: "mappin.circle.fill")
                                        Text(location)
                                    }
                                }

                                if let website = viewModel.user.website, !website.isEmpty {
                                    HStack(spacing: 4) {
                                        Image(systemName: "link")
                                        Text(website)
                                    }
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal)

                            // Followers Count
                            HStack(spacing: 24) {
                                HStack(spacing: 4) {
                                    Text("\(viewModel.user.following.count)")
                                        .fontWeight(.bold)
                                    Text("Following")
                                        .foregroundColor(.gray)
                                }

                                HStack(spacing: 4) {
                                    Text("\(viewModel.user.followers.count)")
                                        .fontWeight(.bold)
                                    Text("Followers")
                                        .foregroundColor(.gray)
                                }
                            }
                            .font(.subheadline)
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                        }
                        .zIndex(2) // 确保整个 Profile Info 在正确的层级

                        // MARK: - 3) TabBar (自定义滚动菜单)

                        VStack(spacing: 0) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 0) {
                                    TabButton(title: "Tweets", currentTab: $currentTab)
                                    TabButton(title: "Replies", currentTab: $currentTab)
                                    TabButton(title: "Media", currentTab: $currentTab)
                                    TabButton(title: "Likes", currentTab: $currentTab)
                                }
                            }
                            Divider()
                        }
                        .padding(.top, 16)
                        .background(colorScheme == .dark ? Color.black : Color.white)
                        .offset(y: tabBarOffset < 90 ? -tabBarOffset + 90 : 0)
                        .overlay(
                            GeometryReader { proxy in
                                Color.clear
                                    .preference(key: TabBarOffsetPreferenceKey.self, value: proxy.frame(in: .global).minY)
                                    .allowsHitTesting(false)
                            }
                            .allowsHitTesting(false) // 也要给 GeometryReader 添加
                            .onPreferenceChange(TabBarOffsetPreferenceKey.self) { value in
                                self.tabBarOffset = value
                            }
                        )
                        .zIndex(1)

                        // MARK: - 4) Tweets 列表

                        VStack(spacing: 18) {
                            ForEach(viewModel.tweets) { tweet in
                                TweetCellView(viewModel: viewModel.getTweetCellViewModel(for: tweet))
                                Divider()
                            }
                        }
                        .padding(.top)
                        .zIndex(0)
                    }
                }
            }
        }
//       .onDisappear {
//            if let currentUserId = authViewModel.currentUser?.id,
//               currentUserId == viewModel.user.id {
//                authViewModel.updateCurrentUser(viewModel.user)
//            }
//        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.blue)
                            .padding(8)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .ignoresSafeArea(.all, edges: .top)
        .enableInjection()
        // 添加 sheet 导航
        .sheet(isPresented: $showEditProfile) {
            if viewModel.isCurrentUser {
                EditProfileView()
            }
        }
    }

    // MARK: - 逻辑与原 UserProfile 保持一致

    // 让 Title View 有一个滑动消失/收起的动画
    func getTitleTextOffset() -> CGFloat {
        let progress = 20 / titleOffset
        // 原逻辑：最多移动 60
        let offset = 60 * (progress > 0 && progress <= 1 ? progress : 1)
        return offset
    }

    // 头像向上移动
    func getOffset() -> CGFloat {
        let progress = (-offset / 80) * 20
        // 最大上移 20
        return progress <= 20 ? progress : 20
    }

    // 头像缩放
    func getScale() -> CGFloat {
        let progress = -offset / 80
        // 1.8 - 1 = 0.8 最小缩放 0.8
        let scale = 1.8 - (progress < 1.0 ? progress : 1)
        return scale < 1 ? scale : 1
    }

    // Banner Blur
    func blurViewOpacity() -> Double {
        let progress = -(offset + 80) / 150
        return Double(-offset > 80 ? progress : 0)
    }

    // 修改 FollowButton 视图
    @ViewBuilder
    private func FollowButton() -> some View {
        Button(action: {
            if viewModel.isFollowing {
                viewModel.unfollow()
            } else {
                viewModel.follow()
            }
        }) {
            Text(viewModel.isFollowing ? "Following" : "Follow")
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundColor(viewModel.isFollowing ? .gray : .white)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(
                    Capsule()
                        .fill(viewModel.isFollowing ? Color.clear : Color.blue)
                        .overlay(
                            Capsule()
                                .stroke(Color.gray, lineWidth: viewModel.isFollowing ? 1 : 0)
                        )
                )
        }
        .animation(.easeInOut, value: viewModel.isFollowing)
    }
}

struct TabButton: View {
    let title: String
    @Binding var currentTab: String

    var body: some View {
        Button {
            currentTab = title
        } label: {
            Text(title)
                .foregroundColor(currentTab == title ? .blue : .gray)
                .padding(.horizontal, 16)
                .frame(height: 44)

            // if currentTab == title {
            //     Rectangle()
            //         .fill(Color.blue)
            //         .frame(height: 2)
            //         .matchedGeometryEffect(id: "TAB", in: animation)
            // } else {
            //     Rectangle()
            //         .fill(Color.clear)
            //         .frame(height: 2)
            // }
        }
    }
}

// 获取屏幕大小
extension View {
    func getRect() -> CGRect {
        UIScreen.main.bounds
    }
}
