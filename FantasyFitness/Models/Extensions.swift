//
//  Extensions.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/26/25.
//

import SwiftUI

extension Date {
    static let shortTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMM d, h:mm a")
        return formatter
    }()
    
    var formattedDate: String {
        return Date.shortDateFormatter.string(from: self)
    }
    var formattedTime: String {
        return Date.shortTimeFormatter.string(from: self)
    }
}

struct AppBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 215/255, green: 236/255, blue: 250/255),
                    Color(red: 190/255, green: 224/255, blue: 245/255)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            content
        }
    }
}

extension View {
    func appBackground() -> some View {
        self.modifier(AppBackgroundModifier())
    }
}
