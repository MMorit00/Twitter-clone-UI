//import SwiftUI
//
//struct SettingsView: View {
//    @Environment(\.dismiss) private var dismiss
//    @EnvironmentObject private var authViewModel: AuthViewModel
//    
//    var body: some View {
//        NavigationView {
//            List {
//                Section {
//                    Button(action: {
//                        authViewModel.signOut()
//                        dismiss()
//                    }) {
//                        Text("Log Out")
//                            .foregroundColor(.red)
//                    }
//                }
//            }
//            .navigationTitle("Settings and Privacy")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                }
//            }
//        }
//    }
//}
