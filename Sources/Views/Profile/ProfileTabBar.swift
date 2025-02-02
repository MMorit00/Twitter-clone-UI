// import SwiftUI

// struct ProfileTabBar: View {
//     @Binding var currentTab: String
//     @Namespace var animation

//     let tabs = ["Tweets", "Replies", "Likes", "Media"]

//     var body: some View {
//         VStack(spacing: 0) {
//             ScrollView(.horizontal, showsIndicators: false) {
//                 HStack(spacing: 30) {
//                     ForEach(tabs, id: \.self) { tab in
//                         TabButton(title: tab,
//                                   currentTab: $currentTab,
//                                   namespace: animation)
//                             .id(tab)
//                     }
//                 }
//                 .padding(.horizontal)
//             }
//             Divider()
//         }
//     }
// }
