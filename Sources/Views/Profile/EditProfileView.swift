import Kingfisher
import SwiftUI

struct EditProfileView: View {
    @Environment(\.presentationMode) var mode
    @ObserveInjection var inject
    @EnvironmentObject private var authViewModel: AuthViewModel

    // 移除 user binding
    // @Binding var user: User
    @StateObject private var viewModel: EditProfileViewModel

    // 用户输入的状态变量
    @State private var name: String = ""
    @State private var location: String = ""
    @State private var bio: String = ""
    @State private var website: String = ""

    // 图片相关状态
    @State private var profileImage: UIImage?
    @State private var bannerImage: UIImage?

    // 添加图片选择相关状态
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var imagePickerType: ImagePickerType = .profile

    // 定义图片选择类型
    enum ImagePickerType {
        case banner
        case profile
    }

    // 修改初始化方法
    init() {
        // 使用AuthViewModel.shared.user初始化
        let user = AuthViewModel.shared.user!
        _viewModel = StateObject(wrappedValue: EditProfileViewModel(user: user))
        // 初始化各个字段
        _name = State(initialValue: user.name)
        _location = State(initialValue: user.location ?? "")
        _bio = State(initialValue: user.bio ?? "")
        _website = State(initialValue: user.website ?? "")
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

            // 独立覆盖的导航栏
            VStack {
                HStack {
                    Button("Cancel") {
                        mode.wrappedValue.dismiss()
                    }
                    Spacer()
                    Button(action: {
                        viewModel.save(
                            name: name,
                            bio: bio,
                            website: website,
                            location: location
                        )
                    }) {
                        Text("Save")
                            .bold()
                            .disabled(viewModel.isSaving)
                    }
                }
                .padding()
                .background(Material.ultraThin)
                .compositingGroup()
                // .shadow(radius: 2)

                Spacer()
            }

            // ImagePicker 保持原样
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
                    .presentationDetents([.large])
                    .edgesIgnoringSafeArea(.all)
                    .onDisappear {
                        guard let image = selectedImage else { return }

                        switch imagePickerType {
                        case .profile:
                            viewModel.profileImage = image // 更新 ViewModel
                            profileImage = image // 更新 View 状态
                        case .banner:
                            viewModel.bannerImage = image // 更新 ViewModel
                            bannerImage = image // 更新 View 状态
                        }

                        // 清除选中的图片
                        selectedImage = nil
                    }
            }
        }
        .onAppear {
            // 清除 Kingfisher 缓存
            KingfisherManager.shared.cache.clearCache()
        }
        .onReceive(viewModel.$uploadComplete) { complete in
            if complete {
           
                // 确保在主线程中关闭视图
                DispatchQueue.main.async {
                    mode.wrappedValue.dismiss()
                }
            }
        }

        .enableInjection()
    }
}
