import Foundation
import Translation

/// بيستخدم Apple Translation framework (iOS 17.4+) — on-device، مجاني، وبدون إنترنت
/// بعد أول مرة تنزيل حزمة اللغة.
@MainActor
final class TranslationManager: ObservableObject {
    @Published var originalText: String = ""
    @Published var translatedText: String = ""

    private var session: TranslationSession?

    func attachSession(_ session: TranslationSession) {
        self.session = session
    }

    func translate(_ text: String) async {
        guard let session else { return }
        originalText = text
        do {
            let response = try await session.translate(text)
            translatedText = response.targetText
        } catch {
            print("Translation error: \(error)")
        }
    }
}
