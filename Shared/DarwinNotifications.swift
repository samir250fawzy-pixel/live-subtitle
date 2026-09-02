import Foundation

/// App Group بيخزن البيانات بس، مش بيبعت إشعار لحظي.
/// Darwin Notifications هي الطريقة اللي بيها الـ Extension "يصحّي" التطبيق الرئيسي
/// فور ما نص جديد يتكتب.
enum DarwinNotification {
    static let newTextAvailable = "com.yourcompany.livesubtitletranslator.newText"

    static func post(_ name: String) {
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(name as CFString),
            nil, nil, true
        )
    }
}

/// Wrapper بيحافظ على الـ observer حي طول ما الكلاس ده موجود في الذاكرة.
/// امسك reference له في مكان بيعيش طول عمر الشاشة (مثلاً ObservableObject).
final class DarwinObserver {
    private let name: String
    private let callback: () -> Void

    init(name: String, callback: @escaping () -> Void) {
        self.name = name
        self.callback = callback
        let observer = Unmanaged.passUnretained(self).toOpaque()
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            observer,
            { _, observer, _, _, _ in
                guard let observer else { return }
                let mySelf = Unmanaged<DarwinObserver>.fromOpaque(observer).takeUnretainedValue()
                mySelf.callback()
            },
            name as CFString,
            nil,
            .deliverImmediately
        )
    }

    deinit {
        CFNotificationCenterRemoveObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            Unmanaged.passUnretained(self).toOpaque(),
            CFNotificationName(name as CFString),
            nil
        )
    }
}
