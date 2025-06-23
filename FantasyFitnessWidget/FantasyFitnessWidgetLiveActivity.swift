//
//  FantasyFitnessWidgetLiveActivity.swift
//  FantasyFitnessWidget
//
//  Created by Jawwaad Sabree on 6/17/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct FantasyFitnessWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var ffScore: Int
        var nextLevelScore: Int
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
    var avatarName: String
}

struct FantasyFitnessWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FantasyFitnessWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 215/255, green: 236/255, blue: 250/255),
                        Color(red: 190/255, green: 224/255, blue: 245/255)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                VStack(spacing: 8) {
                    Image(context.attributes.avatarName)
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 48, height: 48)
                    
                    Text("FantasyFitness Score")
                        .font(.caption)
                    
                    ProgressView(
                        value: Double(context.state.ffScore),
                        total: Double(context.state.nextLevelScore)
                    )
                    .tint(.orange)
                    .shadow(color: .orange, radius: 4)
                    .animation(.easeInOut(duration: 0.6), value: context.state.ffScore)
                }
                .padding()
            }

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
                    Text("Bottom \(context.state.ffScore)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.ffScore)")
            } minimal: {
                Text("T \(context.state.ffScore)")
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension FantasyFitnessWidgetAttributes {
    fileprivate static var preview: FantasyFitnessWidgetAttributes {
        FantasyFitnessWidgetAttributes(name: "World", avatarName: "avatar_0_0")
    }
}

extension FantasyFitnessWidgetAttributes.ContentState {
    fileprivate static var smiley: FantasyFitnessWidgetAttributes.ContentState {
        FantasyFitnessWidgetAttributes.ContentState(ffScore: 250, nextLevelScore: 500)
     }
     
     fileprivate static var starEyes: FantasyFitnessWidgetAttributes.ContentState {
         FantasyFitnessWidgetAttributes.ContentState(ffScore: 350, nextLevelScore: 500)
     }
}

#Preview("Notification", as: .content, using: FantasyFitnessWidgetAttributes.preview) {
   FantasyFitnessWidgetLiveActivity()
} contentStates: {
    FantasyFitnessWidgetAttributes.ContentState.smiley
    FantasyFitnessWidgetAttributes.ContentState.starEyes
}
