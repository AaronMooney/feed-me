//
//  MenuScene.swift
//  Feed Me
//
//  Created by 20072163 on 16/11/2018.
//  Copyright © 2018 20072163. All rights reserved.
//

import SpriteKit

class MenuScene : SKScene {
    
    var playButton: SKSpriteNode!
    var multiCutButton: SKSpriteNode!
    var toggleAudioButton: SKSpriteNode!
    var toggleMultiCutValueLabel: SKLabelNode!
    var toggleAudioValueLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: ImageName.Background)
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = Layer.Background
        background.size = CGSize(width: size.width, height: size.height)
        addChild(background)
        
        let water = SKSpriteNode(imageNamed: ImageName.Water)
        water.anchorPoint = CGPoint(x: 0, y: 0)
        water.position = CGPoint(x: 0, y: 0)
        water.zPosition = Layer.Water
        water.size = CGSize(width: size.width, height: size.height * 0.2139)
        addChild(water)
        
        playButton = SKSpriteNode(imageNamed: ImageName.Button)
        playButton.anchorPoint = CGPoint(x: 0,y: 0)
        playButton.position = CGPoint(x: size.width/2 - 150, y: size.height/2)
        playButton.zPosition = Layer.Button
        playButton.size = CGSize(width: 300, height: 100)
        playButton.name = "play"
        addChild(playButton)
        
        let playLabel = SKLabelNode(fontNamed: "Chalkduster")
        playLabel.zPosition = 4
        playLabel.text = "Play"
        playLabel.position = CGPoint(x: playButton.position.x + 150,y: playButton.position.y + 50)
        addChild(playLabel)
        
        multiCutButton = SKSpriteNode(imageNamed: ImageName.Button)
        multiCutButton.anchorPoint = CGPoint(x: 0, y: 0)
        multiCutButton.position = CGPoint(x: size.width/2 - 250, y: size.height/2 - 150)
        multiCutButton.zPosition = Layer.Button
        multiCutButton.size = CGSize(width: 500, height: 100)
        multiCutButton.name = "multiCut"
        addChild(multiCutButton)
        
        let multiCutLabel = SKLabelNode(fontNamed: "Chalkduster")
        multiCutLabel.zPosition = 4
        multiCutLabel.text = "Toggle multicut: "
        multiCutLabel.position = CGPoint(x: multiCutButton.position.x + 250,y: multiCutButton.position.y + 50)
        addChild(multiCutLabel)
        
        toggleMultiCutValueLabel = SKLabelNode(fontNamed: "Chalkduster")
        toggleMultiCutValueLabel.zPosition = 5
        toggleMultiCutValueLabel.position = CGPoint(x: multiCutLabel.position.x + 180, y: multiCutLabel.position.y)
        addChild(toggleMultiCutValueLabel)
        
        toggleAudioButton = SKSpriteNode(imageNamed: ImageName.Button)
        toggleAudioButton.anchorPoint = CGPoint(x: 0, y: 0)
        toggleAudioButton.position = CGPoint(x: size.width/2 - 250, y: size.height/2 - 300)
        toggleAudioButton.zPosition = Layer.Button
        toggleAudioButton.size = CGSize(width: 500, height: 100)
        toggleAudioButton.name = "audio"
        addChild(toggleAudioButton)
        
        let toggleAudioLabel = SKLabelNode(fontNamed: "Chalkduster")
        toggleAudioLabel.zPosition = 4
        toggleAudioLabel.text = "Toggle audio: "
        toggleAudioLabel.position = CGPoint(x: toggleAudioButton.position.x + 250,y: toggleAudioButton.position.y + 50)
        addChild(toggleAudioLabel)
        
        toggleAudioValueLabel = SKLabelNode(fontNamed: "Chalkduster")
        toggleAudioValueLabel.zPosition = 5
        toggleAudioValueLabel.position = CGPoint(x: toggleAudioLabel.position.x + 180, y: toggleAudioLabel.position.y)
        addChild(toggleAudioValueLabel)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let objects = nodes(at: location)
            
            if objects.contains(playButton) {
                if let view = self.view {
                    // Load the SKScene from 'GameScene.sks'
                    if let scene = SKScene(fileNamed: "GameScene") {
                        // Set the scale mode to scale to fit the window
                        scene.scaleMode = .aspectFill
                        
                        // Present the scene
                        view.presentScene(scene)
                    }
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }
            
            if objects.contains(multiCutButton){
                GameConfiguration.CanCutMultipleVinesAtOnce = !GameConfiguration.CanCutMultipleVinesAtOnce
            }
            if objects.contains(toggleAudioButton){
                GameConfiguration.ToggleSound = !GameConfiguration.ToggleSound
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if (GameConfiguration.CanCutMultipleVinesAtOnce){
            toggleMultiCutValueLabel.text = "On"
        } else {
            toggleMultiCutValueLabel.text = "Off"
        }
        if (GameConfiguration.ToggleSound){
            toggleAudioValueLabel.text = "On"
        } else {
            toggleAudioValueLabel.text = "Off"
        }
    }
    
}
