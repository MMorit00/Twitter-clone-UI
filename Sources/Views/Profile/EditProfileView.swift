import Kingfisher
import SwiftUI

struct EditProfileView: View {
    @Environment(\.presentationMode) var mode
    @ObserveInjection var inject

    // 绑定用户数据
    @Binding var user: User

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

    // 添加初始化方法
    init(user: Binding<User>) {
        _user = user

        // 初始化各个字段
        _name = State(initialValue: user.wrappedValue.name)
        _location = State(initialValue: user.wrappedValue.location ?? "")
        _bio = State(initialValue: user.wrappedValue.bio ?? "")
        _website = State(initialValue: user.wrappedValue.website ?? "")
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
                    Button("Save") {
                        // 保存逻辑
                        mode.wrappedValue.dismiss()
                    }
                    .bold()
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
                            profileImage = image
                        case .banner:
                            bannerImage = image
                        }
                    }
            }
        }
        .onAppear {
            // 清除 Kingfisher 缓存
            KingfisherManager.shared.cache.clearCache()
        }
        .enableInjection()
    }
}
