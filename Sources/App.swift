@_exported import Inject
import SwiftUI

@main
struct DemoApp: App {
    @StateObject private var injectionManager = InjectionManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AuthViewModel.shared)
                .injectableView()
//          EditProfileView()
//            .injectableView()
        }
    }
  
  
}



struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        if viewModel.isAuthenticated {
          if viewModel.user != nil {
                MainView()
                    .injectableView()
            }
        } else {
            WelcomeView()
                .injectableView()
        }
    }
}




#Preview {
    ContentView()
}

// 创建一个环境对象来管理注入状态
final class InjectionManager: ObservableObject {
    @ObserveInjection var inject
    static let shared = InjectionManager()
}



// 简化的视图修饰符
extension View {
    func injectableView() -> some View {
        modifier(InjectableViewModifier())
    }
}

struct InjectableViewModifier: ViewModifier {
    @StateObject private var manager = InjectionManager.shared

    func body(content: Content) -> some View {
        content.enableInjection()
    }
}

