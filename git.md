-- a/Sources/Features/Main/Views/MainView.swift
+++ b/Sources/Features/Main/Views/MainView.swift
@@ -4,10 +4,11 @@ struct MainView: View {
     @State private var navigationPath = NavigationPath()
     @State private var showMenu = false
     @State private var showProfile = false
+    @State private var profileUserId: String? = nil  // 新增：用于存储用户 ID
     @State private var offset: CGFloat = 0
     @State private var selectedTab = 0 // 添加这行
     @EnvironmentObject private var viewModel: AuthState
+    @Environment(\.diContainer) private var diContainer: DIContainer 
 
     // 侧边菜单宽度（为了方便修改）
     private var menuWidth: CGFloat {
@@ -50,13 +51,15 @@ struct MainView: View {
                     .allowsHitTesting(showMenu)
 
                 // 2. 侧边菜单视图
+                SlideMenu(onProfileTap: { userId in
+                    // 当点击头像时，将传入的 userId 存储，并触发导航到 ProfileView
+                    self.profileUserId = userId
+                    self.showProfile = true
+                })
+                .frame(width: menuWidth)
+                .background(Color.white)
+                .offset(x: offset - menuWidth)
+                .zIndex(2) // 添加最高层级
 
                 // 3. 用于菜单拖拽手势的透明层
                 if showMenu {
@@ -77,10 +80,11 @@ struct MainView: View {
                         .zIndex(1)
                 }
             }
+            // 导航到 ProfileView 时传入 profileUserId（此处 profileUserId 为非 nil 的当前用户 ID）
             .navigationDestination(isPresented: $showProfile) {
+                ProfileView(userId: profileUserId, diContainer: diContainer)
             }
+            .toolbar(.hidden, for: .tabBar) // 只隐藏 tabBar
         }
     }
 
@@ -138,4 +142,4 @@ struct MainView: View {
         offset = 0
         showMenu = false
     }
+}
\ No newline at end of file
--- a/Sources/Features/Main/Views/SettingsView.swift
+++ b/Sources/Features/Main/Views/SettingsView.swift
@@ -1,31 +1,31 @@
+import SwiftUI
+
+struct SettingsView: View {
+   @Environment(\.dismiss) private var dismiss
+   @EnvironmentObject private var authViewModel: AuthState
+   
+   var body: some View {
+       NavigationView {
+           List {
+               Section {
+                   Button(action: {
+                       authViewModel.signOut()
+                       dismiss()
+                   }) {
+                       Text("Log Out")
+                           .foregroundColor(.red)
+                   }
+               }
+           }
+           .navigationTitle("Settings and Privacy")
+           .navigationBarTitleDisplayMode(.inline)
+           .toolbar {
+               ToolbarItem(placement: .navigationBarLeading) {
+                   Button("Cancel") {
+                       dismiss()
+                   }
+               }
+           }
+       }
+   }
+}
--- a/Sources/Features/Main/Views/SlideMenu.swift
+++ b/Sources/Features/Main/Views/SlideMenu.swift
@@ -1,142 +1,148 @@
+import Kingfisher
+import SwiftUI
+
+struct SlideMenu: View {
+   @EnvironmentObject private var authViewModel: AuthState // 注入 AuthState
+   @State private var showSettings = false  // 添加这一行
+
+  // 修改 onProfileTap，接收 String 参数
+    var onProfileTap: (String) -> Void
+   @State private var isExpanded = false
+   @ObserveInjection var inject
+   private var avatarURL: URL? {
+     guard let user = authViewModel.currentUser else {  // 使用 authViewModel.currentUser
+           return nil
+       }
+       return URL(string: "http://localhost:3000/users/\(user.id)/avatar")
+   }
+
+   var body: some View {
+       VStack(alignment: .leading) {
+           // 顶部用户信息区域
+           HStack(alignment: .top, spacing: 0) {
+               VStack(alignment: .leading, spacing: 0) {
+                   Button {
+                         // 当点击头像时，如果当前用户存在，则将 user.id 传给 onProfileTap 回调
+                        if let userId = authViewModel.currentUser?.id {
+                            onProfileTap(userId)
+                        }
+                   } label: {
+                       HStack {
+                           KFImage(avatarURL)
+                               .placeholder {
+                                   Circle()
+                                       .fill(.gray)
+                                       .frame(width: 44, height: 44)
+                               }
+                               .resizable()
+                               .scaledToFill()
+                               .frame(width: 44, height: 44)
+                               .clipShape(Circle())
+                               .padding(.bottom, 12)
+
+                           VStack(alignment: .leading, spacing: 0) {
+                             Text(authViewModel.currentUser?.name ?? "")
+                                   .font(.system(size: 14))
+                                   .padding(.bottom, 4)
+                               Text("@\(authViewModel.currentUser?.username ?? "" )")
+                                   .font(.system(size: 12))
+                                   .bold()
+                                   .foregroundColor(.gray)
+                           }
+                       }
+                   }
+                   .contentShape(Rectangle())
+               }
+               Spacer()
+
+               Button(action: {
+                   isExpanded.toggle()
+               }) {
+                   Image(systemName: "chevron.down")
+                       .font(.system(size: 16))
+               }
+               .padding(.top, 12)
+           }
+
+           // 关注信息区域
+           HStack(spacing: 0) {
+            //    Text("\(authViewModel.user!.following.count) ")
+            Text("324")
+                   .font(.system(size: 14))
+                   .bold()
+               Text("Following")
+                   .foregroundStyle(.gray)
+                   .font(.system(size: 14))
+                   .bold()
+                   .padding(.trailing, 8)
+            //    Text("\(authViewModel.user!.followers.count) ")
+            Text("253")
+                   .font(.system(size: 14))
+                   .bold()
+               Text("Followers")
+                   .font(.system(size: 14))
+                   .foregroundStyle(.gray)
+                   .bold()
+           }
+
+           .padding(.top, 4)
+
+           // 主菜单列表区域
+           VStack(alignment: .leading, spacing: 0) {
+               ForEach([
+                   ("person", "Profile"),
+                   ("list.bullet", "Lists"),
+                   ("number", "Topics"),
+                   ("bookmark", "Bookmarks"),
+                   ("sparkles", "Moments"),
+               ], id: \.1) { icon, text in
+                   HStack {
+                       Image(systemName: icon)
+                           .font(.system(size: 20))
+                           .padding(16)
+                           .padding(.leading, -16)
+
+                       Text(text)
+                           .font(.system(size: 18))
+                           .bold()
+                   }
+               }
+           }
+           .padding(.vertical, 12)
+
+           Divider()
+               .padding(.bottom, 12 + 16)
+
+           // 底部区域
+           VStack(alignment: .leading, spacing: 12) {
+               Button {
+                   showSettings = true
+               } label: {
+                   Text("Settings and privacy")
+                       .font(.system(size: 14))
+                       .bold()
+               }
+               
+               Text("Help Center")
+                   .font(.system(size: 14))
+                   .foregroundStyle(.gray)
+
+               HStack {
+                   Image(systemName: "lightbulb")
+                   Spacer()
+                   Image(systemName: "qrcode")
+               }
+               .font(.title3)
+               .padding(.vertical, 12)
+               .bold()
+           }
+       }
+       .sheet(isPresented: $showSettings) {
+           SettingsView()
+       }
+       .padding(.top, 12)
+       .padding(.horizontal, 24)
+       .frame(maxHeight: .infinity, alignment: .top)
+       .enableInjection()
+   }
+}
--- a/git.md
+++ b/git.md
@@ -1,1912 +0,0 @@
\ No newline at end of file