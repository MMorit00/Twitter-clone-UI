import SwiftUI

struct SearchView: View {
    @State var searchText = ""
    @State var isEditing = false
    @ObserveInjection var inject
    var body: some View {
        VStack {
            HStack {
                if !isEditing {
                    Circle()
                        .fill(.gray)
                        .frame(width: 35, height: 35)
                }
                SearchBar(text: $searchText, isEditing: $isEditing)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)

                if !isEditing {
                    Image(systemName: "gear")
                        .foregroundColor(.gray)
                        .font(.system(size: 24))
                }
            }
            .padding(.horizontal, isEditing ? 0 : 12)

            // 内容区域
            if !isEditing {
                // 趋势话题列表
                List {
                    ForEach(0 ..< 9) { _ in
                        SearchCell()
                    }
                }
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    )
                )
            } else {
                // 用户搜索结果列表
                ScrollView {
                    LazyVStack {
                        ForEach(0 ..< 9) { _ in
                            SearchUserCell()
                        }
                    }
                }
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    )
                )
            }
        }
        // 将动画移到这里，包装整个 VStack
        .animation(
            .spring(
                response: 0.4,
                dampingFraction: 0.7,
                blendDuration: 0.2
            ),
            value: isEditing
        )
        .enableInjection()
    }
}
