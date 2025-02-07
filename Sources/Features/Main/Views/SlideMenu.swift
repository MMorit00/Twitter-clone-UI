import Kingfisher
import SwiftUI

struct SlideMenu: View {
   @EnvironmentObject private var authViewModel: AuthState // 注入 AuthState
   @State private var showSettings = false  // 添加这一行

  // 修改 onProfileTap，接收 String 参数
    var onProfileTap: (String) -> Void
   @State private var isExpanded = false
   @ObserveInjection var inject
   private var avatarURL: URL? {
     guard let user = authViewModel.currentUser else {  // 使用 authViewModel.currentUser
           return nil
       }
       return URL(string: "http://localhost:3000/users/\(user.id)/avatar")
   }

   var body: some View {
       VStack(alignment: .leading) {
           // 顶部用户信息区域
           HStack(alignment: .top, spacing: 0) {
               VStack(alignment: .leading, spacing: 0) {
                   Button {
                         // 当点击头像时，如果当前用户存在，则将 user.id 传给 onProfileTap 回调
                        if let userId = authViewModel.currentUser?.id {
                            onProfileTap(userId)
                        }
                   } label: {
                       HStack {
                           KFImage(avatarURL)
                               .placeholder {
                                   Circle()
                                       .fill(.gray)
                                       .frame(width: 44, height: 44)
                               }
                               .resizable()
                               .scaledToFill()
                               .frame(width: 44, height: 44)
                               .clipShape(Circle())
                               .padding(.bottom, 12)

                           VStack(alignment: .leading, spacing: 0) {
                             Text(authViewModel.currentUser?.name ?? "")
                                   .font(.system(size: 14))
                                   .padding(.bottom, 4)
                               Text("@\(authViewModel.currentUser?.username ?? "" )")
                                   .font(.system(size: 12))
                                   .bold()
                                   .foregroundColor(.gray)
                           }
                       }
                   }
                   .contentShape(Rectangle())
               }
               Spacer()

               Button(action: {
                   isExpanded.toggle()
               }) {
                   Image(systemName: "chevron.down")
                       .font(.system(size: 16))
               }
               .padding(.top, 12)
           }

           // 关注信息区域
           HStack(spacing: 0) {
            //    Text("\(authViewModel.user!.following.count) ")
            Text("324")
                   .font(.system(size: 14))
                   .bold()
               Text("Following")
                   .foregroundStyle(.gray)
                   .font(.system(size: 14))
                   .bold()
                   .padding(.trailing, 8)
            //    Text("\(authViewModel.user!.followers.count) ")
            Text("253")
                   .font(.system(size: 14))
                   .bold()
               Text("Followers")
                   .font(.system(size: 14))
                   .foregroundStyle(.gray)
                   .bold()
           }

           .padding(.top, 4)

           // 主菜单列表区域
           VStack(alignment: .leading, spacing: 0) {
               ForEach([
                   ("person", "Profile"),
                   ("list.bullet", "Lists"),
                   ("number", "Topics"),
                   ("bookmark", "Bookmarks"),
                   ("sparkles", "Moments"),
               ], id: \.1) { icon, text in
                   HStack {
                       Image(systemName: icon)
                           .font(.system(size: 20))
                           .padding(16)
                           .padding(.leading, -16)

                       Text(text)
                           .font(.system(size: 18))
                           .bold()
                   }
               }
           }
           .padding(.vertical, 12)

           Divider()
               .padding(.bottom, 12 + 16)

           // 底部区域
           VStack(alignment: .leading, spacing: 12) {
               Button {
                   showSettings = true
               } label: {
                   Text("Settings and privacy")
                       .font(.system(size: 14))
                       .bold()
               }
               
               Text("Help Center")
                   .font(.system(size: 14))
                   .foregroundStyle(.gray)

               HStack {
                   Image(systemName: "lightbulb")
                   Spacer()
                   Image(systemName: "qrcode")
               }
               .font(.title3)
               .padding(.vertical, 12)
               .bold()
           }
       }
       .sheet(isPresented: $showSettings) {
           SettingsView()
       }
       .padding(.top, 12)
       .padding(.horizontal, 24)
       .frame(maxHeight: .infinity, alignment: .top)
       .enableInjection()
   }
}
