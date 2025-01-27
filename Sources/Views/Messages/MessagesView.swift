import SwiftUI

struct MessagesView: View {
    @ObserveInjection var inject
    var body: some View {
        VStack {
            ScrollView {
                ForEach(0..<10) { _ in
                    MessageCell()
                }
            }
        }
        .enableInjection()
    }
}

#Preview {
    MessagesView()
}
