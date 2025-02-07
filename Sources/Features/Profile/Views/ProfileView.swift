//
//  ProfileView.swift
//  twitter-clone (iOS)
//  Created by cem on 7/31/21.
//

import SwiftUI
import Kingfisher

// MARK: - BlurView 实现
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style = .light
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) { }
}

// MARK: - PreferenceKey 用于传递滚动偏移
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - ProfileView 主界面
struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    var isCurrentUser: Bool { viewModel.isCurrentUser }
    
    // For Dark Mode Adoption
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.diContainer) private var diContainer: DIContainer

    @State var currentTab = "Tweets"
    
    // For Smooth Slide Animation...
    @Namespace var animation
    @State var offset: CGFloat = 0            // 记录 Header 的滚动偏移（由 PreferenceKey 更新）
    @State var titleOffset: CGFloat = 0         // 用于计算标题上移量
    @State var tabBarOffset: CGFloat = 0

    // 头像及其它状态
    @State private var selectedImage: UIImage?
    @State var profileImage: Image?
    @State var imagePickerRepresented = false
    @State var editProfileShow = false

    @State var width = UIScreen.main.bounds.width
    
    // 初始化：若 userId 为 nil，则显示当前用户；否则显示指定用户的信息
    init(userId: String? = nil, diContainer: DIContainer) {
        guard let service: ProfileServiceProtocol = diContainer.resolve(.profileService) else {
            fatalError("ProfileService 未在 DIContainer 中注册")
        }
        _viewModel = StateObject(wrappedValue: ProfileViewModel(profileService: service, userId: userId))
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 15) {
                // Header (Banner) View
                GeometryReader { proxy -> AnyView in
                    // 使用命名坐标空间 "scroll" 得到准确的偏移
                    let minY = proxy.frame(in: .named("scroll")).minY
                    return AnyView(
                        ZStack {
                            // Banner 图片：高度为 180，下拉时高度增加
                            Image("SSC_banner")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: getRect().width, height: minY > 0 ? 180 + minY : 180)
                                .clipped()
                            
                            // 模糊效果：从 20 点开始逐渐出现，到 80 点全模糊
                            BlurView(style: .light)
                                .opacity(blurViewOpacity())
                            
                            // 标题文本：显示用户名和 "150 Tweets"
                            VStack(spacing: 5) {
                                Text(viewModel.user?.name ?? "")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text("150 Tweets")
                                    .foregroundColor(.white)
                            }
                            // 初始偏移为 120，向上滚动时上移一定距离（使用 textOffset）
                            .offset(y: 120 - getTitleTextOffset())
                            // 当向上滚动超过 80 点时，文本开始淡出
                            .opacity(max(1 - ((max(-offset, 0) - 80) / 70), 0))
                        }
                        .frame(height: minY > 0 ? 180 + minY : 180)
                        // Sticky & Stretchy 效果
                        .offset(y: minY > 0 ? -minY : (-minY < 80 ? 0 : -minY - 80))
                        // 通过 Preference 将 minY 传递出去
                        .background(Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: minY))
                    )
                }
                .frame(height: 180)
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    self.offset = value
                    // 这里直接使用 -value 作为向上滚动距离（正值）
                    self.titleOffset = max(-value, 0)
                }
                .zIndex(1)
                
                // Profile Image 及其它信息部分
                VStack {
                    HStack {
                        VStack {
                            if profileImage == nil {
                                Button {
                                    self.imagePickerRepresented.toggle()
                                } label: {
                                    KFImage(viewModel.getAvatarURL())
                                        .placeholder {
                                            Image("blankpp")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 75, height: 75)
                                                .clipShape(Circle())
                                        }
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 75, height: 75)
                                        .clipShape(Circle())
                                        .padding(8)
                                        .background(colorScheme == .dark ? Color.black : Color.white)
                                        .clipShape(Circle())
                                        // 根据滚动偏移调整头像垂直位置与缩放
                                        .offset(y: offset < 0 ? getAvatarOffset() : -20)
                                        .scaleEffect(getAvatarScale())
                                }
                            } else if let image = profileImage {
                                VStack {
                                    HStack(alignment: .top) {
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 75, height: 75)
                                            .clipShape(Circle())
                                            .padding(8)
                                            .background(colorScheme == .dark ? Color.black : Color.white)
                                            .clipShape(Circle())
                                            .offset(y: offset < 0 ? getAvatarOffset() : -20)
                                    }
                                    .padding()
                                    Spacer()
                                }
                            }
                        }
                        Spacer()
                        if self.isCurrentUser {
                            Button(action: {
                                editProfileShow.toggle()
                            }, label: {
                                Text("Edit Profile")
                                    .foregroundColor(.blue)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal)
                                    .background(
                                        Capsule().stroke(Color.blue, lineWidth: 1.5)
                                    )
                            })
                            .onAppear {
                                KingfisherManager.shared.cache.clearCache()
                            }
                            .sheet(isPresented: $editProfileShow, onDismiss: {
                                KingfisherManager.shared.cache.clearCache()
                            }, content: {
                                // EditProfileView(user: $viewModel.user)
                            })
                        }
                    }
                    .padding(.top, -25)
                    .padding(.bottom, -10)
                    
                    // Profile Data 区域
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(viewModel.user?.name ?? "")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Text("@\(viewModel.user?.username ?? "")")
                                .foregroundColor(.gray)
                            Text(viewModel.user?.bio ?? "Make education not fail! 4️⃣2️⃣ Founder @TurmaApp soon.. @ProbableApp")
                            HStack(spacing: 8) {
                                if let userLocation = viewModel.user?.location, !userLocation.isEmpty {
                                    HStack(spacing: 2) {
                                        Image(systemName: "mappin.circle.fill")
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(.gray)
                                        Text(userLocation)
                                            .foregroundColor(.gray)
                                            .font(.system(size: 14))
                                    }
                                }
                                if let userWebsite = viewModel.user?.website, !userWebsite.isEmpty {
                                    HStack(spacing: 2) {
                                        Image(systemName: "link")
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(.gray)
                                        Text(userWebsite)
                                            .foregroundColor(Color("twitter"))
                                            .font(.system(size: 14))
                                    }
                                }
                            }
                            HStack(spacing: 5) {
                                Text("4,560")
                                    .foregroundColor(.primary)
                                    .fontWeight(.semibold)
                                Text("Followers")
                                    .foregroundColor(.gray)
                                Text("680")
                                    .foregroundColor(.primary)
                                    .fontWeight(.semibold)
                                    .padding(.leading, 10)
                                Text("Following")
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 8)
                        }
                        .padding(.leading, 8)
                        .overlay(
                            GeometryReader { proxy -> Color in
                                let minY = proxy.frame(in: .global).minY
                                // 此处可以根据需要更新 titleOffset（或其他状态）
                                DispatchQueue.main.async {
                                    self.titleOffset = max(-minY, 0)
                                }
                                return Color.clear
                            }
                            .frame(width: 0, height: 0),
                            alignment: .top
                        )
                        Spacer()
                    }
                    
                    // 分段菜单
                    VStack(spacing: 0) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                TabButton(title: "Tweets", currentTab: $currentTab, animation: animation)
                                TabButton(title: "Tweets & Likes", currentTab: $currentTab, animation: animation)
                                TabButton(title: "Media", currentTab: $currentTab, animation: animation)
                                TabButton(title: "Likes", currentTab: $currentTab, animation: animation)
                            }
                        }
                        Divider()
                    }
                    .padding(.top, 30)
                    .background(colorScheme == .dark ? Color.black : Color.white)
                    .offset(y: tabBarOffset < 90 ? -tabBarOffset + 90 : 0)
                    .overlay(
                        GeometryReader { reader -> Color in
                            let minY = reader.frame(in: .global).minY
                            DispatchQueue.main.async {
                                self.tabBarOffset = minY
                            }
                            return Color.clear
                        }
                        .frame(width: 0, height: 0),
                        alignment: .top
                    )
                    .zIndex(1)
                    
                    // 推文列表
                    TweetListView(tweets: viewModel.tweets, viewModel: viewModel)
                        .zIndex(0)
                }
                .padding(.horizontal)
                .zIndex(-offset > 80 ? 0 : 1)
            }
        }
        .coordinateSpace(name: "scroll")
        // .toolbarBackground(.hidden, for: .navigationBar)
        .ignoresSafeArea(.all, edges: .top)
    }
    
    // MARK: - 辅助函数
    
    func getRect() -> CGRect {
        UIScreen.main.bounds
    }
    
    // 头像缩放效果：向上滚动时从 1.0 缩放到 0.8
    func getAvatarScale() -> CGFloat {
        let currentOffset = max(-offset, 0)
        let maxOffset: CGFloat = 80
        let minScale: CGFloat = 0.8
        let progress = min(currentOffset / maxOffset, 1)
        return 1.0 - progress * (1.0 - minScale)
    }
    
    // 头像垂直偏移：向上滚动时最多平移 20 点
    func getAvatarOffset() -> CGFloat {
        let currentOffset = max(-offset, 0)
        let maxOffset: CGFloat = 20
        let progress = min(currentOffset / 80, 1)
        return progress * maxOffset
    }
    
    // 标题文本上移：这里采用简单公式：上移量 = (-offset) * 0.5
    func getTitleTextOffset() -> CGFloat {
        return max(-offset, 0) * 0.5
    }
    
    // 模糊透明度：初始完全清晰，当向上滚动超过 20 点后开始模糊，到 80 点时全模糊
    func blurViewOpacity() -> Double {
        let currentOffset = max(-offset, 0)
        let startBlur: CGFloat = 20
        let fullBlur: CGFloat = 80
        if currentOffset < startBlur {
            return 0
        } else {
            let progress = min((currentOffset - startBlur) / (fullBlur - startBlur), 1)
            return Double(progress)
        }
    }
}

