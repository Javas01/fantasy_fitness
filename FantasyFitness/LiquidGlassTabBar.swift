//
//  LiquidGlassTabBar.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/26/25.
//


import SwiftUI
import PostgREST

struct LiquidGlassTabBar: View {
    @Binding var selectedTab: MainAppView.Tab
    @Binding var showCreateSheet: Bool

    var body: some View {
        HStack(spacing: 30) {
            tabButton(icon: "house.fill", tab: .home)
            tabButton(icon: "figure.run", tab: .challenges)
            createButton() // Custom FAB
            tabButton(icon: "trophy.fill", tab: .activity)
            tabButton(icon: "person.crop.circle", tab: .profile)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
        .padding(.bottom, 0)
    }
    
    func tabButton(icon: String, tab: MainAppView.Tab, isCenter: Bool = false) -> some View {
        Button(action: {
            withAnimation(.spring()) {
                selectedTab = tab
            }
        }) {
            Image(systemName: icon)
                .font(.system(size: isCenter ? 32 : 22))
                .foregroundColor(selectedTab == tab ? .orange : .gray)
                .frame(maxWidth: .infinity)
        }
    }
    
    func createButton() -> some View {
        Button(action: {
            withAnimation(.spring()) {
                showCreateSheet = true
            }
        }) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 38))
                .foregroundColor(.orange)
                .frame(maxWidth: .infinity)
        }
    }
}