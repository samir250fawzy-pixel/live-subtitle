import Foundation

/// تخزين مشترك بين الـ Broadcast Extension والتطبيق الرئيسي عن طريق App Group.
/// الـ Extension بيكتب النص المستخرَج من الشاشة، والتطبيق الرئيسي بيقراه.
enum SharedTextStore {
    private static let defaults = UserDefaults(suiteName: AppGroup.identifier)
    private static let latestSourceTextKey = "latestSourceText"
    private static let latestTimestampKey = "latestTimestamp"

    static func writeSourceText(_ text: String) {
        defaults?.set(text, forKey: latestSourceTextKey)
        defaults?.set(Date().timeIntervalSince1970, forKey: latestTimestampKey)
    }

    static func readSourceText() -> String? {
        defaults?.string(forKey: latestSourceTextKey)
    }
}
