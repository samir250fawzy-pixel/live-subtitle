import ActivityKit
import Foundation

/// لازم الملف ده يكون Target Membership فيه شامل: التطبيق الرئيسي + الـ Widget Extension
/// (اللي فيه الـ Live Activity)، عشان الاتنين يفهموا نفس الـ shape.
struct SubtitleActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var translatedText: String
        var originalText: String
    }

    var startedAt: Date
}
