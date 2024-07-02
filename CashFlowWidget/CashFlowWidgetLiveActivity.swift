//
//  CashFlowWidgetLiveActivity.swift
//  CashFlowWidget
//
//  Created by Voltline on 2024/7/2.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct CashFlowWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct CashFlowWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CashFlowWidgetAttributes.self) { context in
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

extension CashFlowWidgetAttributes {
    fileprivate static var preview: CashFlowWidgetAttributes {
        CashFlowWidgetAttributes(name: "World")
    }
}

extension CashFlowWidgetAttributes.ContentState {
    fileprivate static var smiley: CashFlowWidgetAttributes.ContentState {
        CashFlowWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: CashFlowWidgetAttributes.ContentState {
         CashFlowWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: CashFlowWidgetAttributes.preview) {
   CashFlowWidgetLiveActivity()
} contentStates: {
    CashFlowWidgetAttributes.ContentState.smiley
    CashFlowWidgetAttributes.ContentState.starEyes
}
