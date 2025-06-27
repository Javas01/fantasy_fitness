//
//  PlayerLevel.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/26/25.
//


import SwiftUI

struct PlayerLevel: View {
    @EnvironmentObject var appUser: AppUser
    
    var body: some View {
        HStack {
            VStack(alignment: .leading){
                HStack(alignment: .center) {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(.orange)
                        .frame(width: 30, alignment: .leading)
                    Text("99")
                }
                .padding(10.0)
                HStack {
                    Image(systemName: "lungs.fill")
                        .foregroundColor(.orange)
                        .frame(width: 30, alignment: .leading)
                    Text("99")
                }
                .padding(10.0)
                HStack {
                    Image(systemName: "figure.walk.circle.fill")
                        .foregroundColor(.orange)
                        .frame(width: 30, alignment: .leading)
                    Text("99")
                }
                .padding(10.0)
            }
            .frame(width: 100)
            Spacer()
            VStack(spacing: 12) {
                Image(appUser.avatarName)
                    .resizable()
                    .frame(width: 100, height: 100)
                
                Text(appUser.user.name)
                    .font(.title2.bold())
     
                Text(ffTitle(for: appUser.user.ffScore))
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                
            }
            Spacer()
            VStack(alignment: .leading){
                HStack {
                    Text("99")
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundColor(.orange)
                        .frame(width: 30, alignment: .trailing)
                }
                .padding(10.0)
                HStack {
                    Text("99")
                    Image(systemName: "scope")
                        .foregroundColor(.orange)
                        .frame(width: 30, alignment: .trailing)
                }
                .padding(10.0)
                HStack {
                    Text("99")
                    Image(systemName: "bed.double.fill")
                        .foregroundColor(.orange)
                        .frame(width: 30, alignment: .trailing)
                }
                .padding(10.0)
            }
            .frame(width: 100)
        }
    }
}

struct PlayerLevelView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper {
            ProfileView()
        }
    }
}
