import SwiftUI

struct MessageCell: View {
    @State private var width = UIScreen.main.bounds.width
    @ObserveInjection var inject 
    var body: some View {
        VStack(alignment: .leading, spacing: nil) {
            // 1. 分隔线
            Rectangle()
                .frame(width: width, height: 1)
                .foregroundColor(.gray)
                .opacity(0.3)
            
            // 2. 主要内容区域
            HStack(alignment: .top) {
                // 头像
                Circle()
                    .fill(Color.gray)
                    .frame(width: 60, height: 60)
                    .padding(.leading)
                
                // 右侧信息区域
                VStack(alignment: .leading) {
                    // 用户信息行
                    HStack {
                        Text("Bruce Wayne")
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Text("@_bruce")
                                .foregroundColor(.gray)
                            
                            Spacer(minLength: 0)
                            
                            Text("6/28/21")
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 2)
                    }
                    
                    // 最后一条消息
                    Text("Hey, how's it going?")
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
                .padding(.trailing)
            } 
        }
        .frame(width: width, height: 84)
        .enableInjection()
    }
}

#Preview {
    MessageCell()
}