import Kingfisher
import SwiftUI

// 添加 AuthenticationError 定义
enum AuthenticationError: Error {
    case custom(String)
}

class EditProfileViewModel: ObservableObject {
    // 使用 @Published 标记需要观察的属性
    @Published var user: User
    @Published var isSaving = false
    @Published var error: Error?
    @Published var uploadComplete = false // 添加完成标记

    // 添加图片相关状态
    @Published var profileImage: UIImage?
    @Published var bannerImage: UIImage?
    @Published var isUploadingImage = false

    init(user: User) {
        self.user = user
    }

    func save(name: String, bio: String, website: String, location: String) {
        guard !name.isEmpty else { return }

        isSaving = true

        Task {
            do {
                // 1. 如果有新的头像图片，先上传头像
                if let newProfileImage = profileImage {
                    uploadProfileImage(text: "profile", image: newProfileImage)
                }

                // 2. 上传用户数据
                try await uploadUserData(
                    name: name,
                    bio: bio.isEmpty ? nil : bio,
                    website: website.isEmpty ? nil : website,
                    location: location.isEmpty ? nil : location
                )

                // 3. 完成保存
                DispatchQueue.main.async {
                    self.isSaving = false
                }

            } catch {
                DispatchQueue.main.async {
                    self.error = error
                    self.isSaving = false
                }
            }
        }
    }

    func uploadUserData(name: String?, bio: String?, website: String?, location: String?) async throws {
        // 1. 获取 token
        guard let token = UserDefaults.standard.string(forKey: "jsonwebtoken") else {
            throw AuthenticationError.custom("No token found")
        }

        // 2. 构建请求体 - 过滤掉空值
        var requestBody: [String: Any] = [:]
        if let name = name { requestBody["name"] = name }
        if let bio = bio { requestBody["bio"] = bio }
        if let website = website { requestBody["website"] = website }
        if let location = location { requestBody["location"] = location }

        // 3. 构建 URL
        let urlString = "http://localhost:3000/users/me"

        // 4. 发起请求
        AuthService.makePatchRequestWithAuth(
            urlString: urlString,
            requestBody: requestBody,
            token: token
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(data):
                do {
                    // 解码响应数据
                    let updatedUser = try JSONDecoder().decode(User.self, from: data)

                    // 在主线程更新 UI
                    DispatchQueue.main.async {
                        self.user = updatedUser
                        self.uploadComplete.toggle()
                    }
                } catch {
                    // 处理解码错误
                    print("Error decoding response: \(error)")
                }

            case let .failure(error):
                // 处理网络错误
                print("Error uploading user data: \(error)")
            }
        }
    }

    // 添加上传头像方法
    func uploadProfileImage(text _: String, image: UIImage?) {
        // 1. 检查图片是否存在
        guard let image = image else { return }

        // 2. 定义 URL 路径
        let urlPath = "/users/me/avatar"

        // 3. 使用 ImageUploader 上传图片
        ImageUploader.uploadImage(
            paramName: "avatar",
            fileName: "profile_image.jpeg",
            image: image,
            urlPath: urlPath
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(json):
                print("Profile image uploaded successfully: \(json)")

                // 清除 Kingfisher 缓存以更新 UI
                KingfisherManager.shared.cache.clearCache()

                // 触发 UI 更新
                DispatchQueue.main.async {
                    self.uploadComplete.toggle()
                }

            case let .failure(error):
                print("Failed to upload profile image: \(error)")
                DispatchQueue.main.async {
                    self.error = error
                }
            }
        }
    }
}
