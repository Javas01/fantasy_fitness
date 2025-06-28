//
//  GuidedTooltip.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/27/25.
//

import SwiftUI

struct GuidedTooltipAnchor<ID: Hashable>: ViewModifier {
    let id: ID
    let currentStep: ID?
    let text: String
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(
                                key: TooltipAnchorPreferenceKey.self,
                                value: [TooltipAnchor(id: AnyHashable(id), frame: proxy.frame(in: .global))]
                            )
                    }
                )
        }
        .overlayPreferenceValue(TooltipAnchorPreferenceKey.self) { anchors in
            if currentStep == id,
               let anchor = anchors.first(where: { $0.id == AnyHashable(id) }) {
                Tooltip(text: text)
                    .position(
                        x: anchor.frame.midX,
                        y: anchor.frame.minY - 40
                    )
                    .transition(.opacity.combined(with: .scale))
                    .onAppear {
                        print("💡 anchors count: \(anchors.count)")
                        anchors.forEach { print("➡️ \($0.id) at \($0.frame)") }
                    }
            }
        }
        .onAppear {
            print("🧭 currentStep: \(String(describing: currentStep)), this ID: \(id)")
        }
    }
}

extension View {
    func guidedTooltip<ID: Hashable>(id: ID, currentStep: ID?, text: String) -> some View {
        self.modifier(GuidedTooltipAnchor(id: id, currentStep: currentStep, text: text))
    }
}

struct TooltipAnchor: Equatable {
    let id: AnyHashable
    let frame: CGRect
}

struct TooltipAnchorPreferenceKey: PreferenceKey {
    static var defaultValue: [TooltipAnchor] = []
    
    static func reduce(value: inout [TooltipAnchor], nextValue: () -> [TooltipAnchor]) {
        value.append(contentsOf: nextValue())
    }
}

struct Tooltip: View {
    let text: String
    @State private var appear = false
    
    var body: some View {
        VStack(spacing: 4) {
            Text(text)
                .font(.headline)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                        .shadow(radius: 5)
                        .blur(radius: 0.1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.orange.opacity(0.6), lineWidth: 1)
                )
            
            Image(systemName: "arrowtriangle.down.fill")
                .foregroundStyle(Color.white)
                .frame(width: 16, height: 10)
                .shadow(radius: 2)
        }
    }
}
