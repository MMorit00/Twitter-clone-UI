import Kingfisher
import SwiftUI

struct TopBar: View {
    let width = UIScreen.main.bounds.width
    @ObserveInjection var inject
    @Binding var showMenu: Bool
    @Binding var offset: CGFloat
    @Binding var selectedTab: Int // 添加这行
    @EnvironmentObject private var authViewModel: AuthViewModel
  @Binding var searchText: String
  @Binding var isSearching: Bool
    private var avatarURL: URL? {
        guard let user = authViewModel.user else {
            return nil
        }
        return URL(string: "http://localhost:3000/users/\(user.id)/avatar")
    } 
    var body: some View {
        VStack {
            HStack {
                // 替换Circle为KFImage
                KFImage(avatarURL)
                    .placeholder {
                        Image("blankpp") // 使用默认头像作为占位图
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 35, height: 35)
                    .clipShape(Circle())
                    .opacity(1.0 - (offset / (UIScreen.main.bounds.width - 90)))
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showMenu.toggle()
                            if showMenu {
                                offset = UIScreen.main.bounds.width - 90
                            } else {
                                offset = 0
                            }
                        }
                    }

                Spacer()

                Image(systemName: "ellipsis")
                    .font(.system(size: 24))
                    .foregroundColor(.black)
            }
            .overlay(
                Group {
                    switch selectedTab {
                    case 0:
                        Image("X")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 25, height: 25)
                    case 1:
                        SearchBar(text: $searchText, isEditing: $isSearching)
                            .frame(width: width * 0.7)
                    case 2:
                        Text("Notifications")
                            .font(.headline)
                    case 3:
                        Text("Messages")
                            .font(.headline)
                    default:
                        EmptyView()
                    }
                },
                alignment: .center
            )
            .padding(.top, 6)
            .padding(.bottom, 8)
            .padding(.horizontal, 12)

            // 底部分隔线
            Rectangle()
                .frame(width: width, height: 1)
                .foregroundColor(.gray)
                .opacity(0.3)
        }
        .background(Color.white)
        .enableInjection()
    }
}
