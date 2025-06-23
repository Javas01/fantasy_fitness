//
//  FantasyFitnessWidget.swift
//  FantasyFitnessWidget
//
//  Created by Jawwaad Sabree on 6/17/25.
//

import WidgetKit
import SwiftUI

struct FFEntry: TimelineEntry {
    let date: Date
    let level: String
    let currentScore: Int
    let nextLevelScore: Int
}

struct FFProvider: TimelineProvider {
    func placeholder(in context: Context) -> FFEntry {
        FFEntry(date: Date(), level: "Weekend Warrior", currentScore: 420, nextLevelScore: 500)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (FFEntry) -> ()) {
        let entry = FFEntry(date: Date(), level: "Weekend Warrior", currentScore: 420, nextLevelScore: 500)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<FFEntry>) -> ()) {
        // Normally fetch from shared storage or network
        let entry = FFEntry(date: Date(), level: "Weekend Warrior", currentScore: 420, nextLevelScore: 500)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct FantasyFitnessWidgetEntryView : View {
    var entry: FFProvider.Entry
    
    var body: some View {
        VStack(alignment: .center) {
            Image("avatar_0_0")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
            Text("🏆 \(entry.level)")
                .font(.headline)
            
            ProgressView(value: Double(entry.currentScore), total: Double(entry.nextLevelScore))
                .progressViewStyle(LinearProgressViewStyle())
                .padding(.vertical, 4)
            
            Text("\(entry.currentScore)/\(entry.nextLevelScore) FF")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .containerBackground(for: .widget) {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 215/255, green: 236/255, blue: 250/255),
                    Color(red: 190/255, green: 224/255, blue: 245/255)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

struct FantasyFitnessWidget: Widget {
    let kind: String = "FantasyFitnessWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FFProvider()) { entry in
            FantasyFitnessWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("FantasyFitness Score")
        .description("Track your FF level right from your home screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemLarge) {
    FantasyFitnessWidget()
} timeline: {
    FFEntry(date: Date(), level: "Weekend Warrior", currentScore: 420, nextLevelScore: 500)
}
