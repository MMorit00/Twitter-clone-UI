
// import SwiftUI

// struct TabButton: View {
//     let title: String
//     @Binding var currentTab: String
//     let namespace: Namespace.ID
    
//     var body: some View {
//         Button {
//             withAnimation(.spring()) {
//                 currentTab = title
//             }
//         } label: {
//             VStack {
//                 Text(title)
//                     .fontWeight(currentTab == title ? .semibold : .regular)
//                     .foregroundColor(currentTab == title ? .primary : .gray)
                
//                 if currentTab == title {
//                     Rectangle()
//                         .fill(Color.blue)
//                         .frame(height: 3)
//                         .matchedGeometryEffect(id: "TAB", in: namespace)
//                 } else {
//                     Rectangle()
//                         .fill(Color.clear)
//                         .frame(height: 3)
//                 }
//             }
//         }
//     }
// }

