import SwiftUI
import Translation

struct ContentView: View {
    @StateObject private var translationManager = TranslationManager()
    @StateObject private var liveActivityController = LiveActivityController()
    @StateObject private var observerHolder = ObserverHolder()
    @State private var configuration: TranslationSession.Configuration?

    var body: some View {
        VStack(spacing: 24) {
            Text("مترجم الشاشة اللحظي")
                .font(.title2)
                .bold()

            Text("اضغط الزرار وابدأ البث (Broadcast) عشان يبدأ يقرا ويترجم أي نص إنجليزي ظاهر على الشاشة.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            BroadcastPickerView()
                .frame(width: 60, height: 60)

            Divider()

            VStack(alignment: .trailing, spacing: 8) {
                Text("النص الأصلي:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(translationManager.originalText)
                    .font(.footnote)

                Text("الترجمة:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(translationManager.translatedText)
                    .font(.title3)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding()
        }
        .padding()
        .translationTask(configuration) { session in
            translationManager.attachSession(session)
        }
        .onAppear {
            configuration = TranslationSession.Configuration(
                source: nil, // كشف تلقائي للغة المصدر
                target: Locale.Language(identifier: "ar")
            )
            liveActivityController.start()
            observerHolder.startObserving(
                translationManager: translationManager,
                liveActivityController: liveActivityController
            )
        }
        .onDisappear {
            liveActivityController.end()
        }
    }
}

/// كلاس بسيط بيحافظ على الـ DarwinObserver حي طول ما الشاشة ظاهرة.
@MainActor
final class ObserverHolder: ObservableObject {
    private var observer: DarwinObserver?

    func startObserving(translationManager: TranslationManager, liveActivityController: LiveActivityController) {
        observer = DarwinObserver(name: DarwinNotification.newTextAvailable) {
            Task { @MainActor in
                guard let text = SharedTextStore.readSourceText() else { return }
                await translationManager.translate(text)
                liveActivityController.update(
                    original: translationManager.originalText,
                    translated: translationManager.translatedText
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
