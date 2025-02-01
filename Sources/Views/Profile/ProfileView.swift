import SwiftUI
import Kingfisher

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

struct ProfileView: View {
    // MARK: - Properties

    @StateObject var viewModel: ProfileViewModel
    @ObserveInjection var inject
    @State var offset: CGFloat = 0 // 监测最顶端 Banner 的滚动偏移
    @State var titleOffset: CGFloat = 0 // 监测 Profile Data 或标题区域的滚动偏移
    @State var tabBarOffset: CGFloat = 0 // 监测 TabBar 的滚动偏移
    @State private var showEditProfile = false // 添加导航状态

    @State var currentTab = "Tweets"
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss

    // 添加初始化方法
    init(user: User) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(user: user))
    }

    // MARK: - Body

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 15) {
                // MARK: - 1) Banner + Title

                GeometryReader { proxy in
                    let minY = proxy.frame(in: .global).minY

                    ZStack {
                        // 背景 Banner
                        KFImage(URL(string: viewModel.user.bannerURL ?? ""))
                            .placeholder {
                                Rectangle()
                                    .fill(Color(.systemGray6))
                            }
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(
                                width: getRect().width,
                                height: minY > 0 ? 180 + minY : 180
                            )
                            .cornerRadius(0)

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
                    .onChange(of: minY) { newValue in
                        offset = newValue
                    }
                }
                .frame(height: 180)
                .zIndex(1)

                // MARK: - 2) Profile Image + Profile Info

                VStack {
                    // 头像 + 按钮
                    HStack {
                        // 头像
                        ZStack {
                            KFImage(URL(string: viewModel.user.avatarURL ?? ""))
                                .placeholder {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundColor(Color(.systemGray4))
                                }
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 75, height: 75)
                                .clipShape(Circle())
                                .padding(8)
                                .background(colorScheme == .dark ? Color.black : Color.white)
                                .clipShape(Circle())
                                .offset(y: offset < 0 ? getOffset() - 20 : -20)
                                .scaleEffect(getScale())
                        }

                        Spacer()

                        // "Edit Profile" 按钮示例
                        Button {
                            showEditProfile = true
                        } label: {
                            Text("Edit Profile")
                                .foregroundColor(.blue)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(
                                    Capsule()
                                        .stroke(Color.blue, lineWidth: 1.5)
                                )
                        }
                    }
                    .padding(.top, -25)
                    .padding(.bottom, -10)

                    // 用户文本资料
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(viewModel.user.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)

                            Text("@\(viewModel.user.username)")
                                .foregroundColor(.gray)

                            Text(viewModel.user.bio ?? "No bio available")

                            HStack(spacing: 5) {
                                Text("\(viewModel.user.following.count)")
                                    .foregroundColor(.primary)
                                    .fontWeight(.semibold)
                                Text("Following")
                                    .foregroundColor(.gray)

                                Text("\(viewModel.user.followers.count)")
                                    .foregroundColor(.primary)
                                    .fontWeight(.semibold)
                                    .padding(.leading, 10)
                                Text("Followers")
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 8)
                        }
                        .padding(.leading, 8)

                        Spacer()
                    }
                    .overlay(
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: ScrollOffsetPreferenceKey.self, value: proxy.frame(in: .global).minY)
                        }
                        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                            self.titleOffset = value
                        }
                    )

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
                        }
                        .onPreferenceChange(TabBarOffsetPreferenceKey.self) { value in
                            self.tabBarOffset = value
                        }
                    )
                    .zIndex(1)

                    // MARK: - 4) Tweets 列表

                    VStack(spacing: 18) {
                        ForEach(0 ..< 10, id: \.self) { _ in
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 100)
                                .padding(.horizontal)
                            Divider()
                        }
                    }
                    .padding(.top)
                    .zIndex(0)
                }
                .padding(.horizontal)
                .zIndex(-offset > 80 ? 0 : 1)
            }
        }
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
            EditProfileView(user: $viewModel.user)
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
