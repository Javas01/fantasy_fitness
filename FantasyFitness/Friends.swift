//
//  Friends.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/17/25.
//

import SwiftUI

struct FriendsView: View {
    let activities: [FriendActivity] = friendFeed
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(activities) { activity in
                    FriendActivityRow(activity: activity)
                }
                
                Spacer(minLength: 40)
            }
            .padding()
        }
    }
}

var friendFeed: [FriendActivity] = [
    FriendActivity(name: "Jay", avatarName: "avatar_0_0", action: "ran a mile", timestamp: "2025"),
    FriendActivity(name: "Bob", avatarName: "avatar_0_2", action: "completed the Shape Up challenge", timestamp: "2025"),
    FriendActivity(name: "Jay", avatarName: "avatar_0_0", action: "ran a mile", timestamp: "2025"),
    FriendActivity(name: "Bob", avatarName: "avatar_0_2", action: "completed the Shape Up challenge", timestamp: "2025"),
    FriendActivity(name: "Jay", avatarName: "avatar_0_0", action: "ran a mile", timestamp: "2025"),
    FriendActivity(name: "Bob", avatarName: "avatar_0_2", action: "completed the Shape Up challenge", timestamp: "2025"),
    FriendActivity(name: "Jay", avatarName: "avatar_0_0", action: "ran a mile", timestamp: "2025"),
    FriendActivity(name: "Bob", avatarName: "avatar_0_2", action: "completed the Shape Up challenge", timestamp: "2025")
]

#Preview {
    FriendsView()
}
