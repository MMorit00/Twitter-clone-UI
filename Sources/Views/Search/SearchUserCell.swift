

import SwiftUI

struct SearchUserCell: View {
    var body: some View {
        HStack {
            // 左侧头像
            Circle()
                .fill(.gray)
                .frame(width: 44, height: 44)

            // 右侧用户信息
            VStack(alignment: .leading) {
                Text("Jim")
                    .fontWeight(.heavy)
                Text("@username")
            }

            Spacer(minLength: 0)
        }
    }
}
