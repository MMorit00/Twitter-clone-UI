import SwiftUI

struct MainView: View {
    @State private var navigationPath = NavigationPath()
    @State private var showMenu = false
    @State private var showProfile = false  // 新增状态控制导航
    @State private var offset: CGFloat = 0
    // @State private var selectedUser: User? = nil
    let user: User
    // 侧边菜单宽度（为了方便修改）
    private var menuWidth: CGFloat {
        UIScreen.main.bounds.width - 90
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .leading) {
                // 1. 主界面内容
                VStack(spacing: 0) {
                    // 顶部导航条，这里仅示例
                    TopBar(showMenu: $showMenu, offset: $offset)

                    // HomeView 里面有 TabView 等
                    HomeView(user: user)
                }
                // 根据 offset 偏移，用于把主界面往右推
                .offset(x: offset)
                // 当菜单展开时，若需要禁止主界面交互，可在此启用:
                // .disabled(showMenu)

                // 半透明蒙版，用于点击/拖拽关闭菜单
                Color.gray
                    .opacity(0.3 * min(offset / (UIScreen.main.bounds.width - 90), 1.0))
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showMenu = false
                            offset = 0
                        }
                    }
                    .allowsHitTesting(showMenu)

                // 2. 侧边菜单视图
                SlideMenu(user: user, onProfileTap: {
                    showProfile = true
                })
                .frame(width: menuWidth)
                .background(Color.white)
                .offset(x: offset - menuWidth)
                .zIndex(2) // 添加最高层级

                // 3. 用于菜单拖拽手势的透明层
                if showMenu {
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .gesture(dragGesture)
                        .frame(width: UIScreen.main.bounds.width - menuWidth)
                        .offset(x: menuWidth) // 只覆盖非菜单区域
                        .zIndex(1)
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .frame(width: 30)
                        .gesture(dragGesture)
                        .zIndex(1)
                }
            }
            .navigationDestination(isPresented: $showProfile) {
                ProfileView(user: user)
            }
            .toolbar(.hidden, for: .tabBar) // 只隐藏tabBar
        }
    }

    /// 将 DragGesture 封装，给上面透明视图使用
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                // 计算当前手指移动量（根据是否已经在菜单展开状态，做相对位移）
                let translation = gesture.translation.width

                if !showMenu {
                    // 菜单未展开时，手势从左向右拉出
                    // offset 最大只能到 menuWidth
                    offset = max(0, min(translation, menuWidth))
                } else {
                    // 菜单已展开，手势可能关闭菜单
                    // 基准点为展开状态下 offset=menuWidth，所以要加上 menuWidth
                    offset = max(0, min(menuWidth, translation + menuWidth))
                }
            }
            .onEnded { gesture in
                let translation = gesture.translation.width
                // 计算手指在结束时的速度或位置
                let predictedEnd = gesture.predictedEndLocation.x - gesture.startLocation.x
                let threshold = menuWidth / 2

                withAnimation(.easeInOut(duration: 0.3)) {
                    if !showMenu {
                        // 原来是关闭状态
                        // 判断是否要展开
                        if predictedEnd > 200 || offset > threshold {
                            openMenu()
                        } else {
                            closeMenu()
                        }
                    } else {
                        // 原来是打开状态
                        // 判断是否要关闭
                        if predictedEnd < -200 || offset < threshold {
                            closeMenu()
                        } else {
                            openMenu()
                        }
                    }
                }
            }
    }

    private func openMenu() {
        offset = menuWidth
        showMenu = true
    }

    private func closeMenu() {
        offset = 0
        showMenu = false
    }
}
