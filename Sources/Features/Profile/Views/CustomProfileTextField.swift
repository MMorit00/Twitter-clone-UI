
import SwiftUI 

struct CustomProfileTextField: View {
    // 绑定的文本值
    @Binding var message: String
    // placeholder文本
    let placeholder: String

    var body: some View {
        ZStack(alignment: .leading) {
            // 只在文本为空时显示placeholder
            if message.isEmpty {
                HStack {
                    Text(placeholder)
                        .foregroundColor(.gray)
                    Spacer()
                }
            }

            // 文本输入框
            TextField("", text: $message)
                .foregroundColor(.blue)
        }
    }
}

struct CustomProfileBioTextField: View {
    // 绑定的文本值
    @Binding var bio: String

    var body: some View {
        VStack(alignment: .leading) {
            // 使用ZStack实现placeholder的叠加效果
            ZStack(alignment: .topLeading) {
                // 只在bio为空时显示placeholder
                if bio.isEmpty {
                    HStack {
                        Text("Add bio to your profile")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding([.top, .leading], 8)
                    .zIndex(1)
                }

                // 多行文本编辑器
                TextEditor(text: $bio)
                    .foregroundColor(.blue)
            }
        }
        .frame(height: 90)
    }
}
