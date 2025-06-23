//
//  SpriteScene.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/18/25.
//

import SpriteKit
import SwiftUI

class KnightScene: SKScene {
    override func didMove(to view: SKView) {
        let texture = SKTexture(imageNamed: "sprites") // full sprite sheet
        
        let frameWidth: CGFloat = 100   // adjust based on your sprite sheet
        let frameHeight: CGFloat = 150
        let yOffset: CGFloat = 0    // start at top row
        
        var frames: [SKTexture] = []
        
        for i in 0..<5 {  // if you want 6 frames
            let rect = CGRect(x: CGFloat(i) * frameWidth / texture.size().width,
                              y: yOffset,
                              width: frameWidth / texture.size().width,
                              height: frameHeight / texture.size().height)
            frames.append(SKTexture(rect: rect, in: texture))
        }
        
        let sprite = SKSpriteNode(texture: frames.first)
        sprite.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(sprite)
        
        let animation = SKAction.repeatForever(
            SKAction.animate(with: frames, timePerFrame: 0.15)
        )
        sprite.run(animation)
    }
}

struct KnightSpriteView: UIViewRepresentable {
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        let scene = KnightScene(size: CGSize(width: 250, height: 250))
        scene.scaleMode = .aspectFit
        view.presentScene(scene)
        return view
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {}
}

#Preview {
    KnightSpriteView()
}
