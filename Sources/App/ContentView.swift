import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authState: AuthState
    
    var body: some View {
        Group {
            if authState.isAuthenticated {
                MainView()
            } else {
                WelcomeView()
            }
        }
    }
}
