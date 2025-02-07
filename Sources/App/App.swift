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


   @StateObject private var authState: AuthState = {
        guard let authService: AuthServiceProtocol = DIContainer.defaultContainer().resolve(.authService) else {
            fatalError("Failed to resolve AuthService")
        }
        return AuthState(authService: authService)
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.diContainer, container)
                .environmentObject(authState)
        }
    }
}
