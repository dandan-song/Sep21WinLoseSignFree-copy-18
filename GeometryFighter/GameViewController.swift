/*
 * Copyright (c) 2015 Razeware LLC
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

import UIKit
import SceneKit
import MobileCoreServices
import SpriteKit

import CoreMotion


class GameViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var scnView: SCNView!
    var scnScene: SCNScene!
    var backScene: SCNScene!

     var cameraNode: SCNNode!
    var ghostNode: SCNNode!
    var rootsplashNode: SCNNode!
    var rootsplashNode2: SCNNode!
    var backNode: SCNNode!

    //   var geometry:SCNGeometry!
    var spawnTime:NSTimeInterval = 0
    var game = GameHelper.sharedInstance
    var splashNodes:[String:SCNNode] = [:]
    //    let motionManager = CMMotionManager()
    //let motionKit = MotionKit()
    let motionManager = CMMotionManager()
    var start = NSDate()
    var rightPosition = 0
    var srart = 0
    var end = 0
    var labelNode:SKLabelNode!
    var timeInterval1 = 0
    var timeInterval = 0
    var CleanSceneCurrentTime = 0
    var plane = SCNPlane(width: 5, height: 5)
   
    var distance: Float!
    var ghostSize1: Float!
    var ghostSize2: Float!
    var endTime = 10
    var backGround = 0
    let imagePicker = UIImagePickerController();

    


    override func viewDidLoad() {
        super.viewDidLoad()
       
        //scnScene.rootNode.addChildNode(backNode)

        setupView()
        //setupScene()
        setupCamera()
        setupHUD()
        
        
        setupSounds()
        
        setupSplash()
        //game.level = -1
        //print("level:", game.level)
        
        
        if motionManager.deviceMotionAvailable {
            
            motionManager.deviceMotionUpdateInterval = 0.017
            motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue())
            {
                motion, error in
                self.cameraNode.orientation = motion!.gaze(atOrientation: UIApplication.sharedApplication().statusBarOrientation)
                self.rootsplashNode.orientation=self.cameraNode.orientation
                
            }
        }
    }
    
    func deviceDidMove(motion: CMDeviceMotion?, error: NSError?) {
        
        if let motion = motion {
            
            self.cameraNode.orientation = motion.gaze(atOrientation: UIApplication.sharedApplication().statusBarOrientation)
            //change splash node orientation
            self.rootsplashNode.orientation=cameraNode.orientation
        }
    }
    
    
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func setupView() {
        
        backGround = 1
        //if backGround == 1 {
        imagePicker.delegate = self
        imagePicker.sourceType =
            UIImagePickerControllerSourceType.Camera
        imagePicker.allowsEditing = false
        imagePicker.toolbarHidden = true
        imagePicker.navigationBarHidden = true
        imagePicker.showsCameraControls  = false
        //imagePicker.cameraOverlayView!.bounds = self.view.bounds
        /*self.presentViewController(imagePicker, animated: true,
                                   completion: nil)*/
        
        imagePicker.cameraViewTransform = CGAffineTransformMakeScale(1.35, 1.35);
        imagePicker.view.bounds=self.view.bounds  //chuck
        //self.view.addSubview(imagePicker.view)
        //}
        
        scnView = SCNView();

        scnView.frame = self.view.bounds
        scnView.backgroundColor = UIColor.clearColor();
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = false
        scnView.delegate = self
        scnView.playing = true
                self.view.addSubview(scnView)
        scnScene = SCNScene();
        scnView.scene = scnScene
        backNode = SCNNode()
        ghostNode = SCNNode();
        scnScene.rootNode.addChildNode(ghostNode)

        setupScene()
    }
    func setupScene()
    {
        
        print("backGround:backGround", backGround)
        
/* it says for a skybox to use 6 pictues
         //version3 - pass array in directly (NOT through SCNMaterialProperty!!!!)
         scene.background.contents = @[[NSImage imageNamed:@"right.tga"],
         [NSImage imageNamed:@"left.tga"],
         [NSImage imageNamed:@"top.tga"],
         [NSImage imageNamed:@"bottom.tga"],
         [NSImage imageNamed:@"back.tga"],
         [NSImage imageNamed:@"front.tga"]
 */
        backNode.removeFromParentNode()
        for node in ghostNode.childNodes {
            
                node.removeFromParentNode()
            
        }

        if backGround == 0 {
            backScene = SCNScene();
            backNode = backScene.rootNode.clone()

            //need to turn on imagepicker
            self.view.addSubview(imagePicker.view)
            
            scnView.removeFromSuperview()
            self.view.addSubview(scnView)
            scnScene.background.contents =
            "GeometryFighter.scnassets/Textures/background_Transparent1.png"
        }else{
            backScene = SCNScene(named: "GeometryFighter.scnassets/Textures/game1.scn")
            backNode = backScene.rootNode.clone()
            
            //scnScene.background.contents=backScene.background.contents
            let path = "GeometryFighter.scnassets/Textures/envskybox"
            
            scnScene!.background.contents =
                [
                    UIImage(named: path+"_right.png") as UIImage!,  //-z  0003
                    UIImage(named: path+"_left.png") as UIImage!,   //+z  0001
                    UIImage(named: path+"_top.png") as UIImage!,    //+y  0006
                    UIImage(named: path+"_bottom.png") as UIImage!, //-y  0005
                    UIImage(named: path+"_front.png") as UIImage!,  //+x  0004
                    UIImage(named: path+"_back.png") as UIImage!,   //-x  0002
            ]
          
            imagePicker.view.removeFromSuperview()
 
        }
        //scnScene.rootNode.addChildNode(backNode)


    }
    
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        scnScene.rootNode.addChildNode(cameraNode)
        scnView.pointOfView = cameraNode  //selects the current camera node
        rootsplashNode = SCNNode()
        rootsplashNode.position = SCNVector3(x: 0, y: 0, z: 10)
        rootsplashNode2 = SCNNode()
        rootsplashNode2.position = SCNVector3(x: 0, y: 0, z: -10)

        scnScene.rootNode.addChildNode(rootsplashNode)
        rootsplashNode.addChildNode(rootsplashNode2)
    }
    
    func spawnShape() {
        
        
        var geometry:SCNGeometry
        var randomR:Float
       
            randomR = Float.random(min: ghostSize1, max: ghostSize2)
        
            geometry = SCNSphere(radius: CGFloat(randomR))
        let color = UIColor.random()
  

        geometry.materials.first?.diffuse.contents = color
        let geometryNode = SCNNode(geometry: geometry)
        
        geometryNode.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: nil)
        //geometryNode.physicsBody!.mass = 0.0000001
        geometryNode.physicsBody?.affectedByGravity = false
        geometryNode.opacity = 0.2
        //geometryNode.geometry?.materials.first?.diffuse.contents = "GeometryFighter.scnassets/Textures/ghostSkingT.png"
       geometryNode.geometry?.materials.first?.normal.contents = "GeometryFighter.scnassets/Textures/ghostskin2ghostSkin.png"
        //geometryNode.geometry?.materials.first?.emission.contents = "GeometryFighter.scnassets/Textures/img_ball_emission.png"
       
        
        if (true)
        
        {
            var eyes1:SCNGeometry
            eyes1 = SCNSphere(radius: 0.5*CGFloat(randomR))
            eyes1.materials.first?.diffuse.contents = color
            let eyesNode1 = SCNNode(geometry: eyes1)
            eyesNode1.opacity = 1.0
            eyesNode1.position = SCNVector3(x: -0.90*randomR, y: 0.5*randomR, z: 0.0)
            eyesNode1.geometry?.materials.first?.diffuse.contents = "GeometryFighter.scnassets/Textures/eye.png"
            eyesNode1.name="EYES"
             let left = SCNAction.moveBy(SCNVector3(x: -0.5*randomR, y: 0.0, z: 0.0), duration: 1)
            let right = SCNAction.moveBy(SCNVector3(x: 0.5*randomR, y: 0.0, z: 0.0), duration: 1)
            let up = SCNAction.moveBy(SCNVector3(x: 0.0, y: 0.5*randomR, z: 0.0), duration: 1)
            let down = SCNAction.moveBy(SCNVector3(x: 0.0, y: -0.5*randomR, z: 0.0), duration: 1)
            let eyeSpin1 = SCNAction.rotateByAngle(90.0, aroundAxis: SCNVector3Make(0, 0, -3), duration: 1)
            let eyeSpin2 = SCNAction.rotateByAngle(90.0, aroundAxis: SCNVector3Make(0, 0, 3), duration: 1)
            
            let blink1 = SCNAction.sequence([left, eyeSpin2, up, eyeSpin1, down, eyeSpin2, right, eyeSpin1])
            let blink2 = SCNAction.sequence([left, eyeSpin2, up, eyeSpin1, down, eyeSpin2, right, eyeSpin1, right, eyeSpin1, down, eyeSpin2, up, eyeSpin1, left, eyeSpin2])
            let repeatblink1  = SCNAction.repeatActionForever(blink1)
            let repeatblink2  = SCNAction.repeatActionForever(blink2)
            eyesNode1.runAction(repeatblink1)
          
            /*SCNTransaction.begin()
            SCNTransaction.setAnimationDuration(3)
            eyes1.materials.first?.diffuse.contents = "GeometryFighter.scnassets/Textures/eye.png"
            SCNTransaction.commit()*/
            
            geometryNode.addChildNode(eyesNode1)
            
            let tear = SCNParticleSystem(named: "tear.scnp", inDirectory: nil)!
            tear.particleColor = color
            tear.emitterShape = eyes1
            
            eyesNode1.addParticleSystem(tear)
            
            
            var eyes2:SCNGeometry
            eyes2 = SCNSphere(radius: 0.5*CGFloat(randomR))
            eyes2.materials.first?.diffuse.contents = color
            let eyesNode2 = SCNNode(geometry: eyes2)
            eyesNode2.opacity = 1.0
            eyesNode2.position = SCNVector3(x: 0.90*randomR, y: 0.5*randomR, z: 0.0)
            eyesNode2.geometry?.materials.first?.diffuse.contents = "GeometryFighter.scnassets/Textures/eye.png"
            eyesNode2.runAction(repeatblink2)
            eyesNode2.name="EYES"

            geometryNode.addChildNode(eyesNode2)
            
            let tear2 = SCNParticleSystem(named: "tear.scnp", inDirectory: nil)!
            tear2.particleColor = color
            tear2.emitterShape = eyes1
            eyesNode2.addParticleSystem(tear2)
            
            let randomX = Float.random(min: -1*distance, max: distance)
            let randomY = Float.random(min: -1*distance, max:distance)
            var randomZ = Float.random(min: -1*distance, max:distance)
            
            
            if (randomX > -10&&randomX < 10&&randomY < -10&&randomY < 10){
                randomZ = -1*distance
            }
            
            geometryNode.position = SCNVector3(x: randomX, y: randomY, z: randomZ)
            
            let randomX1 = Float.random(min: -10, max: 10)
            let randomY1 = Float.random(min: -10, max:10)
            let randomZ1 = Float.random(min: -10, max: 10)
            let moveTo = SCNAction.moveTo(SCNVector3Make(randomX1, randomY1, randomZ1), duration: 3)
            
            let FinalmoveTo = SCNAction.moveTo(SCNVector3Make(0, 0, 0), duration: 2)
      
            let grow = SCNAction.scaleBy ( 0.2, duration: 1)
            let shrink = SCNAction.reversedAction(grow)
            
            let spine = SCNAction.rotateByAngle(30.0, aroundAxis: SCNVector3Make(0, 0, -3), duration: 1)
            let antiSpine = SCNAction.reversedAction(spine)
            
            
            let end1 = NSDate()
            let timeInterval: Double = end1.timeIntervalSinceDate(start)
            let pi = M_PI
            let moveBy = SCNAction.moveBy(SCNVector3Make(0.1*Float(timeInterval),100.0*Float(sin(timeInterval/(2*pi))), 50.0*Float(sin(timeInterval/(2*pi))) ),duration: 5)
            let antimoveBy = SCNAction.reversedAction(moveBy)
            let fadeOut = SCNAction.fadeOutWithDuration(1)
            let fadeIn = SCNAction.fadeInWithDuration(1)
           //let swirl = SCNAction.rotateByAngle(90.0, aroundAxis: SCNVector3Make(0, 5, 5), duration: 4)
            //let antiSwirl = SCNAction.reversedAction(swirl)
            
          // let fadeSequence = SCNAction.repeatActionForever(SCNAction.sequence([swirl, fadeIn, antiSwirl(), fadeOut, fadeIn]))
           // geometryNode.runAction(fadeSequence)
            
            let sequence = SCNAction.sequence([grow, shrink(), spine, antiSpine(), moveBy, antimoveBy(), moveTo, shrink(),fadeIn, fadeOut,fadeIn,FinalmoveTo])
            geometryNode.runAction(sequence)
 
            
            let trailEmitter = createTrail(color, geometry: geometry)
            geometryNode.addParticleSystem(trailEmitter)
            
            let Sound = createSound()
            geometryNode.runAction(Sound)
            
            game.playSound(scnScene.rootNode, name: "SpawnGood")
            
        }
        geometryNode.name = "GHOST";
        
        ghostNode.addChildNode(geometryNode)
        
        
        
    }
    
    
    func cleanScene() {
        for node in ghostNode.childNodes {
            let py = node.presentationNode.position.y
            let px = node.presentationNode.position.x
            let pz = node.presentationNode.position.z
            if (node != game.hudNode&&(py < 2.0&&py > -2.0)&&py != 0&&(px < 2.0&&px > -2.0)&&px != 0&&(pz < 2.0&&pz > -2.0)&&pz != 0) {
                
                game.shakeNode(cameraNode)
                if game.lives != 0{
                    game.lives -= 1
                }
                game.playSound(scnScene.rootNode, name: "ExplodeBad")
                node.removeFromParentNode()
            }
            
            let plane = SCNPlane(width: 5, height: 10)
            let splashNode = SCNNode(geometry: plane)
            splashNode.position = SCNVector3(x: 0, y: 0, z: 0)
            
            let skScene = SKScene(size: CGSize(width: 500, height: 500))
            skScene.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
            
            
            labelNode = SKLabelNode(fontNamed: "SavoyeLetPlain")
            labelNode.fontSize = 96
            labelNode.position.y = 200
            labelNode.position.x = 250
            
            
            if (game.lives == 1){
               /* scnScene.background.contents =
                "GeometryFighter.scnassets/Textures/backgroundLoose1.png"*/
            }
                
            else if (game.lives == 2){
             /*   scnScene.background.contents =
                "GeometryFighter.scnassets/Textures/backgroundLoose.png"*/
            }
                
            else if (game.lives == 3){
              /*  scnScene.background.contents =
                "GeometryFighter.scnassets/Textures/background_Transparent1.png"*/
            }
            else if (game.lives == 0){
                game.saveState()
                
                labelNode.text = "Survived: \(game.currentT) sec"
                //game.currentT = 0
                
                skScene.addChild(labelNode)
                
                let material = SCNMaterial()
                material.lightingModelName = SCNLightingModelConstant
                material.doubleSided = true
                material.diffuse.contents = skScene
                plane.materials = [material]
                splashNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: 3.14159265)
                splashNodes["GameOver"] = splashNode
                
                
                rootsplashNode2.addChildNode(splashNode)
                if game.state == .TapToPlay{
                    splashNodes["GameOver"]?.hidden = true
                    game.currentT = 0
                }
               // game.saveState()
                if (game.state == .Playing){
                    splashNodes["GameOver"]?.hidden = false
                    game.playSound(scnScene.rootNode, name: "GameOver")
                    game.state = .GameOver
                }else{
                    splashNodes["GameOver"]?.removeFromParentNode()
                }
                scnScene.rootNode.runAction(SCNAction.waitForDurationThenRunBlock(5) { (node:SCNNode!) -> Void in
                    self.showSplash("TapToPlay")
                    self.game.state = .TapToPlay
                    splashNode.removeFromParentNode()
                    })
            }
            //print("endTime:", endTime)
            if (game.state == .Playing&&game.currentT>=endTime){
                game.saveState()
                labelNode.text = "level passed👻"
                skScene.addChild(labelNode)
                
                let material = SCNMaterial()
                material.lightingModelName = SCNLightingModelConstant
                material.doubleSided = true
                material.diffuse.contents = skScene
                plane.materials = [material]
                splashNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: 3.14159265)
                splashNodes["GameOver"] = splashNode
                
                
                rootsplashNode2.addChildNode(splashNode)
                if game.state == .TapToPlay{
                    splashNodes["GameOver"]?.hidden = true
                    
                }
                
                //game.saveState()
                if (game.state == .Playing){
                    splashNodes["GameOver"]?.hidden = false
                    game.playSound(scnScene.rootNode, name: "GameOver")
                    game.state = .GameOver
                }else{
                    splashNodes["GameOver"]?.removeFromParentNode()
                }
                scnScene.rootNode.runAction(SCNAction.waitForDurationThenRunBlock(5) { (node:SCNNode!) -> Void in
                    self.showSplash("TapToPlay")
                    self.game.state = .TapToPlay
                    splashNode.removeFromParentNode()
                    })
            }
            
            
            
        }
        
        
    }

    func createTrail(color: UIColor, geometry: SCNGeometry) -> SCNParticleSystem {
        let trail = SCNParticleSystem(named: "Trail.scnp", inDirectory: nil)!
        trail.particleColor = UIColor.whiteColor1()
        trail.emitterShape = geometry
        //    trail.particleColor.whiteColor(alpha: 0.5)
        return trail
    }
    func createSound() -> SCNAction {
       // let sound = SCNAction
        game.loadSound("Laugh",
                       fileNamed: "GeometryFighter.scnassets/Sounds/ghostLaugh.wav")
        game.loadSound("Alligator",
                       fileNamed: "GeometryFighter.scnassets/Sounds/Alligator.wav")
        game.loadSound("Baby",
                       fileNamed: "GeometryFighter.scnassets/Sounds/Baby.wav")
        game.loadSound("Killer",
                       fileNamed: "GeometryFighter.scnassets/Sounds/Killer Movie.wav")
        game.loadSound("HeartBeat",
                       fileNamed: "GeometryFighter.scnassets/Sounds/Spooky Heart Beat.wav")
        game.loadSound("Sliding",
                       fileNamed: "GeometryFighter.scnassets/Sounds/Sliding-Sound.wav")
        game.loadSound("Beep",
                       fileNamed: "GeometryFighter.scnassets/Sounds/Strange Beeping.wav")
        game.loadSound("Strange",
                       fileNamed: "GeometryFighter.scnassets/Sounds/Strange_Days.wav")
        game.loadSound("Slime",
                       fileNamed: "GeometryFighter.scnassets/Sounds/Slime-SoundBible.com-803762203.wav")
        game.loadSound("sigh",
                       fileNamed: "GeometryFighter.scnassets/Sounds/Female Sigh-.wav")
        game.loadSound("flapping",
                       fileNamed: "GeometryFighter.scnassets/Sounds/Flapping.wav")
        game.loadSound("Door",
                       fileNamed: "GeometryFighter.scnassets/Sounds/Door.wav")
        game.loadSound("Eerie",
                       fileNamed: "GeometryFighter.scnassets/Sounds/Eerie.wav")
        game.loadSound("Board",
                       fileNamed: "GeometryFighter.scnassets/Sounds/Board.wav")
        game.loadSound("Evil Laugh",
                       fileNamed: "GeometryFighter.scnassets/Sounds/Evil Laugh.wav")
        game.loadSound("Elves Laughing",
                       fileNamed: "GeometryFighter.scnassets/Sounds/Elves Laughing.wav")
        game.loadSound("Spooky Water Drops",
                       fileNamed: "GeometryFighter.scnassets/Sounds/Spooky Water Drops.wav")
        
        let SoundList:[String] = [
            "Laugh",
            "Alligator",
            "Baby",
            "Killer",
            "HeartBeat",
            "Sliding",
            "Beep",
            "Strange",
            "Slime",
            "sigh",
            "flapping",
            "Door",
            "Eerie",
            "Spooky Water Drops",
            "Elves Laughing",
            "Evil Laugh",
            "Board"
        ]
        let maxValue = SoundList.count
        let rand = Int(arc4random_uniform(UInt32(maxValue)))
   

        
        let actulyLaugh = SCNAction.playAudioSource(game.sounds[SoundList[rand]]!, waitForCompletion: false)
        let waitAction = SCNAction.waitForDuration(Double.random(min: 10, max: 20))
        let sequenceSound = SCNAction.sequence([waitAction, actulyLaugh])
        let repeatSound = SCNAction.repeatActionForever(sequenceSound)
        return repeatSound
    }

    
    func setupHUD() {
        game.hudNode.position = SCNVector3(x: 0.0, y: 4.0, z: 0.0)
        //game.hudNode.physicsBody = SCNPhysicsBody(type: .Static, shape: nil)
        rootsplashNode2.addChildNode(game.hudNode)
        //cameraNode.addChildNode(game.hudNode)
    }
    
     func showSplash(splashName:String) {
        for (name,node) in splashNodes {
            if name == splashName {
                node.hidden = false
            } else {
                node.hidden = true
            }
        }
    }
    
    func setupSplash() {
        
        let plane = SCNPlane(width: 5, height: 5)
        let splashNode = SCNNode(geometry: plane)
        splashNode.position = SCNVector3(x: 0, y: 0, z: 0)
        splashNode.name = "TapToPlay"
        
        splashNode.geometry?.materials.first?.diffuse.contents = "GeometryFighter.scnassets/Textures/ghost1.png"
        splashNodes["TapToPlay"] = splashNode
        rootsplashNode2.addChildNode(splashNode)
      //  return splashNode
        
       
    }
    
    func setupSounds() {
        
        game.loadSound("ExplodeGood",
                       fileNamed: "GeometryFighter.scnassets/Sounds/ghostPup8.wav")
        game.loadSound("ExplodeGood1",
                       fileNamed: "GeometryFighter.scnassets/Sounds/bloodSplash.wav")
        game.loadSound("SpawnGood",
                       fileNamed: "GeometryFighter.scnassets/Sounds/open_creaky_door.wav")
        game.loadSound("ExplodeBad",
                       fileNamed: "GeometryFighter.scnassets/Sounds/ExplodeBad.wav")
        game.loadSound("SpawnBad",
                       fileNamed: "GeometryFighter.scnassets/Sounds/SpawnBad.wav")
        game.loadSound("GameOver",
                       fileNamed: "GeometryFighter.scnassets/Sounds/GameOver.wav")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if game.state == .GameOver {
            return
        }
        
        if game.state == .TapToPlay {
            game.reset()
            
            game.level = game.level+1
            print("level:", game.level)
            print("endTime:", endTime)
            switch game.level % 31 {
            case 1:
                distance = 15; endTime = 60; ghostSize1 = 1; ghostSize2 = 2; backGround = 0
            case 2:
                distance = 30; endTime = 60; ghostSize1 = 1; ghostSize2 = 2; backGround = 0
            case 3:
                distance = 60; endTime = 60; ghostSize1 = 1; ghostSize2 = 2; backGround = 1
            case 4:
                distance = 90; endTime = 60; ghostSize1 = 0.5; ghostSize2 = 1; backGround = 0
            case 5:
                distance = 60; endTime = 60; ghostSize1 = 0.5; ghostSize2 = 1; backGround = 0
            case 6:
                distance = 30; endTime = 60; ghostSize1 = 0.5; ghostSize2 = 1; backGround = 2
            case 7:
                distance = 15; endTime = 90; ghostSize1 = 1; ghostSize2 = 2; backGround = 0
            case 8:
                distance = 30; endTime = 90; ghostSize1 = 1; ghostSize2 = 2; backGround = 0
            case 9:
                distance = 60; endTime = 90; ghostSize1 = 1; ghostSize2 = 2; backGround = 3
            case 10:
                distance = 90; endTime = 90; ghostSize1 = 0.5; ghostSize2 = 1; backGround = 0
            case 11:
                distance = 60; endTime = 90; ghostSize1 = 0.5; ghostSize2 = 1; backGround = 0
            case 12:
                distance = 60; endTime = 90; ghostSize1 = 0.5; ghostSize2 = 1; backGround = 1
            case 13:
                distance = 30; endTime = 120; ghostSize1 = 1; ghostSize2 = 2; backGround = 0
            case 14:
                distance = 15; endTime = 120; ghostSize1 = 1; ghostSize2 = 2; backGround = 0
            case 15:
                distance = 30; endTime = 120; ghostSize1 = 1; ghostSize2 = 2; backGround = 2
            case 16:
                distance = 60; endTime = 120; ghostSize1 = 0.5; ghostSize2 = 1; backGround = 0
            case 17:
                distance = 90; endTime = 120; ghostSize1 = 0.5; ghostSize2 = 1; backGround = 0
            case 18:
                distance = 60; endTime = 120; ghostSize1 = 0.5; ghostSize2 = 1; backGround = 3
            case 19:
                distance = 30; endTime = 150; ghostSize1 = 1; ghostSize2 = 2; backGround = 0
            case 20:
                distance = 15; endTime = 150; ghostSize1 = 1; ghostSize2 = 2; backGround = 0
            case 21:
                distance = 30; endTime = 150; ghostSize1 = 1; ghostSize2 = 2; backGround = 2
            case 22:
                distance = 60; endTime = 150; ghostSize1 = 0.5; ghostSize2 = 1; backGround = 0
            case 23:
                distance = 90; endTime = 150; ghostSize1 = 0.5; ghostSize2 = 1; backGround = 0
            case 24:
                distance = 60; endTime = 150; ghostSize1 = 0.5; ghostSize2 = 1; backGround = 3
            case 25:
                distance = 30; endTime = 180; ghostSize1 = 1; ghostSize2 = 2; backGround = 0
            case 26:
                distance = 15; endTime = 180; ghostSize1 = 1; ghostSize2 = 2; backGround = 0
            case 27:
                distance = 30; endTime = 180; ghostSize1 = 1; ghostSize2 = 2; backGround = 2
            case 28:
                distance = 60; endTime = 180; ghostSize1 = 0.5; ghostSize2 = 1; backGround = 0
            case 29:
                distance = 90; endTime = 180; ghostSize1 = 0.5; ghostSize2 = 1; backGround = 0
            case 30:
                distance = 60; endTime = 180; ghostSize1 = 0.5; ghostSize2 = 1; backGround = 3

            default:
                distance = 30; endTime = 210; ghostSize1 = 1; ghostSize2 = 2; backGround = 1
            }
            
            print("level:", game.level)
            print("endTime1:", endTime)
            game.saveState()
           // setupView()
            setupScene()

            start = NSDate()
            game.state = .Playing
            showSplash("")
            /*
           scnScene.background.contents =
           "GeometryFighter.scnassets/Textures/background_Transparent.png"
            */
          /*for node in scnScene.rootNode.childNodes {
                if (node != game.hudNode&&node != rootsplashNode){
                node.removeFromParentNode()
                }
            }*/
            return
        }
        
        let touch = touches.first
        let location = touch!.locationInView(scnView)
        let hitResults = scnView.hitTest(location, options: nil)
        
        if hitResults.count > 0 {
            
            let result: AnyObject! = hitResults[0]
            
            if result.node.name == "GHOST" ||
                result.node.name == "EYES"   {
                createExplosion(result.node.geometry!,
                                position: result.node.presentationNode.position,
                                rotation: result.node.presentationNode.rotation)
                
                result.node.removeFromParentNode()

                handleGoodCollision();
            
            }
            
                    }
    }
    
    func handleGoodCollision() {
        game.score += 1
        if (game.lives <= 2&&game.lives > 0){
            game.lives = game.lives + 1;
        }
        print(game.lives)
        game.playSound(scnScene.rootNode, name: "ExplodeGood")
        game.playSound(scnScene.rootNode, name: "ExplodeGood1")
        
    }
    

    
    func createExplosion(geometry: SCNGeometry, position: SCNVector3,
                         rotation: SCNVector4) {
        let explosion =
            SCNParticleSystem(named: "Explode.scnp", inDirectory:
                nil)!
        explosion.emitterShape = geometry
        explosion.birthLocation = .Surface
        let rotationMatrix =
            SCNMatrix4MakeRotation(rotation.w, rotation.x,
                                   rotation.y, rotation.z)
        let translationMatrix =
            SCNMatrix4MakeTranslation(position.x, position.y, position.z)
        let transformMatrix =
            SCNMatrix4Mult(rotationMatrix, translationMatrix)
        scnScene.addParticleSystem(explosion, withTransform: transformMatrix)
    }
}

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(renderer: SCNSceneRenderer, updateAtTime time:
        NSTimeInterval) {
        //setupView()
        if game.state == .Playing{
            if time > spawnTime {
                spawnShape()
                var minN = 10.0 - Float(game.score)
                var maxN = 15.0 - Float(game.score)
                if game.level > 24 {
                    minN = 20.0 - Float(game.score)
                    maxN = 25.0 - Float(game.score)
                }
                
                if (minN <= 1){minN = 1}
                
                if (maxN <= 1){maxN = 1}
                spawnTime = time + NSTimeInterval(Float.random(min: (minN), max:(maxN)))
                
            }
            
            cleanScene()
            
            
        }
        // cleanScene()
        let end = NSDate()
        
        let timeInterval: Double = end.timeIntervalSinceDate(start)
        
        game.currentT = Int (timeInterval)
        game.updateHUD()
        // game.level = 0
        
        
    }
}
