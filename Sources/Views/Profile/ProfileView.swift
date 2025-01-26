import SwiftUI

struct ProfileView: View {
    @ObserveInjection var inject
    
    var body: some View {
        VStack {
            Text("Profile")
        }
        .enableInjection()
    }
}

#Preview {
    ProfileView()
}
