// import Combine
// import Kingfisher
// import SwiftUI

// // 在 class EditProfileViewModel 之前添加 AuthenticationError 枚举
// enum AuthenticationError: Error {
//     case custom(String)
// }

// class EditProfileViewModel: ObservableObject {
//     @Published var user: User
//     @Published var isSaving = false
//     @Published var error: Error?
//     @Published var uploadComplete = false

//     // 图片相关状态
//     @Published var profileImage: UIImage?
//     @Published var bannerImage: UIImage?
//     @Published var isUploadingImage = false

//     private var cancellables = Set<AnyCancellable>()

//     init(user: User) {
//         self.user = user

//         // 可以选择是否也订阅 AuthViewModel 的变化
//         AuthViewModel.shared.$user
//             .compactMap { $0 }
//             .receive(on: DispatchQueue.main)
//             .sink { [weak self] updatedUser in
//                 self?.user = updatedUser
//             }
//             .store(in: &cancellables)
//     }

//     func save(name: String, bio: String, website: String, location: String) {
//         guard !name.isEmpty else { return }

//         isSaving = true
//         uploadComplete = false // 重置状态

//         Task {
//             do {
//                 // 1. 如果有新的头像图片，先上传头像
//                 if let newProfileImage = profileImage {
//                     try await uploadProfileImage(image: newProfileImage)
//                     // 清除特定URL的缓存
//                     if let avatarURL = URL(string: "http://localhost:3000/users/\(user.id)/avatar") {
//                         try? await KingfisherManager.shared.cache.removeImage(forKey: avatarURL.absoluteString)
//                     }
//                 }

//                 // 2. 如果有新的横幅图片，上传横幅
//                 if bannerImage != nil {
//                     // TODO: 添加上传横幅的方法
//                 }

//                 // 3. 上传用户文本数据
//                 let updatedUser = try await uploadUserData(
//                     name: name,
//                     bio: bio.isEmpty ? nil : bio,
//                     website: website.isEmpty ? nil : website,
//                     location: location.isEmpty ? nil : location
//                 )

//                 // 4. 如果有图片更新，清除缓存
//                 if profileImage != nil || bannerImage != nil {
//                     try? await KingfisherManager.shared.cache.clearCache()
//                 }

//                 // 5. 在主线程更新状态
//                 await MainActor.run {
//                     // 更新用户数据
//                     self.user = updatedUser
//                     AuthViewModel.shared.updateUser(updatedUser)

//                     // 清除已上传的图片状态
//                     self.profileImage = nil
//                     self.bannerImage = nil

//                     // 最后更新完成状态
//                     self.isSaving = false
//                     self.uploadComplete = true
//                 }
//             } catch {
//                 await MainActor.run {
//                     print("Error saving profile: \(error)")
//                     self.error = error
//                     self.isSaving = false
//                     self.uploadComplete = false
//                 }
//             }
//         }
//     }

//     // MARK: - 上传用户信息 （真正使用 async/await，而不是在里面套闭包）

//     func uploadUserData(
//         name: String?,
//         bio: String?,
//         website: String?,
//         location: String?
//     ) async throws -> User {
//         // 1. 获取 token
//         guard let token = UserDefaults.standard.string(forKey: "jwt") else {
//             throw AuthenticationError.custom("No token found")
//         }

//         // 2. 构建请求体 - 只包含非空值
//         var requestBody: [String: Any] = [:]
//         if let name = name { requestBody["name"] = name }
//         if let bio = bio { requestBody["bio"] = bio }
//         if let website = website { requestBody["website"] = website }
//         if let location = location { requestBody["location"] = location }

//         print("Uploading user data:", requestBody) // 添加日志

//         // 3. 构建 URL
//         let urlString = "http://localhost:3000/users/me"

//         // 4. 发送请求
//         return try await withCheckedThrowingContinuation { continuation in
//             AuthService.makePatchRequestWithAuth(
//                 urlString: urlString,
//                 requestBody: requestBody,
//                 token: token
//             ) { result in
//                 switch result {
//                 case let .success(data):
//                     do {
//                         print("Received response data:", String(data: data, encoding: .utf8) ?? "") // 添加日志
//                         let updatedUser = try JSONDecoder().decode(User.self, from: data)
//                         continuation.resume(returning: updatedUser)
//                     } catch {
//                         print("Failed to decode user data:", error) // 添加日志
//                         continuation.resume(throwing: error)
//                     }

//                 case let .failure(error):
//                     print("Network request failed:", error) // 添加日志
//                     continuation.resume(throwing: error)
//                 }
//             }
//         }
//     }

//     // MARK: - 上传头像 (也改成 async)

//     func uploadProfileImage(image: UIImage) async throws {
//         // 1. 定义 URL 路径
//         let urlPath = "/users/me/avatar"

//         // 2. 用 continuation 等到上传结束
//         try await withCheckedThrowingContinuation { continuation in
//             ImageUploader.uploadImage(
//                 paramName: "avatar",
//                 fileName: "profile_image.jpeg",
//                 image: image,
//                 urlPath: urlPath
//             ) { [weak self] result in
//                 guard let self = self else { return }

//                 switch result {
//                 case let .success(json):
//                     print("Profile image uploaded successfully: \(json)")
//                     // 清除 Kingfisher 缓存以更新 UI
//                     KingfisherManager.shared.cache.clearCache()
//                     // 不要在这里 toggle self.uploadComplete，因为还要等文本信息一起更新
//                     continuation.resume(returning: ())

//                 case let .failure(error):
//                     print("Failed to upload profile image: \(error)")
//                     DispatchQueue.main.async {
//                         self.error = error
//                     }
//                     continuation.resume(throwing: error)
//                 }
//             }
//         }
//     }
// }
