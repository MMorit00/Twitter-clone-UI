import SwiftUI

enum ImageUploader {
    // 上传图片的静态方法
    static func uploadImage(
        paramName: String,
        fileName: String,
        image: UIImage,
        urlPath: String,
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        // 1. 构建完整URL
        guard let url = URL(string: "http://localhost:3000\(urlPath)") else { return }

        // 2. 生成boundary
        let boundary = UUID().uuidString

        // 3. 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // 4. 设置请求头
        guard let token = UserDefaults.standard.string(forKey: "jwt") else { return }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // 5. 构建multipart表单数据
        var data = Data()
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        data.append(image.jpegData(compressionQuality: 0.5)!)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        // 6. 创建上传任务
        let task = URLSession.shared.uploadTask(with: request, from: data) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else { return }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    completion(.success(json))
                }
            } catch {
                completion(.failure(error))
            }
        }

        // 7. 开始上传
        task.resume()
    }
}
