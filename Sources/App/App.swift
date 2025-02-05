//
//  App.swift
//  CloneTwitter
//
//  Created by 潘令川 on 2025/2/5.
//

import Foundation
@_exported import Inject
import SwiftUI

@main
struct TwitterCloneApp: App {
    // 创建容器
    @StateObject private var authViewModel = AuthViewModel.shared
    let container: DIContainer = {
        let container = DIContainer.defaultContainer()
        
        #if DEBUG
        // 打印调试信息
        if let client: APIClientProtocol = container.resolve(.apiClient) {
            print("成功注册 APIClient")
        } else {
            print("APIClient 注册失败")
        }
        #endif
        
        return container
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.diContainer, container)
                .environmentObject(authViewModel)
        }
    }
}