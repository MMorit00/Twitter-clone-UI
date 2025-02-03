import SwiftUI

class NotificationsViewModel: ObservableObject {
    
    @Published var notifications = [Notification]()
    let user: User
    
    init(user: User) {
        self.user = user
        fetchNotifications()
    }

    func fetchNotifications() {
        let userId = self.user.id  // 获取当前用户的 ID
        
        // 修正 URL 拼接
        let urlString = "http://localhost:3000/notifications/\(userId)"
        print("Fetching notifications for user: \(urlString)")  // 打印 URL，调试用
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")  // URL 拼接错误时打印
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // 获取 token
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            print("No token found")  // 如果没有 token，提示用户
            return
        }
        
        // 设置请求头
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Error fetching notifications: \(error.localizedDescription)")  // 打印请求错误
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")  // 打印响应的 HTTP 状态码
            }
            
            guard let data = data else {
                print("No data received")  // 没有接收到数据
                return
            }
            
            // 打印原始响应数据
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw response: \(responseString)")
            }
            
            do {
                let notifications = try JSONDecoder().decode([Notification].self, from: data)
                DispatchQueue.main.async {
                    self?.notifications = notifications  // 更新通知列表
                    print("Successfully decoded \(notifications.count) notifications")  // 打印解析成功的通知数量
                }
            } catch {
                print("Error decoding notifications: \(error)")  // 解码失败时的错误
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Failed to decode response: \(responseString)")  // 打印无法解码的响应数据
                }
            }
        }
        
        task.resume()
    }
}
