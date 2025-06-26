//
//  PlayerRowView.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/26/25.
//


import SwiftUI
import PostgREST
import Supabase
import WidgetKit

struct PlayerRowView: View {
    let player: ChallengeParticipantJoinUsers
    let alignLeft: Bool
        
    var body: some View {
        if(alignLeft) {
            Image(player.users.avatarName)
                .resizable()
                .frame(width: 40, height: 40)
        }
        if !alignLeft {
            Text("\(player.score, specifier: "%.1f")")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.orange)
            Spacer()
        }
        VStack(alignment: alignLeft ? .leading : .trailing, spacing: 4) {
            Text(player.name)
                .fontWeight(.semibold)
            Text(playerDisplayInfo)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 80, alignment: alignLeft ? .leading : .trailing)
        if alignLeft {
            Spacer()
            Text("\(player.score, specifier: "%.1f")")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.orange)
        }
        if(!alignLeft) {
            Image(player.users.avatarName)
                .resizable()
                .frame(width: 40, height: 40)
        }
    }
    
    var playerDisplayInfo: String {
        "Athlete"
    }
}