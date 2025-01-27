import SwiftUI

struct TopBar: View {
    let width = UIScreen.main.bounds.width
    @ObserveInjection var inject
    @Binding var showMenu: Bool
    @Binding var offset: CGFloat
    

    var body: some View {
        VStack {
            HStack {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 35, height: 35)
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
                Image("X")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 25, height: 25),
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
