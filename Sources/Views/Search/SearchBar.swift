import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @Binding var isEditing: Bool
    @ObserveInjection var inject

    var body: some View {
        ZStack {
            if isEditing {
                HStack {
                    // 搜索框
                    TextField("", text: $text)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        .overlay(
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.black)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 10)
                            }
                        )
                        .onTapGesture {
                            isEditing = true
                        }

                    // 取消按钮
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isEditing = false
                            text = ""
                            UIApplication.shared.endEditing()
                        }
                    }) {
                        Text("Cancel")
                            .foregroundColor(.black)
                    }
                }
                .transition(.opacity)
            } else {
                HStack {
                    TextField("", text: $text)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        .overlay(
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.black)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                    .padding(.leading, 10)
                            }
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isEditing = true
                            }
                        }
                }
                .transition(.opacity)
            }
        }
        .enableInjection()
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
