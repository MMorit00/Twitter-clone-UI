import SwiftUI
//! 无法解决 tap 与 手势冲突的 问题  -> 可以尝试UIKit    
struct MainView: View {
    @ObserveInjection var inject
    @State private var showMenu = false
    @State private var offset: CGFloat = 0

    var body: some View {
        ZStack(alignment: .leading) {
            // 主内容
            VStack(spacing: 0) {
                TopBar(showMenu: $showMenu, offset: $offset)
                HomeView()
            }
            .offset(x: offset)

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
              


            // 侧边菜单
            SlideMenu()
                .frame(width: UIScreen.main.bounds.width - 90)
                .background(Color.white)
                .offset(x: offset - (UIScreen.main.bounds.width - 90))

            // 白色前景遮罩 - 完全重构
            Rectangle() // 使用Rectangle替代Color
                .fill(Color.white)
                .opacity(0.6 * min(1.0 - offset / (UIScreen.main.bounds.width - 90), 1.0))
                .frame(width: UIScreen.main.bounds.width - 90)
                .frame(maxHeight: .infinity) // 确保填充整个高度
                .offset(x: offset - (UIScreen.main.bounds.width - 90))
                .ignoresSafeArea()
                .contentShape(Rectangle()) // 确保正确的点击区域
        }
        // 统一的手势处理
        .contentShape(Rectangle()) // 确保整个ZStack可以接收手势
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    let translation = gesture.translation.width
                    if !showMenu {
                        offset = max(0, min(translation, UIScreen.main.bounds.width - 90))
                    } else {
                        offset = max(0, min(UIScreen.main.bounds.width - 90, translation + UIScreen.main.bounds.width - 90))
                    }
                }
                .onEnded { gesture in
                    let velocity = gesture.predictedEndLocation.x - gesture.location.x
                    let threshold = UIScreen.main.bounds.width - 90

                    withAnimation(.easeInOut(duration: 0.3)) {
                        // 降低速度阈值，提高灵敏度
                        if !showMenu {
                            if velocity > 300 || offset > threshold / 2 {
                                showMenu = true
                                offset = threshold
                            } else {
                                offset = 0
                            }
                        } else {
                            // 放宽轻触判定范围
                            if abs(velocity) < 30 && gesture.location.x < threshold {
                                showMenu = false
                                offset = 0
                            }
                            // 降低关闭的速度阈值
                            else if velocity < -300 || offset < threshold / 2 {
                                showMenu = false
                                offset = 0
                            } else {
                                offset = threshold
                            }
                        }
                    }
                }
        )
        .enableInjection()
    }
}
