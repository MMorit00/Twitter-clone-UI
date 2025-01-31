import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    // 改为可选类型
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var mode

    // 创建UIImagePickerController
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    // 更新控制器(本例中不需要实现)
    func updateUIViewController(_: UIImagePickerController, context _: Context) {}

    // 创建协调器
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // 协调器类处理图片选择回调
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        // 处理图片选择完成的回调
        func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                // 直接赋值可选类型
                parent.image = image
            }

            // 关闭图片选择器
            parent.mode.wrappedValue.dismiss()
        }
    }
}
