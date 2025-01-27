import SwiftUI


// ! 无法解决AnyView bug 问题 
struct ProfileView: View {
    // MARK: - Properties
    
    @State var offset: CGFloat = 0       // 监测最顶端 Banner 的滚动偏移
    @State var titleOffset: CGFloat = 0  // 监测 Profile Data 或标题区域的滚动偏移
    @State var tabBarOffset: CGFloat = 0 // 监测 TabBar 的滚动偏移
    
    @State var currentTab = "Tweets"
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Body
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 15) {
                
                // MARK: - 1) Banner + Title
                GeometryReader { proxy -> AnyView in
                    
                    let minY = proxy.frame(in: .global).minY
                    DispatchQueue.main.async {
                        self.offset = minY
                    }
                    
                    return AnyView(
                        ZStack {
                            // 背景 Banner
                            Image("SSC_banner")
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
                            
                            // Title (与原 UserProfile 中类似：offset + opacity)
                            VStack(spacing: 5) {
                                Text("Your Name")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text("150 Tweets")
                                    .foregroundColor(.white)
                            }
                            .offset(y: 120)
                            .offset(y: titleOffset > 100 ? 0 : -getTitleTextOffset())
                            .opacity(titleOffset < 100 ? 1 : 0)
                        }
                        .clipped()
                        .frame(height: minY > 0 ? 180 + minY : nil)
                        // Stretchy 向下拉伸
                        .offset(y: minY > 0 ? -minY : -minY < 80 ? 0 : -minY - 80)
                    )
                    
                }
                .frame(height: 180)
                .zIndex(1)
                
                // MARK: - 2) Profile Image + Profile Info
                VStack {
                    
                    // 头像 + 按钮
                    HStack {
                        // 头像
                        ZStack {
                            Image("blankpp") // 替换成你自己的头像占位
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 75, height: 75)
                                .clipShape(Circle())
                                .padding(8)
                                .background(colorScheme == .dark ? Color.black : Color.white)
                                .clipShape(Circle())
                                // 同样使用 offset/scale, 与原版写法一致
                                .offset(y: offset < 0 ? getOffset() - 20 : -20)
                                .scaleEffect(getScale())
                        }
                        
                        Spacer()
                        
                        // “Edit Profile” 按钮示例
                        Button {
                            print("Edit Profile Tapped")
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
                            Text("Your Name")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("@username")
                                .foregroundColor(.gray)
                            
                            Text("Bio: I don't know what I don't know.\nSo I try to figure out what I don't know.")
                            
                            HStack(spacing: 5) {
                                Text("4,560")
                                    .foregroundColor(.primary)
                                    .fontWeight(.semibold)
                                Text("Followers")
                                    .foregroundColor(.gray)
                                
                                Text("680")
                                    .foregroundColor(.primary)
                                    .fontWeight(.semibold)
                                    .padding(.leading,10)
                                Text("Following")
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 8)
                        }
                        .padding(.leading, 8)
                        
                        Spacer()
                    }
                    .overlay(
                        // 侦测 titleOffset
                        GeometryReader { proxy -> Color in
                            let minY = proxy.frame(in: .global).minY
                            DispatchQueue.main.async {
                                self.titleOffset = minY
                            }
                            return Color.clear
                        }
                        .frame(width: 0, height: 0),
                        alignment: .top
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
                    
                    // MARK: - 4) Tweets 列表
                    VStack(spacing: 18) {
                        // 模拟 10 条数据
                        ForEach(0..<10, id: \.self) { _ in
                            TweetCellView()
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
        // 跟原版一致，忽略顶部安全区
        .ignoresSafeArea(.all, edges: .top)
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

// MARK: - Preview
struct DemoProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
