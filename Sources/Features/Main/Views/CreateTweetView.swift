import SwiftUI

struct CreateTweetView: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss
    @State private var tweetText: String = ""
    @StateObject private var viewModel = CreateTweetViewModel()

    // 1. 添加所需的状态变量
    @State private var imagePickerPresented = false
    @State private var selectedImage: UIImage?
    @State private var postImage: Image?
    @State private var width = UIScreen.main.bounds.width // 用于图片宽度计算

    var body: some View {
        VStack(spacing: 0) {
            // 顶部操作栏
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                        .foregroundColor(.gray)
                }

                Spacer()

                Button(action: {
                    // 检查文本非空
                    if !tweetText.isEmpty {
                        // 发送推文,只在有图片时传入
                        viewModel.uploadPost(text: tweetText, image: selectedImage)
                        // 关闭视图
                        dismiss()
                    }
                }) {
                    Text("Tweet")
                }
                .buttonStyle(.borderedProminent)
                .cornerRadius(40)
                // 文本为空时禁用按钮
                .disabled(tweetText.isEmpty)
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

            // 2. 添加图片选择和预览逻辑
            if let image = postImage {
                // 显示已选择的图片预览
                VStack {
                    HStack(alignment: .top) {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: width * 0.9)
                            .cornerRadius(10)
                            .clipped()
                            .padding(.horizontal)
                    }
                    Spacer()
                }
            }

            Spacer()

            // 底部工具栏
            HStack(spacing: 20) {
                // 图片选择按钮
                Button(action: {
                    imagePickerPresented.toggle()
                }) {
                    Image(systemName: "photo")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }

                // 可以在这里添加更多工具栏按钮

                Spacer()

                // 字数统计
                Text("\(tweetText.count)/280")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
        }
        // 3. 添加图片选择器sheet
        .sheet(isPresented: $imagePickerPresented) {
            loadImage()
        } content: {
            ImagePicker(image: $selectedImage)
                .presentationDetents([.large]) // 设置为全屏展示
                .edgesIgnoringSafeArea(.all) // 忽略安全区域
        }
        .enableInjection()
    }
}

// 4. 添加图片处理扩展
extension CreateTweetView {
    func loadImage() {
        if let image = selectedImage {
            postImage = Image(uiImage: image)
        }
    }
}

#Preview {
    CreateTweetView()
}
