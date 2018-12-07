//
//  GameScene.swift
//  Feed Me
//
//  Created by 20072163 on 09/11/2018.
//  Copyright © 2018 20072163. All rights reserved.
//

import SpriteKit
import AVFoundation


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var crocodile: SKSpriteNode!
    private var prize: SKSpriteNode!
    private var options: SKSpriteNode!
    private var optionsMenu: SKSpriteNode!
    private var hearts: [SKSpriteNode] = [SKSpriteNode]()
    private var heart1: SKSpriteNode!
    private var heart2: SKSpriteNode!
    private var heart3: SKSpriteNode!
    private var toggleMultiCutValueLabel: SKLabelNode!
    private var toggleAudioValueLabel: SKLabelNode!
    private var scoreLabel: SKLabelNode!
    private var levelLabel: SKLabelNode!
    private static var backgroundMusicPlayer: AVAudioPlayer!
    private var sliceSoundAction: SKAction!
    private var splashSoundAction: SKAction!
    private var nomNomSoundAction: SKAction!
    private var levelOver = false
    private var vineCut = false
    private var toggleOptions = false
    private var levelWon: Bool = false
    private var currentLevel = 0
    private var score = 0
    private var lives = 3
    
    override func didMove(to view: SKView) {
        setUpPhysics()
        setUpScenery()
        setUpPrize()
        setUpVines()
        setUpCrocodile()
        setUpAudio()
        setUpOptions()
        setUpHud()
    }
    
    //MARK: - Level setup
    
    fileprivate func setUpPhysics() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
        physicsWorld.speed = 1.0
    }
    fileprivate func setUpScenery() {
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
    }
    fileprivate func setUpPrize() {
        levelWon = false
        prize = SKSpriteNode(imageNamed: ImageName.Prize)
        prize.position = CGPoint(x: size.width * 0.5, y: size.height * 0.7)
        prize.zPosition = Layer.Prize
        prize.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: ImageName.Prize), size: prize.size)
        prize.physicsBody?.categoryBitMask = PhysicsCategory.Prize
        prize.physicsBody?.collisionBitMask = 0
        prize.physicsBody?.density = 0.5
        prize.physicsBody?.isDynamic = true
        
        addChild(prize)
    }
    
    fileprivate func setUpHud(){
        scoreLabel = SKLabelNode(fontNamed: "chalkduster")
        scoreLabel.zPosition = Layer.HUD
        scoreLabel.position = CGPoint(x: size.width / 2, y: 20)
        scoreLabel.text = "Score: \(score)"
        addChild(scoreLabel)
        
        levelLabel = SKLabelNode(fontNamed: "chalkduster")
        levelLabel.zPosition = Layer.HUD
        levelLabel.position = CGPoint(x: size.width / 2, y: size.height - 40)
        levelLabel.text = "Level: \(currentLevel + 1)"
        addChild(levelLabel)
        
        if currentLevel == 0 {
            heart1 = SKSpriteNode(imageNamed: ImageName.Heart)
            heart1.zPosition = Layer.HUD
            hearts.append(heart1)
        
            heart2 = SKSpriteNode(imageNamed: ImageName.Heart)
            heart2.zPosition = Layer.HUD
            hearts.append(heart2)
        
            heart3 = SKSpriteNode(imageNamed: ImageName.Heart)
            heart3.zPosition = Layer.HUD
            hearts.append(heart3)
        }
        
        var betweenDistance = CGFloat(50)
        for node in hearts{
            node.position = CGPoint(x: betweenDistance, y: size.height - 40)
            betweenDistance += CGFloat(50)
            addChild(node)
        }
    }
    
    //MARK: - Vine methods
    
    fileprivate func setUpVines() {
        // 1 load vine data
        let dataFile = Bundle.main.path(forResource: GameConfiguration.Levels[currentLevel], ofType: nil)
        let vines = NSArray(contentsOfFile: dataFile!) as! [NSDictionary]
        
        // 2 add vines
        for i in 0..<vines.count {
            // 3 create vine
            let vineData = vines[i]
            let length = Int(truncating: vineData["length"] as! NSNumber)
            let relAnchorPoint = CGPointFromString(vineData["relAnchorPoint"] as! String)
            let anchorPoint = CGPoint(x: relAnchorPoint.x * size.width,
                                      y: relAnchorPoint.y * size.height)
            let vine = VineNode(length: length, anchorPoint: anchorPoint, name: "\(i)")
            
            // 4 add to scene
            vine.addToScene(self)
            
            // 5 connect the other end of the vine to the prize
            vine.attachToPrize(prize)
        }
    }
    
    //MARK: - Croc methods
    
    fileprivate func setUpCrocodile() {
        crocodile = SKSpriteNode(imageNamed: ImageName.CrocMouthClosed)
        crocodile.position = CGPoint(x: size.width * 0.75, y: size.height * 0.312)
        if currentLevel == 1 { crocodile.position.y -= 80 }
        crocodile.zPosition = Layer.Crocodile
        crocodile.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: ImageName.CrocMask), size: crocodile.size)
        crocodile.physicsBody?.categoryBitMask = PhysicsCategory.Crocodile
        crocodile.physicsBody?.collisionBitMask = 0
        crocodile.physicsBody?.contactTestBitMask = PhysicsCategory.Prize
        crocodile.physicsBody?.isDynamic = false
        
        addChild(crocodile)
        animateCrocodile()
    }
    
    fileprivate func animateCrocodile() {
        let durationOpen = 2 + drand48()
        let open = SKAction.setTexture(SKTexture(imageNamed: ImageName.CrocMouthOpen))
        let waitOpen = SKAction.wait(forDuration: durationOpen)
        let durationClosed = 3 + (drand48() * 2)
        let close = SKAction.setTexture(SKTexture(imageNamed: ImageName.CrocMouthClosed))
        let waitClosed = SKAction.wait(forDuration: durationClosed)
        let sequence = SKAction.sequence([waitOpen,open,waitClosed,close])
        let loop = SKAction.repeatForever(sequence)
        crocodile.run(loop)
        
        if currentLevel == 1 {
            let moveLeft = SKAction.move(to: CGPoint(x: size.width * 0.1, y: crocodile.position.y), duration: 2)
            let moveRight = SKAction.move(to: CGPoint(x: size.width * 0.9, y: crocodile.position.y), duration: 2)
            let moveNode = SKNode()
            crocodile.addChild(moveNode)
            crocodile.run(SKAction.repeatForever(SKAction.sequence([moveLeft,moveRight])))
        }
    }
    
    fileprivate func runNomNomAnimationWithDelay(_ delay: TimeInterval) {
        crocodile.removeAllActions()
        
        let closeMouth = SKAction.setTexture(SKTexture(imageNamed: ImageName.CrocMouthClosed))
        let wait = SKAction.wait(forDuration: delay)
        let openMouth = SKAction.setTexture(SKTexture(imageNamed: ImageName.CrocMouthOpen))
        let sequence = SKAction.sequence([closeMouth, wait, openMouth, wait, closeMouth])
        
        crocodile.run(sequence)
    }
    
    //MARK: - Touch handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let objects = nodes(at: location)
            
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
            
            if objects.contains(toggleAudioValueLabel) {
                GameConfiguration.ToggleSound = !GameConfiguration.ToggleSound
            }
        }
        vineCut = false
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let startPoint = touch.location(in: self)
            let endPoint = touch.previousLocation(in: self)
            
            // check if vine cut
            scene?.physicsWorld.enumerateBodies(alongRayStart: startPoint, end: endPoint,
                                                using: { (body, point, normal, stop) in
                                                    self.checkIfVineCutWithBody(body)
            })
            
            // produce some nice particles
            //showMoveParticles(touchPosition: startPoint)
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { }
    fileprivate func showMoveParticles(touchPosition: CGPoint) { }
    
    //MARK: - Game logic
    
    override func update(_ currentTime: TimeInterval) {
        if GameConfiguration.ToggleSound {
            toggleAudioValueLabel.text = "On"
            GameScene.backgroundMusicPlayer.volume = 1
            sliceSoundAction = SKAction.playSoundFileNamed(SoundFile.Slice, waitForCompletion: false)
            splashSoundAction = SKAction.playSoundFileNamed(SoundFile.Splash, waitForCompletion: false)
            nomNomSoundAction = SKAction.playSoundFileNamed(SoundFile.NomNom, waitForCompletion: false)
        } else {
            toggleAudioValueLabel.text = "Off"
            GameScene.backgroundMusicPlayer.volume = 0
            nomNomSoundAction = SKAction.init()
            sliceSoundAction = SKAction.init()
            splashSoundAction = SKAction.init()
        }
        if (GameConfiguration.CanCutMultipleVinesAtOnce){
            toggleMultiCutValueLabel.text = "On"
        } else {
            toggleMultiCutValueLabel.text = "Off"
        }
        if levelOver {
            return
        }
        if prize.position.y <= 0 {
            run(splashSoundAction)
            if lives <= 1 {
                levelOver = true
                returnToMenu(SKTransition.doorway(withDuration: 1.0))
            } else {
                resetLevel()
            }
        }
    }
    
    func resetLevel(){
        lives -= 1
        hearts.removeLast().removeFromParent()
        setUpPrize()
        setUpVines()
    }
    
    func returnToMenu(_ transition: SKTransition){
        let delay = SKAction.wait(forDuration: 1)
        let sceneChange = SKAction.run({
            let scene = MenuScene(size: self.size)
            self.view?.presentScene(scene, transition: transition)
        })
        run(SKAction.sequence([delay, sceneChange]))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if levelOver {
            return
        }
        if (contact.bodyA.node == crocodile && contact.bodyB.node == prize)
            || (contact.bodyA.node == prize && contact.bodyB.node == crocodile) {
            
            score += 1
            
            // shrink the pineapple away
            let shrink = SKAction.scale(to: 0, duration: 0.08)
            let removeNode = SKAction.removeFromParent()
            let sequence = SKAction.sequence([shrink, removeNode])
            prize.run(sequence)
            runNomNomAnimationWithDelay(0.15)
            run(nomNomSoundAction)
            // transition to next level
            levelWon = true
            levelOver = true
            switchToNewGameWithTransition(SKTransition.doorway(withDuration: 1.0))
        }
    }
    
    fileprivate func checkIfVineCutWithBody(_ body: SKPhysicsBody) {
        if vineCut && !GameConfiguration.CanCutMultipleVinesAtOnce {
            return
        }
        
        let node = body.node!
        
        // if it has a name it must be a vine node
        if let name = node.name {
            // snip the vine
            node.removeFromParent()
            
            run(sliceSoundAction)
            
            // fade out all nodes matching name
            enumerateChildNodes(withName: name, using: { (node, stop) in
                let fadeAway = SKAction.fadeOut(withDuration: 0.25)
                let removeNode = SKAction.removeFromParent()
                let sequence = SKAction.sequence([fadeAway, removeNode])
                node.run(sequence)
                self.crocodile.removeAllActions()
                self.crocodile.texture = SKTexture(imageNamed: ImageName.CrocMouthOpen)
                self.animateCrocodile()
            })
            vineCut = true
        }
    }
    
    fileprivate func switchToNewGameWithTransition(_ transition: SKTransition) {
        let delay = SKAction.wait(forDuration: 1)
        let sceneChange = SKAction.run({
            let scene = GameScene(size: self.size)
            if self.levelWon {
                scene.currentLevel = (self.currentLevel + 1) % GameConfiguration.Levels.count
                scene.score = self.score
                scene.lives = self.lives
                scene.hearts = self.hearts
                for node in self.hearts { node.removeFromParent() }
            }
            self.view?.presentScene(scene, transition: transition)
        })
        
        run(SKAction.sequence([delay, sceneChange]))
    }
    
    //MARK: - Audio
    
    fileprivate func setUpAudio() {
        if GameScene.backgroundMusicPlayer == nil {
            let backgroundMusicURL = Bundle.main.url(forResource: SoundFile.BackgroundMusic, withExtension: nil)
            
            do {
                let theme = try AVAudioPlayer(contentsOf: backgroundMusicURL!)
                GameScene.backgroundMusicPlayer = theme
                
            } catch {
                // couldn't load file :[
            }
            
            GameScene.backgroundMusicPlayer.numberOfLoops = -1
        }
        if !GameScene.backgroundMusicPlayer.isPlaying {
            GameScene.backgroundMusicPlayer.play()
        }
    }
    
    //MARK: - Options
    
    fileprivate func setUpOptions() {
        options = SKSpriteNode(imageNamed: ImageName.Options)
        options.zPosition = 4
        options.position = CGPoint(x: size.width - 100,y: size.height - 100)
        options.size = CGSize(width: 100, height: 100)
        addChild(options)
        optionsConfig()
    }
    
    func optionsConfig(){
        //TODO toggle sound
        
        optionsMenu = SKSpriteNode(imageNamed: ImageName.Button)
        optionsMenu.zPosition = 5
        optionsMenu.anchorPoint = CGPoint(x: 0, y: 0)
        optionsMenu.position = CGPoint(x: 100, y: 800)
        optionsMenu.size = CGSize (width: 550, height: 300)
        
        let toggleMultiCutLabel = SKLabelNode(fontNamed: "Chalkduster")
        toggleMultiCutLabel.zPosition = 5
        toggleMultiCutLabel.position = CGPoint(x: optionsMenu.position.x + 125, y: optionsMenu.position.y - 600)
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
        
        let toggleAudioLabel = SKLabelNode(fontNamed: "Chalkduster")
        toggleAudioLabel.zPosition = 5
        toggleAudioLabel.position = CGPoint(x: optionsMenu.position.x + 125, y: optionsMenu.position.y - 700)
        toggleAudioLabel.text = "Toggle Audio: "
        optionsMenu.addChild(toggleAudioLabel)
        
        toggleAudioValueLabel = SKLabelNode(fontNamed: "Chalkduster")
        toggleAudioValueLabel.zPosition = 5
        toggleAudioValueLabel.position = CGPoint(x: toggleAudioLabel.position.x + 225, y: toggleAudioLabel.position.y)
        optionsMenu.addChild(toggleAudioValueLabel)
        
        if GameConfiguration.ToggleSound {
            toggleAudioValueLabel.text = "On"
        } else {
            toggleAudioValueLabel.text = "Off"
        }
    }
}