extension View {
    func getRect() -> CGRect {
        UIScreen.main.bounds
    }
}

// MARK: - TabButton
struct TabButton: View {
    var title: String
    @Binding var currentTab: String
    var animation: Namespace.ID
    
    var body: some View {
        Button(action: {
            withAnimation {
                currentTab = title
            }
        }, label: {
            LazyVStack(spacing: 12) {
                Text(title)
                    .fontWeight(.semibold)
                    .foregroundColor(currentTab == title ? .blue : .gray)
                    .padding(.horizontal)
                if currentTab == title {
                    Capsule()
                        .fill(Color.blue)
                        .frame(height: 1.2)
                        .matchedGeometryEffect(id: "TAB", in: animation)
                } else {
                    Capsule()
                        .fill(Color.clear)
                        .frame(height: 1.2)
                }
            }
        })
    }
}

// MARK: - TweetListView
struct TweetListView: View {
    var tweets: [Tweet]
    var viewModel: ProfileViewModel
    @Environment(\.diContainer) private var container
    @EnvironmentObject private var authViewModel: AuthState 
    var body: some View {
        VStack(spacing: 18) {
            ForEach(tweets) { tweet in
                TweetCellView(
                    viewModel: TweetCellViewModel(
                        tweet: tweet,
                        tweetService: container.resolve(.tweetService) ?? TweetService(apiClient: APIClient(baseURL: APIConfig.baseURL)),   notificationService:container.resolve(.notificationService) ?? NotificationService(apiClient:APIClient( baseURL: APIConfig.baseURL)), currentUserId: authViewModel.currentUser?.id ?? ""
                    )
                 
                )
                Divider()
            }
        }
        .padding(.top)
        .zIndex(0)
    }
}
