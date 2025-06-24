//
//  EmptyPlayerRowView.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/24/25.
//


import SwiftUI
import PostgREST
import Supabase

struct EmptyPlayerRowView: View {
    let alignLeft: Bool
    
    var body: some View {
        if alignLeft {
            Image(systemName: "person.crop.circle.badge.plus")
                .resizable()
                .frame(width: 40, height: 40)
        }
        
        VStack(alignment: alignLeft ? .leading : .trailing, spacing: 4) {
            Text("Tap to Invite")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("Open Slot")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 80, alignment: alignLeft ? .leading : .trailing)
        
        if !alignLeft {
            Image(systemName: "person.crop.circle.badge.plus")
                .resizable()
                .frame(width: 40, height: 40)
        }
    }
}