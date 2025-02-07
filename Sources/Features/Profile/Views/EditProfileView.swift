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
                        }
                    }) {
                        Text("Save")
                            .bold()
                            .disabled(viewModel.isLoading) // or some other condition
                    }
                }
                .padding()
                .background(Material.ultraThin)
                .compositingGroup()

                Spacer()
            }

            // ImagePicker 弹窗
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
                    .presentationDetents([.large])
                    .edgesIgnoringSafeArea(.all)
                    .onDisappear {
                        guard let image = selectedImage else { return }

                        // 将选中的 UIImage 转成 jpegData
                        guard let data = image.jpegData(compressionQuality: 0.8) else { return }

                        switch imagePickerType {
                        case .profile:
                            // 上传头像
                            Task {
                                await viewModel.uploadAvatar(imageData: data)
                            }
                            profileImage = image // 更新界面预览

                        case .banner:
                            // 上传 banner
                            Task {
                                await viewModel.uploadBanner(imageData: data)
                            }
                            bannerImage = image // 更新界面预览
                        }

                        selectedImage = nil
                    }
            }
        }
        // 当上传或更新完成后，自动关闭
        .onReceive(viewModel.$shouldRefreshImage) { _ in
            // 如果需要在图片上传完立即退出，可在这里进行 dismiss
//            mode.dismss()
        }
        // 如果希望等待一切保存都完成再退出，可另加逻辑
        .onReceive(viewModel.$user) { updatedUser in
            // 可选：若 updatedUser != nil，说明资料更新完毕
//            updatedUser != nil
        }
        .onAppear {
            // 可选：清除缓存或其他逻辑
            KingfisherManager.shared.cache.clearCache()
        }
    }
}
