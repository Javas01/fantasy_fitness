//
//  DailyChallenge.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/18/25.
//

struct DailyChallenge {
    let title: String
    let progress: Double
    let goal: Double
    let rewardFF: Int
    var isCompleted: Bool {
        progress >= goal
    }
}
