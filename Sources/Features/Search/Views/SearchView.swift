//import Kingfisher
//import SwiftUI
//
//struct SearchView: View {
//    @EnvironmentObject private var authViewModel: AuthViewModel
//    @ObservedObject var viewModel = SearchViewModel()
//    @ObserveInjection var inject
//    
//    // 从 TopBar 传入的搜索状态
//    @Binding var searchText: String
//    @Binding var isEditing: Bool
//    
//    var users: [User] {
//        return searchText.isEmpty ? viewModel.users : viewModel.filteredUsers(searchText)
//    }
//
//    var body: some View {
//        ScrollView {
//            VStack {
//                LazyVStack {
//                    ForEach(users) { user in
//                        NavigationLink(destination: ProfileView(userId: user.id)) {
//                            SearchUserCell(user: user)
//                                .padding(.leading)
//                        }
//                    }
//                }
//                .transition(
//                    .asymmetric(
//                        insertion: .move(edge: .trailing).combined(with: .opacity),
//                        removal: .move(edge: .leading).combined(with: .opacity)
//                    )
//                )
//            }
//            .animation(
//                .spring(
//                    response: 0.4,
//                    dampingFraction: 0.7,
//                    blendDuration: 0.2
//                ),
//                value: isEditing
//            )
//        }
//        .enableInjection()
//    }
//}
