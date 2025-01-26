import SwiftUI

struct NotificationsView: View {
    @ObserveInjection var inject
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(0 ..< 9) { _ in
                        NotificationCell()
                        
                    }
                }
            }
        }
        .enableInjection()
    }
}

#Preview {
    NotificationsView()
} 