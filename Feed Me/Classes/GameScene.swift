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
    private static var backgroundMusicPlayer: AVAudioPlayer!
    private var sliceSoundAction: SKAction!
    private var splashSoundAction: SKAction!
    private var nomNomSoundAction: SKAction!
    private var levelOver = false
    private var vineCut = false
    
    override func didMove(to view: SKView) {
        setUpPhysics()
        setUpScenery()
        setUpPrize()
        setUpVines()
        setUpCrocodile()
        setUpAudio()
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
        prize = SKSpriteNode(imageNamed: ImageName.Prize)
        prize.position = CGPoint(x: size.width * 0.5, y: size.height * 0.7)
        prize.zPosition = Layer.Prize
        prize.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: ImageName.PrizeMask), size: prize.size)
        prize.physicsBody?.categoryBitMask = PhysicsCategory.Prize
        prize.physicsBody?.collisionBitMask = 0
        prize.physicsBody?.density = 0.5
        prize.physicsBody?.isDynamic = true
        
        addChild(prize)
    }
    
    //MARK: - Vine methods
    
    fileprivate func setUpVines() {
        // 1 load vine data
        let dataFile = Bundle.main.path(forResource: GameConfiguration.VineDataFile, ofType: nil)
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
        if levelOver {
            return
        }
        if prize.position.y <= 0 {
            run(splashSoundAction)
            levelOver = true
            switchToNewGameWithTransition(SKTransition.fade(withDuration: 1.0))
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if levelOver {
            return
        }
        if (contact.bodyA.node == crocodile && contact.bodyB.node == prize)
            || (contact.bodyA.node == prize && contact.bodyB.node == crocodile) {
            
            // shrink the pineapple away
            let shrink = SKAction.scale(to: 0, duration: 0.08)
            let removeNode = SKAction.removeFromParent()
            let sequence = SKAction.sequence([shrink, removeNode])
            prize.run(sequence)
            runNomNomAnimationWithDelay(0.15)
            run(nomNomSoundAction)
            // transition to next level
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
        
        sliceSoundAction = SKAction.playSoundFileNamed(SoundFile.Slice, waitForCompletion: false)
        splashSoundAction = SKAction.playSoundFileNamed(SoundFile.Splash, waitForCompletion: false)
        nomNomSoundAction = SKAction.playSoundFileNamed(SoundFile.NomNom, waitForCompletion: false)
    }
}
