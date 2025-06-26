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
