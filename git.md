--- a/Sources/Features/Search/ViewModels/SearchViewModel.swift
+++ b/Sources/Features/Search/ViewModels/SearchViewModel.swift
@@ -1,37 +1,38 @@
 import SwiftUI
 
 class SearchViewModel: ObservableObject {
     @Published var users = [User]()
     
     init() {
+        // 初始化时启动加载任务
+        Task {
+            await fetchUsers()
+        }
     }
     
+    /// 使用 async/await 从后端加载所有用户数据
+    func fetchUsers() async {
+        guard let url = URL(string: "http://localhost:3000/users") else { return }
+        do {
+            let (data, _) = try await URLSession.shared.data(from: url)
+            let decoder = JSONDecoder()
+            decoder.keyDecodingStrategy = .convertFromSnakeCase
+            let fetchedUsers = try decoder.decode([User].self, from: data)
+            // 更新 UI 必须在主线程上
+            await MainActor.run {
+                self.users = fetchedUsers
+            }
+        } catch {
+            print("Failed to fetch users: \(error)")
+        }
     }
     
+    /// 根据搜索关键字过滤用户（姓名或用户名包含关键字）
     func filteredUsers(_ query: String) -> [User] {
         let lowercasedQuery = query.lowercased()
+        return users.filter { user in
+            user.name.lowercased().contains(lowercasedQuery) ||
+            user.username.lowercased().contains(lowercasedQuery)
+        }
     }
+}
\ No newline at end of file
--- a/git.md
+++ b/git.md
@@ -1,999 +0,0 @@
\ No newline at end of file