import Foundation

final class DIContainer {
    private var dependencies: [String: Any] = [:]
    
    // 注册依赖
    func register<T>(_ dependency: T, for key: String) {
        dependencies[key] = dependency
    }
    
    // 解析依赖
    func resolve<T>(_ key: String) -> T? {
        return dependencies[key] as? T
    }
    
    // 清理所有依赖
    func reset() {
        dependencies.removeAll()
    }
}

// 服务类型定义
extension DIContainer {
    enum ServiceType: String {
        case apiClient
        case authService
        case tweetService
        case profileService
        case notificationService
    }
}

// 便捷方法
extension DIContainer {
    func register<T>(_ dependency: T, type: ServiceType) {
        register(dependency, for: type.rawValue)
    }
    
    func resolve<T>(_ type: ServiceType) -> T? {
        resolve(type.rawValue)
    }
}