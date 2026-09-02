import SwiftUI
import ReplayKit

/// زرار النظام الرسمي لبدء/إيقاف الـ Broadcast. لازم تحط فيه Bundle ID
/// بتاع الـ Broadcast Extension نفسه (مش بتاع التطبيق الرئيسي).
struct BroadcastPickerView: UIViewRepresentable {
    func makeUIView(context: Context) -> RPSystemBroadcastPickerView {
        let picker = RPSystemBroadcastPickerView()
        // غيّر ده ليطابق الـ Bundle Identifier الفعلي بتاع الـ BroadcastExtension target في Xcode.
        picker.preferredExtension = "com.yourcompany.LiveSubtitleTranslator.BroadcastExtension"
        picker.showsMicrophoneButton = false
        return picker
    }

    func updateUIView(_ uiView: RPSystemBroadcastPickerView, context: Context) {}
}
