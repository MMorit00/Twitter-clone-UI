

 import SwiftUI
 @_exported import Inject
 @main
 struct DemoApp: App {
   @StateObject private var injectionManager = InjectionManager.shared
     var body: some Scene {
         WindowGroup {
        //   MainView()
        //      .injectableView()
//            
        //   CreateTweetView()
        //   .injectableView()
            // FeedView()
            // .injectableView()
         ProfileView()
            .injectableView()
         }

     }
 }





struct ContentView: View {
    var body: some View {
        Text("awd1aw44aaawdawdwdadwddwd53aaaa")
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
        self.modifier(InjectableViewModifier())
    }
}

struct InjectableViewModifier: ViewModifier {
    @StateObject private var manager = InjectionManager.shared
    
    func body(content: Content) -> some View {
        content.enableInjection()
    }
}
