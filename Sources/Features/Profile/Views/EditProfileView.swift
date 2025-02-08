import Kingfisher
import SwiftUI

struct EditProfileView: View {
    @Environment(\.presentationMode) var mode
    @EnvironmentObject private var authState: AuthState // 若需要访问全局登录状态
    @ObservedObject var viewModel: ProfileViewModel // 使用同一个 ProfileViewModel

    // 用户输入的状态变量
    @State private var name: String = ""
    @State private var location: String = ""
    @State private var bio: String = ""
    @State private var website: String = ""

    // 图片相关状态
    @State private var profileImage: UIImage?
    @State private var bannerImage: UIImage?
    @State private var showError = false
    @State private var errorMessage: String?

    // 图片选择器相关状态
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var imagePickerType: ImagePickerType = .profile

    enum ImagePickerType {
        case banner
        case profile
    }

    // 初始化，从 ProfileViewModel.user 中读取现有数据
    init(viewModel: ProfileViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)

        // 若 user 还没加载成功，可以在这里做安全处理
        if let user = viewModel.user {
            _name = State(initialValue: user.name)
            _location = State(initialValue: user.location ?? "")
            _bio = State(initialValue: user.bio ?? "")
            _website = State(initialValue: user.website ?? "")
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            // 主内容区域
            ScrollView {
                VStack {
                    // 图片编辑区域
                    VStack {
                        // Banner图片区域
                        ZStack {
                            if let bannerImage = bannerImage {
                                Image(uiImage: bannerImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 180)
                                    .clipShape(Rectangle())
                            } else {
                                Rectangle()
                                    .fill(Color(.systemGray6))
                                    .frame(height: 180)
                            }

                            // Banner编辑按钮
                            Button(action: {
                                imagePickerType = .banner
                                showImagePicker = true
                            }) {
                                Image(systemName: "camera")
                                    .renderingMode(.template)
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.black.opacity(0.75))
                                    .clipShape(Circle())
                            }
                        }

                        // 头像编辑区域
                        HStack {
                            Button(action: {
                                imagePickerType = .profile
                                showImagePicker = true
                            }) {
                                if let profileImage = profileImage {
                                    Image(uiImage: profileImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 75, height: 75)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: 2)
                                        )
                                } else {
                                    Circle()
                                        .fill(Color(.systemGray6))
                                        .frame(width: 75, height: 75)
                                        .overlay(
                                            Image(systemName: "camera")
                                                .foregroundColor(.white)
                                                .padding(8)
                                                .background(Color.black.opacity(0.75))
                                                .clipShape(Circle())
                                        )
                                }
                            }
                            Spacer()
                        }
                        .padding(.top, -25)
                        .padding(.bottom, -10)
                        .padding(.leading)
                        .padding(.top, -12)
                        .padding(.bottom, 12)
                    }

                    // 个人信息编辑区域
                    VStack {
                        Divider()

                        // Name字段
                        HStack {
                            ZStack {
                                HStack {
                                    Text("Name")
                                        .foregroundColor(.black)
                                        .fontWeight(.heavy)
                                    Spacer()
                                }

                                CustomProfileTextField(
                                    message: $name,
                                    placeholder: "Add your name"
                                )
                                .padding(.leading, 90)
                            }
                        }
                        .padding(.horizontal)

                        Divider()

                        // Location字段
                        HStack {
                            ZStack {
                                HStack {
                                    Text("Location")
                                        .foregroundColor(.black)
                                        .fontWeight(.heavy)
                                    Spacer()
                                }

                                CustomProfileTextField(
                                    message: $location,
                                    placeholder: "Add your location"
                                )
                                .padding(.leading, 90)
                            }
                        }
                        .padding(.horizontal)

                        Divider()

                        // Bio字段
                        HStack {
                            ZStack(alignment: .topLeading) {
                                HStack {
                                    Text("Bio")
                                        .foregroundColor(.black)
                                        .fontWeight(.heavy)
                                    Spacer()
                                }

                                CustomProfileBioTextField(bio: $bio)
                                    .padding(.leading, 86)
                                    .padding(.top, -6)
                            }
                        }
                        .padding(.horizontal)

                        Divider()

                        // Website字段
                        HStack {
                            ZStack {
                                HStack {
                                    Text("Website")
                                        .foregroundColor(.black)
                                        .fontWeight(.heavy)
                                    Spacer()
                                }

                                CustomProfileTextField(
                                    message: $website,
                                    placeholder: "Add your website"
                                )
                                .padding(.leading, 90)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 50)
            }

            // 顶部导航栏
            VStack {
                HStack {
                    Button("Cancel") {
                        mode.wrappedValue.dismiss()
                    }
                    Spacer()
                    Button(action: {
                        Task {
                            await viewModel.updateProfile(data: [
                                "name": name,
                                "bio": bio,
                                "website": website,
                                "location": location,
                            ])
                            authState.currentUser = viewModel.user
                            mode.wrappedValue.dismiss()
                        }
                    }) {
                        Text("Save")
                            .bold()
                    }
                    .disabled(viewModel.isLoading)
                }
                .padding()
                .background(Material.ultraThin)
                .compositingGroup()

                Spacer()
            }

            // ImagePicker 弹窗部分
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
                    .presentationDetents([.large])
                    .edgesIgnoringSafeArea(.all)
                    .onDisappear {
                        Task {
                            await handleSelectedImage()
                        }
                    }
            }
            .alert("上传失败", isPresented: $showError) {
                Button("确定", role: .cancel) {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "未知错误")
            }
        }
//      .onReceive(viewModel.$shouldRefreshImage) { _ in
//     // mode.wrappedValue.dismiss()
        // }
//         .onReceive(viewModel.$user) { updatedUser in
//             // 可选：若 updatedUser != nil，说明资料更新完毕
//         }
        .onAppear {
            // 可选：清除缓存或其他逻辑
            KingfisherManager.shared.cache.clearCache()
        }
    }
}

extension EditProfileView {
  private func handleSelectedImage() async {
        guard let image = selectedImage else { return }

        // 根据选择类型判断上传头像或banner
        if imagePickerType == .profile {
            profileImage = image

            // 注意：字段名称需要与后端保持一致，此处传 "avatar"
            ImageUploader.uploadImage(
                paramName: "avatar", // 修改前为 "image"，现改为 "avatar"
                fileName: "avatar.jpg",
                image: image,
                urlPath: "/users/me/avatar"
            ) { result in
                Task { @MainActor in
                    switch result {
                    case .success:
                        // 上传成功后刷新个人资料
                        await viewModel.fetchProfile()
                    case let .failure(error):
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            }

            await viewModel.uploadAvatar(imageData: image.jpegData(compressionQuality: 0.8)!)

            // 清除所有头像缓存
            await KingfisherManager.shared.cache.clearMemoryCache()
            await KingfisherManager.shared.cache.clearDiskCache()

        } else if imagePickerType == .banner {
            bannerImage = image
            // 如果需要上传 banner，可类似实现：
            /*
             ImageUploader.uploadImage(
                 paramName: "banner",
                 fileName: "banner.jpg",
                 image: image,
                 urlPath: "/users/me/banner"
             ) { result in
                 Task { @MainActor in
                     switch result {
                     case .success(_):
                         await viewModel.fetchProfile()
                     case .failure(let error):
                         errorMessage = error.localizedDescription
                         showError = true
                     }
                 }
             }
             */
        }

        selectedImage = nil
    }
}
