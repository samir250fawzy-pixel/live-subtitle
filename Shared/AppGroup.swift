import Foundation

/// غيّر المعرّف ده ليطابق الـ App Group اللي هتعمله في Xcode
/// (Signing & Capabilities > App Groups) على التطبيق الرئيسي وعلى الـ Broadcast Extension.
enum AppGroup {
    static let identifier = "group.com.yourcompany.livesubtitletranslator"
}
