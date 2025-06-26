//
//  NewActivitySheet.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/24/25.
//

import SwiftUI

struct NewActivitySheet: View {
    @EnvironmentObject var healthManager: HealthManager
    
    var body: some View {
        if (healthManager.recentSamples.isEmpty) {
            Text("No New Activity, Put your phone down")
                .font(.headline)
                .padding()
        } else {
            Text("New Activity:")
                .font(.headline)
                .padding()

        }
    }
}
