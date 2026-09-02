import ActivityKit
import Foundation

/// بيدير Live Activity واحدة (النص المترجم الظاهر في Dynamic Island / شاشة القفل).
@MainActor
final class LiveActivityController: ObservableObject {
    private var activity: Activity<SubtitleActivityAttributes>?

    func start() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities غير مفعّلة من إعدادات النظام.")
            return
        }
        let attributes = SubtitleActivityAttributes(startedAt: Date())
        let initialState = SubtitleActivityAttributes.ContentState(translatedText: "", originalText: "")
        do {
            activity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil)
            )
        } catch {
            print("فشل بدء Live Activity: \(error)")
        }
    }

    func update(original: String, translated: String) {
        guard let activity else {
            start()
            return
        }
        let newState = SubtitleActivityAttributes.ContentState(translatedText: translated, originalText: original)
        Task {
            await activity.update(.init(state: newState, staleDate: nil))
        }
    }

    func end() {
        Task {
            await activity?.end(nil, dismissalPolicy: .immediate)
            activity = nil
        }
    }
}
