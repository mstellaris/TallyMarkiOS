//
//  TallyLiveActivityLiveActivity.swift
//  TallyLiveActivity
//
//  Created by Miltos on 3/5/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TallyLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct TallyLiveActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TallyLiveActivityAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension TallyLiveActivityAttributes {
    fileprivate static var preview: TallyLiveActivityAttributes {
        TallyLiveActivityAttributes(name: "World")
    }
}

extension TallyLiveActivityAttributes.ContentState {
    fileprivate static var smiley: TallyLiveActivityAttributes.ContentState {
        TallyLiveActivityAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: TallyLiveActivityAttributes.ContentState {
         TallyLiveActivityAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: TallyLiveActivityAttributes.preview) {
   TallyLiveActivityLiveActivity()
} contentStates: {
    TallyLiveActivityAttributes.ContentState.smiley
    TallyLiveActivityAttributes.ContentState.starEyes
}
