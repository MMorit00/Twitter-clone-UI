import SwiftUI

class CreateTweetViewModel: ObservableObject {
    // 发送推文方法,添加image参数
    func uploadPost(text: String, image: UIImage? = nil) {
        // 获取当前用户信息
        guard let user = AuthViewModel.shared.user else {
            return
        }

        // 设置服务器域名
        RequestServices.requestDomain = "http://localhost:3000"

        // 调用网络请求服务发送推文
        RequestServices.postTweet(
            text: text,
            user: user.name,
            username: user.username,
            userId: user.id
        ) { result in
            // 在主线程处理结果
            DispatchQueue.main.async {
                switch result {
                case let .success(response):
                    // 发送成功,打印响应
                    print("Tweet posted successfully: \(String(describing: response))")

                    // 如果有图片需要上传
                    if let image = image,
                       let responseData = response,
                       let id = responseData["_id"] as? String
                    {
                        // 上传图片
                        self.uploadTweetImage(image: image, tweetId: id)
                    }

                case let .failure(error):
                    // 发送失败,打印错误
                    print("Failed to post tweet: \(error.localizedDescription)")
                }
            }
        }
    }

    // 上传推文图片的方法
    private func uploadTweetImage(image: UIImage, tweetId: String) {
        ImageUploader.uploadImage(
            paramName: "image",
            fileName: "tweet.png",
            image: image,
            urlPath: "/tweets/\(tweetId)/image"
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(response):
                    print("Image uploaded successfully: \(response)")
                case let .failure(error):
                    print("Failed to upload image: \(error)")
                }
            }
        }
    }
}
