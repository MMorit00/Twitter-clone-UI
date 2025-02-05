import SwiftUI
import UIKit 


struct MultilineTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 18)
        textView.backgroundColor = .clear
        textView.delegate = context.coordinator
        textView.text = placeholder
        textView.textColor = .gray
        return textView
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: MultilineTextField

        init(_ parent: MultilineTextField) {
            self.parent = parent
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == .gray {
                textView.text = ""
                textView.textColor = .black
            }
            
            parent.text = textView.text

        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text

        }

        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = .gray
            }
        }
    }


    func updateUIView(_ uiView: UITextView, context _: Context) {
       
    }

}
