import SwiftUI

struct NotificationCell: View {
    // 屏幕宽度常量
    private let screenWidth = UIScreen.main.bounds.width

    @ObserveInjection var inject
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 顶部分隔线
            Rectangle()
                .frame(width: screenWidth, height: 1)
                .foregroundColor(.gray)
                .opacity(0.3)

            // 主要内容
            HStack(alignment: .top, spacing: 8) {

                // 通知类型图标
                Image(systemName: "person.2.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.blue)
                VStack(alignment: .leading, spacing: 0) {
                    // 用户头像
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 36, height: 36)
                        .cornerRadius(18)

                    // 通知内容
                    HStack(alignment: .center, spacing: 5) {
                        Text("John Doe")
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        Text("followed you")
                            .foregroundColor(.gray)
                    }

                    Spacer(minLength: 0)
                }
            }
            .padding(.leading, 30)
            .padding(.top, 12)
            .padding(.bottom, 12)
        }
        .enableInjection()
    }
}
