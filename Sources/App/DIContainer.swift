import Foundation
import SwiftUI

final class DIContainer {
    private var dependencies: [String: Any] = [:]
    
    // MARK: - Registration
    
    func register<T>(_ dependency: T, for key: String) {
        dependencies[key] = dependency
    }
    
    func register<T>(_ dependency: T, type: ServiceType) {
        register(dependency, for: type.rawValue)
    }
    
    // MARK: - Resolution
    
    func resolve<T>(_ key: String) -> T? {
        return dependencies[key] as? T
    }
    
    func resolve<T>(_ type: ServiceType) -> T? {
        return resolve(type.rawValue)
    }
    
    // MARK: - Lifecycle
    
    func reset() {
        dependencies.removeAll()
    }
    
    // MARK: - Service Types
    
    enum ServiceType: String {
        case apiClient
        case authService
        case tweetService
        case profileService
        case notificationService
        case imageUploadService
    }
    
    // MARK: - Convenience Methods
    
    static func defaultContainer() -> DIContainer {
        let container = DIContainer()
        
        // 配置基础服务
        let apiClient = APIClient(baseURL: APIConfig.baseURL)
        container.register(apiClient, type: .apiClient)
        
        // 配置 AuthService
        let authService = AuthService1(apiClient: apiClient)
        container.register(authService, type: .authService)
        
        // 配置 TweetService
        let tweetService = TweetService(apiClient: apiClient)
        container.register(tweetService, type: .tweetService)
        
        // 配置 ProfileService
        let profileService = ProfileService(apiClient: apiClient)
        container.register(profileService, type: .profileService)
        
        // 配置 NotificationService
        let notificationService = NotificationService(apiClient: apiClient)
        container.register(notificationService, type: .notificationService)
        
        return container
    }
}

// MARK: - Environment Integration

private struct DIContainerKey: EnvironmentKey {
    static let defaultValue = DIContainer.defaultContainer()
}

extension EnvironmentValues {
    var diContainer: DIContainer {
        get { self[DIContainerKey.self] }
        set { self[DIContainerKey.self] = newValue }
    }
}
