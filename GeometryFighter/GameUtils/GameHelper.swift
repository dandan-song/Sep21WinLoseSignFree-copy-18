/*
 * Copyright (c) 2013-2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import SceneKit
import SpriteKit


public enum GameStateType {
    case Playing
    case TapToPlay
    case GameOver
    case Paused
}

class GameHelper {
    
    var score:Int
    var currentT:Int
    var highScore:Int
    
    var lives:Int
    var level:Int
    var totalScore:Int
    var state = GameStateType.TapToPlay
    
    
    var hudNode:SCNNode!
    var labelNode:SKLabelNode!
    
    var gameCenterNode:SCNNode!
    var labelNode2:SKLabelNode!
    
    var AdsFreeNode:SCNNode!
    
    
    static let sharedInstance = GameHelper()
    
    var sounds:[String:SCNAudioSource] = [:]
    
    private init() {
        level = 0
        score = 0
        highScore = 0
        currentT = 0
        lives = 3
        totalScore = 0
        
        let defaults = NSUserDefaults.standardUserDefaults()
        totalScore = defaults.integerForKey("totalScore")
        highScore = defaults.integerForKey("highScore")
        level = defaults.integerForKey("level")
        print("highScore, level", highScore, level)
        
        initHUD()
        initGameCenter()
        initAdsFree()
    }
    func  getHighScore() -> Int {
        return highScore;
    }
    func saveState() {
        //level = 0
        totalScore = totalScore + score
        print("totalScore:", totalScore)
        highScore = max(currentT, highScore)
        let defaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setInteger(highScore, forKey: "highScore")
        defaults.setInteger(level, forKey: "level")
        defaults.setInteger(totalScore, forKey: "totalScore")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func getScoreString(length:Int) -> String {
        return String(format: "%0\(length)d", score)
    }
    
    func initHUD() {
        
        let skScene = SKScene(size: CGSize(width: 500, height: 75))
        skScene.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        
        labelNode = SKLabelNode(fontNamed: "Menlo-Bold")
        labelNode.fontSize = 12
        labelNode.position.y = 50
        labelNode.position.x = 250
        
        skScene.addChild(labelNode)
        
        let plane = SCNPlane(width: 15, height: 3)
        let material = SCNMaterial()
        material.lightingModelName = SCNLightingModelConstant
        material.doubleSided = true
        material.diffuse.contents = skScene
        plane.materials = [material]
        
        hudNode = SCNNode(geometry: plane)
        hudNode.name = "HUD"
        hudNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: 3.14159265)
    }
    
    func initGameCenter() {
        
       let plane = SCNBox(width: 0.8, height: 1.3, length: 1.0, chamferRadius: 0.0)
        
         //let plane = SCNCapsule(capRadius: 0.3, height: 2.5)
        let material = SCNMaterial()
        material.lightingModelName = SCNLightingModelConstant
        material.doubleSided = true
        //geometryNode.geometry?.materials.first?.diffuse.contents = "GeometryFighter.scnassets/Textures/ghostSkingT.png"

        material.diffuse.contents = "GeometryFighter.scnassets/Textures/GameCenter.png"
        plane.materials = [material]
        
        gameCenterNode = SCNNode(geometry: plane)
        gameCenterNode.name = "GameCenter"
        //gameCenterNode.position = SCNVector3Make(0, 0, 0)
        //gameCenterNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: 3.14159265)
    }
    func initAdsFree() {
        
        let squash = SCNCapsule(capRadius: 0.5, height: 1.5)
        let material = SCNMaterial()
        material.lightingModelName = SCNLightingModelConstant
        material.doubleSided = true
        
        material.diffuse.contents = "GeometryFighter.scnassets/Textures/adsFreePumpkin.png"
        squash.materials = [material]
        
        AdsFreeNode = SCNNode(geometry: squash)
        AdsFreeNode.name = "pumpkin"
 
    }

    
    func updateHUD() {
        let scoreFormatted = String(format: "%0\(4)d", score)
        let currentFormatted = String(format: "%0\(4)d", currentT)
        let highScoreFormatted = String(format: "%0\(5)d", highScore)
        
        if (state == .GameOver||state == .TapToPlay){
            currentT = 0
            labelNode.text = "❤️\(lives) 😎\(highScoreFormatted) 🙉\(currentFormatted) 👻\(scoreFormatted)"
        }else{
            labelNode.text = "❤️\(lives) 😎\(highScoreFormatted) 🙈\(currentFormatted) 👻\(scoreFormatted)"
        }
        
    }
    
    func loadSound(name:String, fileNamed:String) {
        if let sound = SCNAudioSource(fileNamed: fileNamed) {
            sound.load()
            sounds[name] = sound
        }
    }
    
    func playSound(node:SCNNode, name:String) {
        let sound = sounds[name]
        node.runAction(SCNAction.playAudioSource(sound!, waitForCompletion: false))
    }
    
    func reset() {
        let defaults = NSUserDefaults.standardUserDefaults()
        // score = defaults.integerForKey("lastScore")
        highScore = defaults.integerForKey("highScore")
        level = defaults.integerForKey("level")
        score = 0
        lives = 3
        currentT = 0
    }
    
    func shakeNode(node:SCNNode) {
        let left = SCNAction.moveBy(SCNVector3(x: -0.2, y: 0.0, z: 0.0), duration: 0.05)
        let right = SCNAction.moveBy(SCNVector3(x: 0.2, y: 0.0, z: 0.0), duration: 0.05)
        let up = SCNAction.moveBy(SCNVector3(x: 0.0, y: 0.2, z: 0.0), duration: 0.05)
        let down = SCNAction.moveBy(SCNVector3(x: 0.0, y: -0.2, z: 0.0), duration: 0.05)
        
        node.runAction(SCNAction.sequence([
            left, up, down, right, left, right, down, up, right, down, left, up,
            left, up, down, right, left, right, down, up, right, down, left, up]))
    }
    
    
}
