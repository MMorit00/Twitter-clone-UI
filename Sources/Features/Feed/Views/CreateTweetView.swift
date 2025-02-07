import SwiftUI

struct CreateTweetView: View {
    @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss
    @Environment(\.diContainer) private var container
    @EnvironmentObject private var authState: AuthState
    
    @State private var tweetText: String = ""
    @State private var imagePickerPresented = false
    @State private var selectedImage: UIImage?
    @State private var postImage: Image?
    @State private var width = UIScreen.main.bounds.width
    
    // Move viewModel to a computed property
    @StateObject private var viewModel: CreateTweetViewModel = {
        let container = DIContainer.defaultContainer()
        let tweetService: TweetServiceProtocol = container.resolve(.tweetService) ?? 
            TweetService(apiClient: APIClient(baseURL: APIConfig.baseURL))
        return CreateTweetViewModel(tweetService: tweetService)
    }()
    
    init() {
        let tweetService: TweetServiceProtocol = container.resolve(.tweetService) ?? 
            TweetService(apiClient: APIClient(baseURL: APIConfig.baseURL))
        _viewModel = StateObject(wrappedValue: CreateTweetViewModel(
            tweetService: tweetService
        ))
    }
    
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
                    guard !tweetText.isEmpty else { return }
                    Task {
                        await viewModel.createTweet(
                            text: tweetText,
                            image: selectedImage,
                            currentUser: authState.currentUser
                        )
                        dismiss()
                    }
                }) {
                    Text("Tweet")
                }
                .buttonStyle(.borderedProminent)
                .cornerRadius(40)
                .disabled(tweetText.isEmpty || viewModel.isLoading)
            }
            .padding()
            
            MultilineTextField(text: $tweetText, placeholder: "有什么新鲜事？")
                .padding(.horizontal)
            
            // 图片预览
            if let image = postImage {
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
                Button(action: {
                    imagePickerPresented.toggle()
                }) {
                    Image(systemName: "photo")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
                .disabled(viewModel.isLoading)
                
                Spacer()
                
                Text("\(tweetText.count)/280")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .alert("发送失败", isPresented: .constant(viewModel.error != nil)) {
            Button("确定") {
                viewModel.error = nil
            }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "未知错误")
        }
        .sheet(isPresented: $imagePickerPresented) {
            loadImage()
        } content: {
            ImagePicker(image: $selectedImage)
                .presentationDetents([.large])
                .edgesIgnoringSafeArea(.all)
        }
        .enableInjection()
    }
}

// 图片处理扩展
extension CreateTweetView {
    func loadImage() {
        if let image = selectedImage {
            postImage = Image(uiImage: image)
        }
    }
}

