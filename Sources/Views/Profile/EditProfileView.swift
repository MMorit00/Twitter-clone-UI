import SwiftUI 

struct EditProfileView: View {
    @Environment(\.presentationMode) var mode

    // 用户输入的状态变量
    @State private var name: String = ""
    @State private var location: String = ""
    @State private var bio: String = ""
    @State private var website: String = ""

    // 图片相关状态
    @State private var profileImage: UIImage?
    @State private var bannerImage: UIImage?

    var body: some View {
        VStack {
            // 顶部导航区域
            HStack {
                Button(action: { mode.wrappedValue.dismiss() }) {
                    Text("Cancel")
                }

                Spacer()

                Button(action: {}) {
                    Text("Save")
                        .bold()
                }
            }
            .padding()

            // 图片区域
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

                    // 头像区域
                    HStack {
                        if let profileImage = profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 75, height: 75)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color(.systemGray6))
                                .frame(width: 75, height: 75)
                        }
                        Spacer()
                    }
                    .padding(.top, -25)
                    .padding(.bottom, -10)
                }
            }

            // 输入字段区域
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

            Spacer()
        }
    }
}
