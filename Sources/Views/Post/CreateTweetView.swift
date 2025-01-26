import SwiftUI

struct CreateTweetView: View {
    @ObserveInjection var inject
    @State private var tweetText: String = ""

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    print("Cancel")
                }) {
                    Text("Cancel")
                }
                Spacer()
                Button(action: {
                    print("Tweet")
                }) {
                    Text("Tweet")
                }
                .buttonStyle(.borderedProminent)
                .cornerRadius(40)
            }
            .padding()

            /*
             2. 多行文本输入框的实现:
             - 使用 UIViewRepresentable 来桥接 UIKit 和 SwiftUI
             - 创建了自定义的 MultilineTextField
             - 用到了 Coordinator 模式来处理文本输入的代理方法
             - 实现了占位文字、字体大小、文字颜色等定制
             */

            MultilineTextField(text: $tweetText, placeholder: "有什么新鲜事？")
                .padding(.horizontal)
            // a button to end editing
            Button(action: {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }) {
                Text("End Editing")
            }
            .padding()
        }
        .enableInjection()
    }
}

#Preview {
    CreateTweetView()
}
