//
//  FFScoreProgressView.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/24/25.
//


import SwiftUI
import HealthKitUI
import PostgREST

struct FFScoreProgressView: View {
    let ffScore: Double
    @State private var animatedScore: Double = 0.0
    @State private var animatedProgress: CGFloat = 0.0
    
    private func animateScore() {
        animatedScore = 0.0
        animatedProgress = 0.0
        
        Timer.scheduledTimer(withTimeInterval: 0.075, repeats: true) { timer in
            if animatedScore < ffScore {
                animatedScore += max(1, ffScore / 60)
            } else {
                animatedScore = ffScore
                timer.invalidate()
            }
            
            animatedProgress = CGFloat(animatedScore) / CGFloat(nextFF(currentScore: ffScore))
        }
    }
    
    var body: some View {
        let nextLevel = nextFF(currentScore: ffScore)
        
        VStack {
            ProgressView(value: animatedProgress)
                .tint(.orange)
                .shadow(color: .orange, radius: 4)
                .frame(height: 10)
            
            Text("\(String(format: "%.1f", animatedScore)) / \(nextLevel) FF Level")
                .font(.footnote)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity)
        }
        .onAppear {
            animateScore()
        }
        .onChange(of: ffScore) {
            animateScore()
        }
    }
}

func nextFF(currentScore: Double) -> Int {
    switch currentScore {
        case 0..<50:
            return 50
        case 50..<150:
            return 150
        case 150..<300:
            return 300
        case 300..<500:
            return 500
        case 500..<750:
            return 750
        case 750..<1000:
            return 1000
        case 1000..<1400:
            return 1400
        case 1400..<1800:
            return 1800
        case 1800..<2300:
            return 2300
        case 2300..<3000:
            return 3000
        case 3000..<4000:
            return 4000
        case 4000..<5000:
            return 5000
        case 5000..<6000:
            return 6000
        case 6000..<7000:
            return 7000
        case 7000..<8000:
            return 8000
        case 8000..<9000:
            return 9000
        case 9000..<10000:
            return 10000
        default:
            return 10000 // Maxed out
    }
}
func ffTitle(for score: Double) -> String {
    switch score {
        case 0..<50: return "Couch Potato"
        case 50..<150: return "Remote Warrior"
        case 150..<300: return "Slow Jogger"
        case 300..<500: return "Gym Dabbler"
        case 500..<750: return "Step Counter"
        case 750..<1000: return "Fitness Fan"
        case 1000..<1400: return "Park Powerwalker"
        case 1400..<1800: return "Spin Class Survivor"
        case 1800..<2300: return "Yoga Yoda"
        case 2300..<3000: return "Marathon Maybe"
        case 3000..<4000: return "Beast Mode Lite"
        case 4000..<5000: return "Cardio Commander"
        case 5000..<6000: return "Lift Lord"
        case 6000..<7000: return "Treadmill Titan"
        case 7000..<8000: return "Crossfit Cultist"
        case 8000..<9000: return "Sweat Machine"
        case 9000..<10000: return "Olympic Hopeful"
        default: return "Fantasy Fitness Legend 💪"
    }
}
