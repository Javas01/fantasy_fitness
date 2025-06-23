//
//  FriendActivityRow.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/18/25.
//
import SwiftUI

struct FriendActivityRow: View {
    let activity: FriendActivity
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(activity.avatarName)
                .resizable()
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(activity.name) \(activity.action)")
                    .font(.subheadline)
                Text(activity.timestamp)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(10)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
