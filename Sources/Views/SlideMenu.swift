import SwiftUI

struct SlideMenu: View {
    @State private var isExpanded = false
    @ObserveInjection var inject

    var body: some View {
        VStack(alignment: .leading) {
            // 顶部用户信息区域
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Circle()
                        .fill(.gray)
                        .frame(width: 44, height: 44)
                        .padding(.bottom,12)


                    VStack(alignment: .leading, spacing: 0) {
                        Text("用户名")
                            .font(.system(size: 14))
                            .padding(.bottom, 4)
                        Text("@username")
                            .font(.system(size: 12))
                            .bold()
                            .foregroundColor(.gray)

                    }
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
                Text("8 ")
                    .font(.system(size: 14))
                    .bold()
                Text("Following")
                    .foregroundStyle(.gray)
                    .font(.system(size: 14))
                    .bold()
                    .padding(.trailing, 8)
                Text("12 ")
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
                    ("sparkles", "Moments")
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
                Text("Settings and privacy")
                    .font(.system(size: 14))
                    .bold()
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
        .padding(.top, 12)
        .padding(.horizontal, 24)
        .frame(maxHeight: .infinity, alignment: .top)
        .enableInjection()
    }
}
