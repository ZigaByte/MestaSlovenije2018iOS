//
//  GameScene.swift
//  Mesta Slovenije 2018
//
//  Created by Klemen Podpadec on 03/03/2018.
//
//

import SpriteKit
import GameplayKit

class MainMenu: SKScene {
    
    // This method is called when the scene gets put into the view
    override func didMove(to view: SKView) {
        print("started scene")
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        // Detect button presses
        let node = self.nodes(at: pos)
        for n in node{
            if n.name != nil {
                let name:String = n.name! as String
                
                switch name {
                case "PlayButton":
                    print("Let's play!")
                    
                    if let scene = SKScene(fileNamed: "Gameplay") {
                        // Set the scale mode to scale to fit the window
                        scene.scaleMode = .aspectFit
                        
                        // Present the scene
                        self.view!.presentScene(scene)
                    }
                    
                case "Instructions":
                    print("Let's Instructions!")
                    if let scene = SKScene(fileNamed: "Tutorial") {
                        // Set the scale mode to scale to fit the window
                        scene.scaleMode = .aspectFit
                        
                        // Present the scene
                        self.view!.presentScene(scene)
                    }
                case "Leaderboard":
                    print("Let's Leaderboard!")
                case "About":
                    print("Let's About!")
                default:
                    break;
                }
            }
        }
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
