import SwiftUI

struct HomeView: View {
    @ObserveInjection var inject
    @State private var selectedTab = 0
    @State private var showCreateTweetView = false 
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                FeedView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .tag(0)

                SearchView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                    .tag(1)

                NotificationsView()
                    .tabItem {
                        Image(systemName: "bell")
                        Text("Notifications")
                    }
                    .tag(2)

                MessagesView()
                    .tabItem {
                        Image(systemName: "envelope")
                        Text("Messages")
                    }
                    .tag(3)
            }
            .sheet(isPresented: $showCreateTweetView) {
                CreateTweetView()
            }
            .accentColor(Color("BG"))

            // 添加浮动发推按钮
            Button(action: {
                showCreateTweetView = true 
            }) {
                Image(systemName: "plus")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color("BG"))
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding()
            .padding(.bottom, 60) // 调整按钮位置，避免与 TabBar 重叠
        }
       
        .enableInjection()
    }
}

