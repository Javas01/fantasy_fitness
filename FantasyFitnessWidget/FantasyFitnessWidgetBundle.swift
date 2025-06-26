//
//  FantasyFitnessWidgetBundle.swift
//  FantasyFitnessWidget
//
//  Created by Jawwaad Sabree on 6/17/25.
//

import WidgetKit
import SwiftUI

@main
struct FantasyFitnessWidgetBundle: WidgetBundle {
    var body: some Widget {
        ChallengeProgressWidget()
        PlayerLevelWidget()
//        FantasyFitnessWidgetLiveActivity() TODO: build live activity
    }
}
