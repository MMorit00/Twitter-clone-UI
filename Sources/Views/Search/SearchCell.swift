
import SwiftUI 


struct SearchCell: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Trending")
                .foregroundColor(.gray)
                .font(.system(size: 14))
            
            Text("SwiftUI")
                .fontWeight(.heavy)
                .padding(.vertical, 2)
            
            Text("10.5K Tweets")
                .foregroundColor(.gray)
                .font(.system(size: 14))
        }
        .padding(.vertical, 8)
        // 添加点击效果
        .contentShape(Rectangle())
        .onTapGesture {
            // 处理点击事件
            print("Trend topic tapped")
        }
    }

    
}