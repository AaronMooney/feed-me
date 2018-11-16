//
//  MenuScene.swift
//  Feed Me
//
//  Created by 20072163 on 16/11/2018.
//  Copyright © 2018 20072163. All rights reserved.
//

import SpriteKit

class MenuScene : SKScene {
    
    var options: SKSpriteNode!
    var button: SKSpriteNode!
    var optionsMenu: SKSpriteNode!
    
    var toggleOptions = false
    var toggleMultiCutValueLabel: SKLabelNode!
    
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
        
        button = SKSpriteNode(imageNamed: ImageName.Button)
        button.anchorPoint = CGPoint(x: 0,y: 0)
        button.position = CGPoint(x: size.width/2 - 150, y: size.height/2)
        button.zPosition = Layer.Button
        button.size = CGSize(width: 300, height: 100)
        button.name = "play"
        addChild(button)
        
        let playLabel = SKLabelNode(fontNamed: "Chalkduster")
        playLabel.zPosition = 4
        playLabel.text = "Play"
        playLabel.position = CGPoint(x: button.position.x + 150,y: button.position.y + 50)
        addChild(playLabel)
        
        options = SKSpriteNode(imageNamed: ImageName.Options)
        options.zPosition = 4
        options.position = CGPoint(x: size.width - 100,y: size.height - 100)
        options.size = CGSize(width: 100, height: 100)
        addChild(options)
        setUpOptions()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let objects = nodes(at: location)
            
            if objects.contains(button) {
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
            
            if objects.contains(options){
                toggleOptions = !toggleOptions
                if (toggleOptions){
                    addChild(optionsMenu)
                } else {
                    optionsMenu.removeFromParent()
                }
            }
            
            if objects.contains(toggleMultiCutValueLabel) {
                GameConfiguration.CanCutMultipleVinesAtOnce = !GameConfiguration.CanCutMultipleVinesAtOnce
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if (GameConfiguration.CanCutMultipleVinesAtOnce){
            toggleMultiCutValueLabel.text = "On"
        } else {
            toggleMultiCutValueLabel.text = "Off"
        }
    }
    
    func setUpOptions(){
        //TODO toggle sound
        
        optionsMenu = SKSpriteNode(imageNamed: ImageName.Button)
        optionsMenu.zPosition = 5
        optionsMenu.anchorPoint = CGPoint(x: 0, y: 0)
        optionsMenu.position = CGPoint(x: 100, y: 500)
        optionsMenu.size = CGSize (width: 550, height: 500)
        
        let toggleMultiCutLabel = SKLabelNode(fontNamed: "Chalkduster")
        toggleMultiCutLabel.zPosition = 5
        toggleMultiCutLabel.position = CGPoint(x: optionsMenu.position.x + 125, y: optionsMenu.position.y - 100)
        toggleMultiCutLabel.text = "Cut multiple vines?"
        optionsMenu.addChild(toggleMultiCutLabel)
        
        toggleMultiCutValueLabel = SKLabelNode(fontNamed: "Chalkduster")
        toggleMultiCutValueLabel.zPosition = 5
        toggleMultiCutValueLabel.position = CGPoint(x: toggleMultiCutLabel.position.x + 225, y: toggleMultiCutLabel.position.y)
        
        if (GameConfiguration.CanCutMultipleVinesAtOnce){
            toggleMultiCutValueLabel.text = "On"
        } else {
            toggleMultiCutValueLabel.text = "Off"
        }
        
        optionsMenu.addChild(toggleMultiCutValueLabel)
    }
}
