import ActivityKit
import WidgetKit
import SwiftUI

struct SubtitleLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SubtitleActivityAttributes.self) { context in
            // شكل الـ Live Activity على شاشة القفل / Banner
            VStack(alignment: .trailing, spacing: 4) {
                Text(context.state.translatedText.isEmpty ? "بانتظار ترجمة..." : context.state.translatedText)
                    .font(.headline)
                    .multilineTextAlignment(.trailing)
            }
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.translatedText)
                        .font(.body)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(3)
                }
            } compactLeading: {
                Image(systemName: "text.bubble.fill")
            } compactTrailing: {
                Text(context.state.translatedText.prefix(6))
                    .font(.caption2)
            } minimal: {
                Image(systemName: "text.bubble.fill")
            }
        }
    }
}
