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
//import SpriteKit
import GameKit
import GoogleMobileAds
//import GCHelper
import CoreMotion
import AVFoundation


class GameViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,GKGameCenterControllerDelegate, GADBannerViewDelegate, GADInterstitialDelegate,UIWebViewDelegate, SCNPhysicsContactDelegate{
    
    let CollisionCategoryUnicorn = 1
    let CollisionCategoryLantern = 2
    let CollisionCategoryTarget1 = 8
    let CollisionCategoryStone = 4
    let CollisionCategoryTarget2 = 16
    let CollisionCategoryTarget3 = 32
    let CollisionCategoryTarget0 = 64
    //let CollisionCategoryPlane = 4
    //let CollisionCategoryCrate = 8
    //let CollisionCategoryPearl = 16
    var ballNode:SCNNode!
    
    var scnView: SCNView!
   // var fview: SCNView!
    var scnScene: SCNScene!
    var backScene: SCNScene!
    
    var cameraNode: SCNNode!
    var cameraOrbitNode: SCNNode!
    var FrontcameraNode: SCNNode!
    var ghostNode1: SCNNode!
    var ghostNode2: SCNNode!
    var rootsplashNode: SCNNode!
    var rootsplashNode2: SCNNode!
    var backNode: SCNNode!
    var lantens = [SCNNode]()
    var plates = [SCNNode]()
    var bubbles = [SCNNode]()
    var rootLanterns: SCNNode!
    var geometryNode: SCNNode!
    var target = 0
    var oldtarget = -1
    
    //var geometry:SCNGeometry!
    var spawnTime:TimeInterval = 0
    var game = GameHelper.sharedInstance
    var gc = GCHelper.sharedInstance
   
    var splashNodes:[String:SCNNode] = [:]
    //    let motionManager = CMMotionManager()
    //let motionKit = MotionKit()
    let motionManager = CMMotionManager()
    var start = Date()
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
    //var r1 = 0
    var playGroundN = 0
    var hasCamera = true
    
    var googleBannerView: GADBannerView!
    var googleInterS: GADInterstitial!
    var currentIndex: Int?
    var cars: [SCNNode] = []
    let emptyScene = SCNScene()
    let plainUnicorn = SCNNode()
      var backgroundMusicPlayer = AVAudioPlayer()
    
    //typealias GameOverBlock = (didWin: Bool) -> Void
//typealias GameOverBlock = () -> Void
   // var gameOverBlock: GameOverBlock?
   // var paused: Bool = true
    
 /*   struct PhysicsCategories {
        static let CarCategoryMask: UInt32 = 1
        static let BoxCategoryMask: UInt32 = 2
    }
   */
    typealias GameEndedBlock = () -> Void
    var gameEndedBlock: GameEndedBlock?

    lazy var playerLabels: [SKLabelNode] = {
        return [SKLabelNode]()
    }()
    
    fileprivate var webview: UIWebView!
    
    internal func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController)
    {
        gameCenterViewController.dismiss(animated: true, completion: nil)
        
    }
    
    func setPlayerLabelsInOrder(_ playerAliases: [String]) {
        
        for (index, playerAlias) in
        //enumerate(playerAliases.generate()) {
        playerAliases.makeIterator().enumerated() {
        
            let car = cars[index]
            let labelNode = SKLabelNode(fontNamed: "Marker Felt")
            labelNode.fontSize = 12
            labelNode.fontColor = SKColor.red
            labelNode.text = playerAlias
            
            //let plane = SCNPlane(width: 15, height: 3)
            let skScene = SKScene(size: CGSize(width: 40, height: 20))
            skScene.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
            skScene.addChild(labelNode)
            let material = SCNMaterial()
            
            material.lightingModel = SCNMaterial.LightingModel.constant
            material.isDoubleSided = true
            material.diffuse.contents = skScene
            //      let geometryNode = SCNNode(geometry: geometry)
            var geometry:SCNGeometry
            //geometry = SCNSphere(radius: CGFloat(1.0))
        //let color = UIColor.random()
           //geometry = SCNBox (width: 5, height: 5, length: 5, chamferRadius: 1)
          geometry = SCNPlane(width: 5, height: 2)
           //                                                                                                                                                                              materials.diffuse.contents = [material]
            geometry.materials = [material]
            let geometryNode = SCNNode(geometry: geometry)
            geometryNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: 3.14159265)
           // geometryNode.rotation = SCNVector4(x: 0, y: 0, z: 1, w: 3.14159265)

            car.addChildNode(geometryNode)
           //car.addChildNode(addPlayerLabel(playerAlias))
        }
    }
    
    func setCurrentPlayerIndex(_ index :Int) {
        currentIndex = index
        setupCarCamera()

    }
    
    func saveHighscore(_ score:Int) {
        
        //check if user is signed in
        if GKLocalPlayer.localPlayer().isAuthenticated {
            
            let scoreReporter = GKScore(leaderboardIdentifier: "grp.com.blogdns.songbird.FightWithRealGhosts.leaderboard.score") //leaderboard id here
            
            scoreReporter.value = Int64(score) //score variable here (same as above)
            
            let scoreArray: [GKScore] = [scoreReporter]
            GKScore.report(
                scoreArray, withCompletionHandler:{
                    (error) -> Void in
                    if error != nil {
                        print("error ", error)
                    }
                }
            )
            
        }
    }
    func interstitialWillPresentScreen(_ ad: GADInterstitial!){
        scnView.pause(ad);
        game.state = .paused
    }
    func interstitialDidDismissScreen(_ ad: GADInterstitial!){
        start = Date() //reset start after interstitial
        scnView.play(ad);
        game.state = .playing

    }
    func adViewWillPresentScreen (_ ad:GADBannerView){
        scnView.pause(ad);
        game.state = .paused
     }
    func adViewDidDismissScreen(_ ad:GADBannerView){
        scnView.play(ad);
        game.state = .playing
    }
   /* override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated)
        let notificationIdentifier: String = "NotificationIdentifier"
        
        // Register to receive notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.playerAuthenticated), name: notificationIdentifier, object: nil)
    }*/
    
   /* func playerAuthenticated() {
        //scnScene = SCNScene();
       // scnView.scene = scnScene
        self.networkingEngine = MultiplayerNetworking()
        networkingEngine.delegate = self
       // scnScene.networkingEngine = networkingEngine

        gc.findMatchWithMinPlayers(2, maxPlayers: 2, viewController: self, delegate: self.networkingEngine)
    }
    */
   // func dealloc() {
    //    Notification.defaultCenter().removeObserver(self)
   // }
    // Add new methods to bottom of file
    // MARK: GameKitHelperDelegate
    
    func matchStarted() {
        print("Match started")
    }
    
    func matchEnded() {
      /*  if let block = gameEndedBlock {
            paused = true
            block()
        }*/
        print("Match ended")
    }
    
    func match(_ theMatch: GKMatch, didReceiveData data: Data, fromPlayer playerID: String) {
        print("Received data")
    }
    //initiate gamecenter
   /* func authenticateLocalPlayer(){
        
        let localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            
            if (viewController != nil) {
                self.presentViewController(viewController!, animated: true, completion: nil)
            }
                
            else {
                print((GKLocalPlayer.localPlayer().authenticated))
            }
        }
        
    }*/
    //shows leaderboard screen
    func showLeader() {
        let vc = self.view?.window?.rootViewController
        let gc = GKGameCenterViewController()
        gc.gameCenterDelegate = self
        vc?.present(gc, animated: true, completion: nil)
    }
    func preloadInterstitial(){
        /*
        googleInterS = GADInterstitial(adUnitID: "ca-app-pub-4069508576645875/6125985589")
        
        googleInterS.delegate = self
        
        let request1 = GADRequest()
        request1.testDevices = [kGADSimulatorID,"3e68f968ee31233a1a2437ef26f03707" ]
        
        self.googleInterS.loadRequest(request1)
    */

    }
  
    
    func playBackgroundMusic(_ filename: String) {
        let url = Bundle.main.url(forResource: filename, withExtension: nil)
        guard let newURL = url else {
            print("Could not find file: \(filename)")
            return
        }
        do {
            
                          backgroundMusicPlayer = try AVAudioPlayer(contentsOf: newURL)
            backgroundMusicPlayer.numberOfLoops = -1
            backgroundMusicPlayer.prepareToPlay()
            
            let qualityOfServiceClass = DispatchQoS.QoSClass.background
            let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
            backgroundQueue.async(execute: {
                self.backgroundMusicPlayer.play()
            })

            
            
        
        } catch let error as NSError{
            print(error.description)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        setupView()
        setupNodes()
        spawnShape1()
        //spawnShape2()
        
        //currentIndex = 0
        setupCamera()
           setupHUD()
        
        
        setupSounds()
        
        setupSplash()
        setLanterns()
        //spawnShape1()
        //scnView.scene?.physicsWorld.contactDelegate = self
        /*
         googleBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
         googleBannerView.adUnitID = "ca-app-pub-4069508576645875/6464062784"
         
         googleBannerView.rootViewController = self
         let request: GADRequest = GADRequest()
         request.testDevices = [kGADSimulatorID,"3e68f968ee31233a1a2437ef26f03707" ]
         
         googleBannerView.loadRequest(request)
         
         googleBannerView.frame = CGRectMake(0, view.bounds.height - googleBannerView.frame.size.height, googleBannerView.frame.size.width, googleBannerView.frame.size.height)
         
         self.view.addSubview(googleBannerView!)
         
         preloadInterstitial();
         */
        
        gc.authenticateLocalUser(self)
        //playerAuthenticated()
        //let notificationIdentifier: String = "NotificationIdentifier"se
        //let LocalPlayerIsAuthenticated: String = "local_player_authenticated"
        
        // Register to receive notification
        // NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.playerAuthenticated), name: LocalPlayerIsAuthenticated, object: nil)
        
        if motionManager.isDeviceMotionAvailable {
            //motionManager.startAccelerometerUpdates()
            motionManager.deviceMotionUpdateInterval = 0.017
            motionManager.startDeviceMotionUpdates(to: OperationQueue())
            {
                motion, error in
                self.cameraNode.orientation = motion!.gaze(atOrientation: UIApplication.shared.statusBarOrientation)
                self.rootsplashNode.orientation=self.cameraNode.orientation
                let pi = M_PI
               
                if self.target == 0{
                    
                self.geometryNode.physicsBody?.velocity = SCNVector3(CGFloat((motion!.attitude.roll)), CGFloat( motion!.attitude.pitch-pi*3/8), -2)
                   // print(self.ghostNode1.physicsBody?.position.x)
 
                }
                else if self.target == 1 {
                    
                self.geometryNode.physicsBody?.velocity = SCNVector3(-2, CGFloat( motion!.attitude.pitch-pi*3/8), CGFloat((-1*motion!.attitude.roll)))
                 
                }else if self.target == 2 {
                   self.geometryNode.physicsBody?.velocity = SCNVector3(CGFloat(-1*(motion!.attitude.roll)), CGFloat( motion!.attitude.pitch-pi*3/8), 2)
                    
                }else if self.target == 3 {
                    self.geometryNode.physicsBody?.velocity = SCNVector3(2, CGFloat( motion!.attitude.pitch-pi*3/8), CGFloat(motion!.attitude.roll))
                    
                }else if self.target == 4 {
                    
                }
             }
            
        }
    }

    
    func setLanterns(){
        
        let plate = SCNScene(named: "GeometryFighter.scnassets/Textures/target0.scn")
        let node = plate!.rootNode
        //node!.physicsBody = SCNPhysicsBody(type: .Static, shape: nil)
        //node!.physicsBody?.contactTestBitMask = CollisionCategoryUnicorn
        node.physicsBody = SCNPhysicsBody(
            type: .static,
            shape: SCNPhysicsShape(geometry: SCNBox(width: 10, height: 100, length: 15, chamferRadius: 0.0), options: nil))

        
        
        for _ in 0...3 {
           plates.append(node.clone());
           // plates.append(node!)
        }
        plates[0].physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        plates[0].physicsBody?.categoryBitMask = CollisionCategoryTarget0
        plates[0].physicsBody?.contactTestBitMask = CollisionCategoryUnicorn
        plates[0].physicsBody?.collisionBitMask = -1

        plates[1].physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        plates[1].position = SCNVector3(0, 0, -225)
        plates[1].physicsBody?.categoryBitMask = CollisionCategoryTarget1
        plates[1].physicsBody?.contactTestBitMask = CollisionCategoryUnicorn
        plates[1].physicsBody?.collisionBitMask = -1
        plates[2].physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        plates[2].position = SCNVector3(-225, 0, -225)
        plates[2].physicsBody?.categoryBitMask = CollisionCategoryTarget2
        plates[2].physicsBody?.contactTestBitMask = CollisionCategoryUnicorn
        plates[2].physicsBody?.collisionBitMask = -1
        plates[3].position = SCNVector3(-225, 0, 15)
        plates[3].physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        plates[3].physicsBody?.categoryBitMask = CollisionCategoryTarget3
        plates[3].physicsBody?.contactTestBitMask = CollisionCategoryUnicorn
        plates[3].physicsBody?.collisionBitMask = -1
        for i in 0...3 {
            let trail = SCNParticleSystem(named: "Trail.scnp", inDirectory: nil)!
            plates[i].addParticleSystem(trail)
            plates[i].name = "target" + "\(i)"
            
            print(plates[i].name)
            scnScene.rootNode.addChildNode(plates[i])

        
        }
        
     
        let bubbleS = SCNScene(named: "GeometryFighter.scnassets/Textures/bubble.scn")
        let bubbleNode = bubbleS!.rootNode
        //node!.physicsBody = SCNPhysicsBody(type: .Static, shape: nil)
        
        bubbleNode.physicsBody = SCNPhysicsBody(
            type: .static,
            shape: SCNPhysicsShape(geometry: SCNSphere(radius: 5), options: nil))
        bubbleNode.physicsBody?.contactTestBitMask = CollisionCategoryUnicorn
        bubbleNode.physicsBody?.categoryBitMask = CollisionCategoryStone
        bubbleNode.physicsBody?.collisionBitMask = CollisionCategoryStone

        
        
        for _ in 0...30 {
            
        bubbles.append(bubbleNode.clone())
            
            
        }
        
        for i in 0...15 {

            let r = Int(arc4random_uniform(5))
            bubbles[i].position = SCNVector3(x: -195+Float(r-3)*15, y: Float(r-3)*15, z: -195+Float(i*10))
            scnScene.rootNode.addChildNode(bubbles[i])
        }
        for i in 15...30 {
  
            let r = Int(arc4random_uniform(5))
            bubbles[i].position = SCNVector3(x: -195+Float((i-15)*10), y: Float(r-3)*15, z: Float(r-3)*15)
            scnScene.rootNode.addChildNode(bubbles[i])
        }
        
        let lanternScene = SCNScene(named: "GeometryFighter.scnassets/Textures/arrow.scn")
        let lanten = lanternScene!.rootNode
        lanten.name = "lan"
        //lanten.physicsBody = SCNPhysicsBody(type: .Static, shape: nil)
        lanten.physicsBody = SCNPhysicsBody(
            type: .static,
            shape: SCNPhysicsShape(geometry: SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0.0), options: nil))

        lanten.physicsBody?.categoryBitMask = CollisionCategoryLantern
        lanten.physicsBody?.collisionBitMask = -1
        lanten.physicsBody?.contactTestBitMask = CollisionCategoryUnicorn
        
        let dimondScene = SCNScene(named: "GeometryFighter.scnassets/Textures/arrow1.scn")
        let dimond = dimondScene!.rootNode
        //dimond.eulerAngles = SCNVector3(0,90,0)
        dimond.name = "lan"
        dimond.physicsBody = SCNPhysicsBody(
            type: .static,
            shape: SCNPhysicsShape(geometry: SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0.0), options: nil))
        dimond.physicsBody?.categoryBitMask = CollisionCategoryLantern
        dimond.physicsBody?.collisionBitMask = -1
        dimond.physicsBody?.contactTestBitMask = CollisionCategoryUnicorn
        
        let bubbleScene = SCNScene(named: "GeometryFighter.scnassets/Textures/arrow2.scn")
        let bubble = bubbleScene!.rootNode
        //bubble.eulerAngles = SCNVector3(0,180,0)
        bubble.name = "lan"
        bubble.physicsBody = SCNPhysicsBody(
            type: .static,
            shape: SCNPhysicsShape(geometry: SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0.0), options: nil))
        bubble.physicsBody?.categoryBitMask = CollisionCategoryLantern
        bubble.physicsBody?.collisionBitMask = -1
        bubble.physicsBody?.contactTestBitMask = CollisionCategoryUnicorn
        
        let ringScene = SCNScene(named: "GeometryFighter.scnassets/Textures/arrow3.scn")
        let ring = ringScene!.rootNode
        //ring.eulerAngles = SCNVector3(0,-90,0)
        ring.name = "lan"
        ring.physicsBody = SCNPhysicsBody(
            type: .static,
            shape: SCNPhysicsShape(geometry: SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0.0), options: nil))
        ring.physicsBody?.categoryBitMask = CollisionCategoryLantern
        ring.physicsBody?.collisionBitMask = -1
        ring.physicsBody?.contactTestBitMask = CollisionCategoryUnicorn
        

        for _ in 0...79 {
            lantens.append(lanten.clone());
        }
        for _ in 80...119 {
            lantens.append(dimond.clone());
        }
        for _ in 120...159 {
            lantens.append(bubble.clone());
        }
        for _ in 160...199 {
            
            lantens.append(ring.clone());
        }
        for i in 0...39 {
            lantens[i].position = SCNVector3(-20, 0, -5*i)
            scnScene.rootNode.addChildNode(lantens[i])
            //rootLanterns.addChildNode(lantens[i]);
        } /* for (index, element) in lantens.enumerate() {
         element.position = SCNVector3(-5*index, 0, 0)
         print("Item \(index): \(element)")
         }*/
        for i in 40...79 {
            lantens[i].position = SCNVector3(20, 0, -5*(i-40))
            scnScene.rootNode.addChildNode(lantens[i])
        }
        
        for i in 80...119 {
            lantens[i].position = SCNVector3(-10-(i-80)*5, 0, -5*40)
            scnScene.rootNode.addChildNode(lantens[i])
        }
        
        for i in 120...159 {
            lantens[i].position = SCNVector3(-205, 0, -195 + 5*(i-120))
            scnScene.rootNode.addChildNode(lantens[i])
        }
        
        for i in 160...199 {
            lantens[i].position = SCNVector3(-210+5*(i-159), 0, 0)
                        scnScene.rootNode.addChildNode(lantens[i])
        }
    }
 
/*    func didBeginContact(contact: SCNPhysicsContact) {
        if Float(contact.nodeA.categoryBitMask) != Float(UInt32.max)
            && Float(contact.nodeB.categoryBitMask) != Float(UInt32.max)
            && (contact.nodeA.categoryBitMask +
                contact.nodeB.categoryBitMask ==
                Int(PhysicsCategories.CarCategoryMask +
                PhysicsCategories.BoxCategoryMask)) {
            
            networkingEngine?.sendLapComplete()
            
           // noOfCollisionsWithBoxes += 1
            //runAction(boxSoundAction)
        }
    }
*/
    
  /*  func setPositionOfCar(index: Int, roll: Float, pitch: Float) {
        let pi = Float(M_PI)
        let car = cars[index] as SCNNode
      // let turn = SCNAction.rotateByAngle(CGFloat(0.01*yaw), aroundAxis: SCNVector3Make(0, 1, 0), duration: 0.1)
       //car.parentNode!.runAction(turn)
       // car.runAction(turn)
       // car.parentNode!.runAction(SCNAction.moveBy(SCNVector3(CGFloat(0.1 * roll), CGFloat(0.5 * (pitch-pi*3/8)), 0),duration: 0.001))
        car.parentNode!.physicsBody?.affectedByGravity = false
      //car.parentNode!.physicsBody?.velocity = SCNVector3(0, 0, CGFloat((pitch-pi*3/8)))
       //car.runAction(SCNAction.moveBy(SCNVector3(0, 0, -0.1), duration: 50))
       //car.parentNode!.physicsBody?.applyTorque(SCNVector4(x: 0,y:1,z: 0, w: 0.1*Float(yaw)), impulse: true)
      car.physicsBody?.velocity = SCNVector3(CGFloat(roll), CGFloat((pitch-pi*3/8)), -1)
 
    }
    func addPlayerLabel(text: String) -> SCNNode {
        let labelNode = SKLabelNode(fontNamed: "Marker Felt")
        labelNode.fontSize = 72
        labelNode.fontColor = SKColor.redColor()
        labelNode.text = text
        //let plane = SCNPlane(width: 15, height: 3)
        let skScene = SKScene(size: CGSize(width: 75, height: 75))
        skScene.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        
        let material = SCNMaterial()
        material.lightingModelName = SCNLightingModelConstant
        material.doubleSided = true
        material.diffuse.contents = skScene
  //      let geometryNode = SCNNode(geometry: geometry)
        var geometry:SCNGeometry
        geometry = SCNPlane(width: 15, height: 10)
       // let color = UIColor.random()
        //geometry.materials.first?.diffuse.contents = color
        geometry.materials = [material]
        let geometryNode = SCNNode(geometry: geometry)

        return geometryNode

    }
  */
func gameOver(_ didLocalPlayerWin: Bool) {
  // paused = true
    //gameOverBlock?()
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func setupView() {
        
     //   backGround = 0
     /*   imagePicker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        {
            let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
            if status == AVAuthorizationStatus.Authorized {
                self.hasCamera = true
                print ("has camera")
                // Show camera
            } else if status == AVAuthorizationStatus.NotDetermined {
                // Request permission
                AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted) -> Void in
                    if granted {
                        // Show camera
                        self.hasCamera = true
                        print ("has camera")

                    }
                })
            } else {
                self.hasCamera = false
                print ("has camera but access denied")

                // User rejected permission. Ask user to switch it on in the Settings app manually
            }
            if hasCamera {
                imagePicker.sourceType =
                    UIImagePickerControllerSourceType.Camera
                
                imagePicker.allowsEditing = false
                imagePicker.toolbarHidden = true
                imagePicker.navigationBarHidden = true
                imagePicker.showsCameraControls  = false
                imagePicker.modalPresentationStyle = UIModalPresentationStyle.FullScreen
                imagePicker.cameraOverlayView!.bounds = self.view.bounds
            }
        } else {
            print ("no camera or restricted.")

            hasCamera = false
        }
        
        imagePicker.view.transform = CGAffineTransformMakeScale(2, 2);
        */
        
       
        scnView = self.view as! SCNView
       // scnView.frame = self.view.bounds
       // scnView.backgroundColor = UIColor.clearColor();
        scnView.autoenablesDefaultLighting = true
       //scnView.allowsCameraControl = false
        scnView.delegate = self
        //scnView.playing = true
        
        //self.view.addSubview(scnView)
        //scnScene = SCNScene();
        scnScene = SCNScene(named: "GeometryFighter.scnassets/Textures/game1.scn")
        scnScene?.physicsWorld.contactDelegate = self
        scnView.scene = scnScene
        
        //backNode = SCNNode()
        ghostNode1 = SCNNode();
       // ghostNode2 = SCNNode();
       // rootLanterns = SCNNode()

    scnScene.rootNode.addChildNode(ghostNode1)
        //scnScene.rootNode.addChildNode(ghostNode2)
        //scnScene.rootNode.addChildNode(rootLanterns)

        
        //setupScene()
    }
    func switchScene(_ playGroundN: Int){
        switch playGroundN % 7 {
            
        case 1:
            backScene = SCNScene(named: "GeometryFighter.scnassets/Textures/playground1.scn")
        case 2:
            backScene = SCNScene(named: "GeometryFighter.scnassets/Textures/playground2.scn")
        case 3:
            backScene = SCNScene(named: "GeometryFighter.scnassets/Textures/playground3.scn")
        case 4:
            backScene = SCNScene(named: "GeometryFighter.scnassets/Textures/playground4.scn")
        case 5:
            backScene = SCNScene(named: "GeometryFighter.scnassets/Textures/playground5.scn")
        case 6:
            backScene = SCNScene(named: "GeometryFighter.scnassets/Textures/playground6.scn")
        default:
            backScene = SCNScene(named: "GeometryFighter.scnassets/Textures/playground0.scn")
        }
    }
    func setupScene()
    {
        
       /* print("backGround:backGround", backGround)
        
        backNode.removeFromParentNode()
        for node in ghostNode1.childNodes {
            
            node.removeFromParentNode()
            
        }
        for node in ghostNode2.childNodes {
            
            node.removeFromParentNode()
            
        }
       if !hasCamera {
            backGround = 1 + Int(arc4random_uniform(5))
        }
        backGround = 1
       if backGround == 0 {
            backScene = SCNScene();
            backNode = backScene.rootNode.clone()
            
            //need to turn on imagepicker
            self.view.addSubview(imagePicker.view)
            
            scnView.removeFromSuperview()
            self.view.addSubview(scnView)
            scnScene.background.contents =
            "GeometryFighter.scnassets/Textures/background_Transparent1.png"
            /*googleBannerView.removeFromSuperview()
            self.view.addSubview(googleBannerView!)*/

        }
        else if backGround == 1 {
            
            //let r1 = Int(arc4random_uniform(9))
            let r1 = 0
            if r1 == 0 {*/
              //  scnScene = SCNScene(named: "GeometryFighter.scnassets/Textures/game.scn")
                
           /* }else if r1 == 1 {
                scnScene = SCNScene(named: "GeometryFighter.scnassets/Textures/cloudeBaloon.scn")
                
            }else{
                switchScene(playGroundN)
                playGroundN = playGroundN+1
            }
           // backScene.physicsWorld.contactDelegate = self
           // ballNode = backScene.rootNode.childNode(withName: "p0", recursively: true)!
           // ballNode.physicsBody?.contactTestBitMask = CollisionCategoryStone
            
            //backNode = backScene.rootNode.clone()
            //backNode = backScene.rootNode
           // scnScene.background.contents=backScene.background.contents
            //imagePicker.view.removeFromSuperview()
            
        }else{
            
            var path = ""
            
            if backGround == 2 {
                
                path = "GeometryFighter.scnassets/Textures/envskybox"
                let r11 = Int(arc4random_uniform(8))
                if r11 == 0{
                    scnScene = SCNScene(named: "GeometryFighter.scnassets/Textures/cactusLong.scn")
                }else{
                    switchScene(playGroundN)
                    playGroundN = playGroundN+1
                }
                
            }else if backGround == 3 {
                
                path = "GeometryFighter.scnassets/Textures/beach"
                scnScene = SCNScene(named: "GeometryFighter.scnassets/Textures/latern.scn")
            }
            else if backGround == 4 {
                
                let r1 = Int(arc4random_uniform(8))
                
                if r1 == 0 {
                    scnScene = SCNScene(named: "GeometryFighter.scnassets/Textures/lutosFlower.scn")
                }else{
                    switchScene(playGroundN)
                    playGroundN = playGroundN+1
                }
                path = "GeometryFighter.scnassets/Textures/moonWater"
                
            }else if backGround == 5 {
                
                switchScene(playGroundN)
                playGroundN = playGroundN+1
                path = "GeometryFighter.scnassets/Textures/sun"
                
            }else if backGround == 6 {
                
                scnScene = SCNScene(named: "GeometryFighter.scnassets/Textures/door.scn")
                path = "GeometryFighter.scnassets/Textures/wave"
            }

           // backNode = backScene.rootNode.clone()
            //backNode = backScene.rootNode
            scnScene!.background.contents =
                [
                    UIImage(named: path+"_front.png") as UIImage!,  //+x  0004
                    UIImage(named: path+"_back.png") as UIImage!,   //-x  0002
                    UIImage(named: path+"_top.png") as UIImage!,    //+y  0006
                    UIImage(named: path+"_bottom.png") as UIImage!, //-y  0005
                    UIImage(named: path+"_left.png") as UIImage!,   //+z  0001
                    UIImage(named: path+"_right.png") as UIImage!,  //-z  0003
                    
            ]
            
           // imagePicker.view.removeFromSuperview()
            
        }
        //scnScene.rootNode.addChildNode(backNode)
      //  scnScene.physicsWorld.contactDelegate = self*/
        
    }
    func setupCarCamera(){
        //if let index = self.currentIndex {
            //let car = self.cars[index]
            geometryNode.addChildNode(cameraNode)
        
      

        //}
    }
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()

        cameraNode.position = SCNVector3(x: 0, y: 50, z: 60)
        setupCarCamera()
        scnView.pointOfView = cameraNode
        
        FrontcameraNode = SCNNode()
        cameraOrbitNode = SCNNode()
        FrontcameraNode.camera = SCNCamera()
        FrontcameraNode.position = SCNVector3(x: 0, y: 20, z: 60)
        cameraOrbitNode.addChildNode(FrontcameraNode)
        geometryNode.addChildNode(cameraOrbitNode)

     
       /* let sizeScnView = CGSize(width: 210.0, height: 290.0)
        //let centerView = CGPoint(x: CGRectGetMidX(self.view.frame) - sizeScnView.width/2, y: CGRectGetMidY(self.view.frame) - sizeScnView.height/2)
        let centerView = CGPoint(x: CGRectGetMidX(self.view.frame) - sizeScnView.width, y: CGRectGetMidY(self.view.frame) - sizeScnView.height)
        fview = SCNView(frame: CGRect(origin: centerView, size: sizeScnView))
        fview.scene = SCNScene()
        self.view.addSubview(fview)
        
        
        FrontcameraNode = SCNNode()
        FrontcameraNode.camera = SCNCamera()
        geometryNode.addChildNode(FrontcameraNode)
        fview.pointOfView = FrontcameraNode
        //print(cameraFollowNode.position.z, " HAhA2")*/
        
       /*   fsceneView.pointOfView = cameraFollowNode
        cameraFollowNode.position.x = geometryNode.position.x
        cameraFollowNode.position.y = geometryNode.position.y + 10
        cameraFollowNode.position.z = geometryNode.position.z + 5
       // scnView.pointOfView = cameraFollowNode
        
        print(cameraFollowNode.position.z, " HAhA2")*/
        rootsplashNode = SCNNode()
        rootsplashNode.position = SCNVector3(x: 0, y: 0, z: 10)
        rootsplashNode2 = SCNNode()
        rootsplashNode2.position = SCNVector3(x: 0, y: 0, z: -10)
        
        scnScene.rootNode.addChildNode(rootsplashNode)
        //rootsplashNode.addChildNode(rootsplashNode2)
    }
    
    func spawnShape1() {
        geometryNode = SCNNode()
        //unicornScene = SCNScene()
       // let unicornScene = SCNScene(named: "GeometryFighter.scnassets/Textures/plainUnicorn.dae")
        
        //emptyScene = SCNScene()
        geometryNode = emptyScene.rootNode
        emptyScene.rootNode.addChildNode(plainUnicorn)
        let unicornbody = SCNNode()
       // geometryNode = unicornScene!.rootNode
        unicornbody.position = SCNVector3(x: 0, y: 15, z: 10)
        geometryNode.position = SCNVector3(x: 0, y: 10, z: 0)
        let color = UIColor.random()
        let stars = SCNParticleSystem(named: "spark.scnp", inDirectory: nil)!
        stars.particleColor = color
        //stars.position = SCNVector3(x: 0, y: 5, z: 0)
        
        unicornbody.addParticleSystem(stars)
        
        geometryNode.physicsBody = SCNPhysicsBody(
            type: .dynamic,
            shape: SCNPhysicsShape(geometry: SCNBox(width: 5, height: 1000, length: 5, chamferRadius: 0.0), options: nil)
        )
       geometryNode.physicsBody?.isAffectedByGravity = false
        geometryNode.physicsBody!.mass = 1
        //geometryNode.physicsBody!.friction = 0.5
        geometryNode.physicsBody!.angularVelocityFactor = SCNVector3(x: 0, y: 0, z: 0)
        geometryNode.physicsBody?.categoryBitMask = CollisionCategoryUnicorn
        geometryNode.physicsBody?.collisionBitMask = CollisionCategoryLantern|CollisionCategoryStone
        geometryNode.physicsBody?.contactTestBitMask = CollisionCategoryTarget0|CollisionCategoryTarget1|CollisionCategoryTarget2|CollisionCategoryTarget3|CollisionCategoryLantern|CollisionCategoryStone
        geometryNode.name = "g1"
        //scnScene.rootNode.addChildNode(geometryNode)
        geometryNode.addChildNode(unicornbody)
        ghostNode1.addChildNode(geometryNode)
        cars.append(geometryNode)
    }
    func spawnShape11() {
        geometryNode = SCNNode()
        let unicornScene = SCNScene(named: "GeometryFighter.scnassets/Textures/plainUnicorn1.dae")
        // geometryNode = unicornScene!.rootNode
        let unicornbody = SCNNode()
        geometryNode = unicornScene!.rootNode
        unicornbody.position = SCNVector3(x: 0, y: 15, z: 10)
        geometryNode.position = SCNVector3(x: -2, y: 5, z: 0)
        let color = UIColor.random()
        let stars = SCNParticleSystem(named: "spark.scnp", inDirectory: nil)!
        stars.particleColor = color
        //stars.position = SCNVector3(x: 0, y: 5, z: 0)
        
        unicornbody.addParticleSystem(stars)
        
        geometryNode.physicsBody = SCNPhysicsBody(
            type: .dynamic,
            shape: SCNPhysicsShape(geometry: SCNBox(width: 5, height: 1000, length: 5, chamferRadius: 0.0), options: nil)
        )
        geometryNode.physicsBody?.isAffectedByGravity = false
        geometryNode.physicsBody!.mass = 1
        geometryNode.physicsBody!.friction = 0
        geometryNode.physicsBody!.angularVelocityFactor = SCNVector3(x: 0, y: 0, z: 0)
        geometryNode.physicsBody?.categoryBitMask = CollisionCategoryUnicorn
        geometryNode.physicsBody?.collisionBitMask = CollisionCategoryTarget0|CollisionCategoryTarget1|CollisionCategoryTarget2|CollisionCategoryTarget3|CollisionCategoryLantern|CollisionCategoryStone
        geometryNode.physicsBody?.contactTestBitMask = CollisionCategoryTarget0|CollisionCategoryTarget1|CollisionCategoryTarget2|CollisionCategoryTarget3|CollisionCategoryLantern|CollisionCategoryStone
        geometryNode.name = "g1"
        //scnScene.rootNode.addChildNode(geometryNode)
        geometryNode.addChildNode(unicornbody)
        ghostNode1.addChildNode(geometryNode)
        cars.append(geometryNode)
    }

    
    func spawnShape2() {
        var geometryNode: SCNNode
        let unicornScene = SCNScene(named: "GeometryFighter.scnassets/Textures/unicorn3.dae")
        geometryNode = unicornScene!.rootNode
        geometryNode.position = SCNVector3(x: 2, y: 5, z: 0)
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        geometryNode.physicsBody?.isAffectedByGravity = false
        geometryNode.physicsBody!.mass = 1
        geometryNode.physicsBody!.angularVelocityFactor = SCNVector3(x: 0, y: 0, z: 0)
        geometryNode.physicsBody?.categoryBitMask = 1
        geometryNode.name = "g1"
        geometryNode.physicsBody?.collisionBitMask = CollisionCategoryTarget0|CollisionCategoryTarget1|CollisionCategoryTarget2|CollisionCategoryTarget3|CollisionCategoryLantern
        //ghostNode2.addChildNode(geometryNode)
        scnScene.rootNode.addChildNode(geometryNode)
        cars.append(geometryNode)
        geometryNode.physicsBody?.contactTestBitMask = CollisionCategoryTarget0|CollisionCategoryTarget1|CollisionCategoryTarget2|CollisionCategoryTarget3|CollisionCategoryLantern|CollisionCategoryStone
        

        
    }
    
 /*   func spawnShape() {
        
        
        var geometry:SCNGeometry
        // var randomR:Float
        
        // randomR = Float.random(min: ghostSize1, max: ghostSize2)
        
        geometry = SCNSphere(radius: CGFloat(1.0))
        let color = UIColor.random()
        
        
        geometry.materials.first?.diffuse.contents = color
        geometryNode = SCNNode(geometry: geometry)
        
        geometryNode.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: nil)
        //geometryNode.physicsBody!.mass = 0.0000001
        geometryNode.physicsBody?.affectedByGravity = false
        geometryNode.opacity = 1
        //geometryNode.geometry?.materials.first?.diffuse.contents = "GeometryFighter.scnassets/Textures/ghostSkingT.png"
        geometryNode.geometry?.materials.first?.normal.contents = "GeometryFighter.scnassets/Textures/ghostskin2ghostSkin.png"
        //geometryNode.geometry?.materials.first?.emission.contents = "GeometryFighter.scnassets/Textures/img_ball_emission.png"
        
        
        
        geometryNode.physicsBody!.mass = 0.2
        geometryNode.name = "GHOST";
        
        ghostNode.addChildNode(geometryNode)
        
        
    }
    */
    func setUpTarget() {
    
    }
    func replaceUnicorn(_ plainUnicorn: SCNNode){
        let tempnode = SCNNode();
        tempnode.name = "plainu";
        for node in plainUnicorn.childNodes as [SCNNode] {
            tempnode.addChildNode(node)
        }
        emptyScene.rootNode.childNode(withName: "plainu",recursively: false)?.removeFromParentNode();
        emptyScene.rootNode.addChildNode(tempnode)
    }
    func updateScene() {
        if target == 0 && oldtarget != 0 && oldtarget != 3{
            oldtarget = target
            let unicornScene = SCNScene(named: "GeometryFighter.scnassets/Textures/plainUnicorn.dae")
            replaceUnicorn(unicornScene!.rootNode)
         
        }
       else if target == 1 && oldtarget != 1{
            oldtarget = target
           
            let unicornScene = SCNScene(named: "GeometryFighter.scnassets/Textures/plainUnicorn1.dae")
            replaceUnicorn(unicornScene!.rootNode)
   
        }else if target == 2 && oldtarget != 2{
            oldtarget = target
            
            let unicornScene = SCNScene(named: "GeometryFighter.scnassets/Textures/plainUnicorn2.dae")
            replaceUnicorn(unicornScene!.rootNode)
            
        }else if target == 3 && oldtarget != 3{
            oldtarget = target
            
            let unicornScene = SCNScene(named: "GeometryFighter.scnassets/Textures/plainUnicorn3.dae")
            replaceUnicorn(unicornScene!.rootNode)
            print("oldtarget",oldtarget)
            
        }else if target == 0 && oldtarget == 3{
            //not working
            oldtarget = target
            
            let unicornScene = SCNScene(named: "GeometryFighter.scnassets/Textures/plainUnicorn4.dae")
            replaceUnicorn(unicornScene!.rootNode)
            
        }
        
        
        
       //if Lap Complete
       // networkingEngine?.sendLapComplete()
        
        
        
       /* for node in ghostNode.childNodes {
            let py = node.presentationNode.position.y
            let px = node.presentationNode.position.x
            let pz = node.presentationNode.position.z
            if (node != game.hudNode&&(py < 2.0&&py > -2.0)&&py != 0&&(px < 2.0&&px > -2.0)&&px != 0&&(pz < 2.0&&pz > -2.0)&&pz != 0) {
                
                game.shakeNode(cameraNode)
                if game.lives != 0{
                    game.lives -= 1
                }
                game.playSound(scnScene.rootNode, name: "ExplodeBad")
               // node.physicsBody!.applyForce(SCNVector3(40 * CGFloat(1), 0,0), atPosition: SCNVector3(0,0,0), impulse:true)
          
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
            
            
             if (game.lives == 0){
                game.saveState()
                saveHighscore(game.totalScore)
                
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
                    preloadInterstitial();

                }else{
                    splashNodes["GameOver"]?.removeFromParentNode()
                }
                scnScene.rootNode.runAction(SCNAction.waitForDurationThenRunBlock(5) { (node:SCNNode!) -> Void in
                    self.showSplash("TapToPlay")
                    self.game.gameCenterNode.hidden = false
                    self.game.AdsFreeNode.hidden = false

                    self.game.state = .TapToPlay
                    splashNode.removeFromParentNode()
                    })
            }
            //print("endTime:", endTime)
            if (game.state == .Playing&&game.currentT>=endTime){
                game.saveState()
                saveHighscore(game.totalScore)
                
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
                    preloadInterstitial();

                }else{
                    splashNodes["GameOver"]?.removeFromParentNode()
                }
                scnScene.rootNode.runAction(SCNAction.waitForDurationThenRunBlock(5) { (node:SCNNode!) -> Void in
                    self.showSplash("TapToPlay")
                    self.game.gameCenterNode.hidden = false
                    self.game.AdsFreeNode.hidden = false

                    self.game.state = .TapToPlay
                    splashNode.removeFromParentNode()
                    })
            }
            
            
            
        }
        */
        
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
        
        
        
        let actulyLaugh = SCNAction.playAudio(game.sounds[SoundList[rand]]!, waitForCompletion: false)
        let waitAction = SCNAction.wait(duration: Double.random(min: 10, max: 20))
        let sequenceSound = SCNAction.sequence([waitAction, actulyLaugh])
        let repeatSound = SCNAction.repeatForever(sequenceSound)
        return repeatSound
    }
    
    
    func setupHUD() {
        game.hudNode.position = SCNVector3(x: 0.0, y: 4.0, z: 0.0)
        game.gameCenterNode.position = SCNVector3(x: 2.3, y: 2.5, z: 0.0)
        game.AdsFreeNode.position = SCNVector3(x: 2.3, y: -4.0, z: 0.0)
       

        rootsplashNode2.addChildNode(game.hudNode)
        rootsplashNode2.addChildNode(game.gameCenterNode)
        rootsplashNode2.addChildNode(game.AdsFreeNode)
        //rootsplashNode.addChildNode(rootsplashNode2)

        cameraNode.addChildNode(rootsplashNode2)
    }
    
    func showSplash(_ splashName:String) {
        for (name,node) in splashNodes {
            if name == splashName {
                node.isHidden = false
            } else {
                node.isHidden = true
            }
        }
    }
    
    func setupSplash() {
        
        let plane = SCNPlane(width: 5, height: 5)
        let splashNode = SCNNode(geometry: plane)
        splashNode.position = SCNVector3(x: 0, y: 0, z: -2)
        splashNode.name = "TapToPlay"
        
        splashNode.geometry?.materials.first?.diffuse.contents = "GeometryFighter.scnassets/Textures/ghost1.png"
        splashNodes["TapToPlay"] = splashNode
        rootsplashNode2.addChildNode(splashNode)
        //  return splashNode
        
        
    }
    
    func setupSounds() {
        
       game.loadSound("foghorn",fileNamed: "GeometryFighter.scnassets/Sounds/foghorn.wav")
        game.loadSound("fly",fileNamed: "GeometryFighter.scnassets/Sounds/fly.wav")
       game.loadSound("windBell", fileNamed: "GeometryFighter.scnassets/Sounds/WindBell.m4a")
        game.loadSound("Sliding-Sound",fileNamed: "GeometryFighter.scnassets/Sounds/Sliding-Sound.wav")
        game.loadSound("chinese", fileNamed: "GeometryFighter.scnassets/Sounds/chinese.wav")
        game.loadSound("GameOver", fileNamed: "GeometryFighter.scnassets/Sounds/GameOver.wav")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if game.state == .gameOver {
            return
        }
        
        scnView.pointOfView = FrontcameraNode
        let turn = SCNAction.rotate(by: CGFloat(M_PI*2), around: SCNVector3Make(0, 1, 0), duration: 10)
        cameraOrbitNode.runAction(turn)
        
        game.playSound(scnScene.rootNode, name: "windBell")

        
        if game.state == .tapToPlay {
            
            
            let touch = touches.first
            let location = touch!.location(in: scnView)
            let hitResults = scnView.hitTest(location, options: nil)
            
            if hitResults.count > 0 {
                
                let result: SCNHitTestResult! = hitResults[0]
                if result.node.name == "GameCenter"   {
                    showLeader();
                    return;
                }
                if result.node.name == "pumpkin"   {
                   /* webview = UIWebView(frame : self.view.bounds)
                    webview.delegate = self;
                    self.view.addSubview(webview)
                    let url = NSURL(string : "itms-apps://itunes.apple.com/us/app/fighting-with-real-ghost/id1160465117?ls=1&mt=8")
                    let urlRequest = NSURLRequest(URL: url!)
                    self.webview.loadRequest(urlRequest)
                    self.webview.removeFromSuperview()
                    return;*/
                }
               
                
            }
            //not hit a label then do the play action
          //  playerAuthenticated()
            game.reset()
           //FrontcameraNode.position = SCNVector3(x: 0, y: 20, z: 60)
            
           // FrontcameraNode.eulerAngles = SCNVector3Make(0, Float(M_PI), 0)


           /* game.level = game.level+1
            print("level:", game.level)
            print("endTime:", endTime)
            switch game.level % 31 {
            case 0:
                distance = 15; endTime = 60; ghostSize1 = 0.5; ghostSize2 = 1; backGround = 0
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
                distance = 60; endTime = 90; ghostSize1 = 0.5; ghostSize2 = 1; backGround = 4
            case 13:
                distance = 30; endTime = 120; ghostSize1 = 1; ghostSize2 = 2; backGround = 0
            case 14:
                distance = 15; endTime = 120; ghostSize1 = 1; ghostSize2 = 2; backGround = 0
            case 15:
                distance = 30; endTime = 120; ghostSize1 = 1; ghostSize2 = 2; backGround = 5
            case 16:
                distance = 60; endTime = 120; ghostSize1 = 0.5; ghostSize2 = 1; backGround = 0
            case 17:
                distance = 90; endTime = 120; ghostSize1 = 0.5; ghostSize2 = 1; backGround = 0
            case 18:
                distance = 60; endTime = 120; ghostSize1 = 0.5; ghostSize2 = 1; backGround = 6
            case 19:
                distance = 30; endTime = 150; ghostSize1 = 1; ghostSize2 = 2; backGround = 0
            case 20:
                distance = 15; endTime = 150; ghostSize1 = 1; ghostSize2 = 2; backGround = 0
            case 21:
                distance = 30; endTime = 150; ghostSize1 = 1; ghostSize2 = 2; backGround = 1
            case 22:
                distance = 60; endTime = 150; ghostSize1 = 0.5; ghostSize2 = 1; backGround = 0
            case 23:
                distance = 90; endTime = 150; ghostSize1 = 0.5; ghostSize2 = 1; backGround = 0
            case 24:
                distance = 60; endTime = 150; ghostSize1 = 0.5; ghostSize2 = 1; backGround = 2
            case 25:
                distance = 30; endTime = 180; ghostSize1 = 1; ghostSize2 = 2; backGround = 0
            case 26:
                distance = 15; endTime = 180; ghostSize1 = 1; ghostSize2 = 2; backGround = 0
            case 27:
                distance = 30; endTime = 180; ghostSize1 = 1; ghostSize2 = 2; backGround = 3
            case 28:
                distance = 60; endTime = 180; ghostSize1 = 0.5; ghostSize2 = 1; backGround = 0
            case 29:
                distance = 90; endTime = 180; ghostSize1 = 0.5; ghostSize2 = 1; backGround = 0
            case 30:
                distance = 60; endTime = 180; ghostSize1 = 0.5; ghostSize2 = 1; backGround = 4
                
            default:
                distance = 30; endTime = 210; ghostSize1 = 1; ghostSize2 = 2; backGround = 0
            }
            
            print("level:", game.level)
            print("endTime1:", endTime)
            setupScene()
            */
            
           // start = NSDate()
            game.state = .playing
    
           
            showSplash("")
            self.game.gameCenterNode.isHidden = true
            self.game.AdsFreeNode.isHidden = true
/*
            if (self.googleInterS.isReady){
                self.googleInterS.presentFromRootViewController(self)
            }
 */
            return
        }
        
        let touch = touches.first
        let location = touch!.location(in: scnView)
        let hitResults = scnView.hitTest(location, options: nil)
        
        if hitResults.count > 0 {
            
            let result: SCNHitTestResult! = hitResults[0]
            if result.node.name == "g1"   {
                //game.playSound(scnScene.rootNode, name: "ExplodeGood")
               // if motionManager.deviceMotionAvailable {
                   // self.motionManager.startDeviceMotionUpdates()
                   // let data = motionManager.deviceMotion
                    //print("Acceleration: \(data!.userAcceleration.x)")
                    //geometryNode.physicsBody!.applyForce(SCNVector3(10 * CGFloat(data!.userAcceleration.x), 0,-0.05), atPosition: SCNVector3(0,0,0), impulse:true)
                //}
                
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
    
    
    
  

        
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        // Set Contact Node
        var contactNode:SCNNode!
        if contact.nodeA.name == "g1" {
            contactNode = contact.nodeB
        } else {
            contactNode = contact.nodeA
        }
        if contactNode.physicsBody?.categoryBitMask == CollisionCategoryLantern {
            //contactNode.hidden = true
            game.playSound(scnScene.rootNode, name: "Sliding-Sound")
            game.playSound(scnScene.rootNode, name: "windBell")
        }
        if contactNode.physicsBody?.categoryBitMask == CollisionCategoryStone {
            //contactNode.hidden = true
            game.playSound(scnScene.rootNode, name: "chinese")
            game.playSound(scnScene.rootNode, name: "windBell")
        }

        if contactNode.physicsBody?.categoryBitMask == CollisionCategoryTarget0 {
        //backgroundMusicPlayer.stop()
          playBackgroundMusic("GeometryFighter.scnassets/Sounds/MulberryBush.m4a")
            //playBackgroundMusic("GeometryFighter.scnassets/Sounds/bensound-happyrock.mp3")
            game.playSound(scnScene.rootNode, name: "windBell")
            game.playSound(scnScene.rootNode, name: "foghorn")
        //contactNode.hidden = true
            if target  == 3 {
                let fireworkNode = SCNNode()
                fireworkNode.position = SCNVector3(0, 20, 0)
               let firework = SCNParticleSystem(named: "firework.scnp", inDirectory: nil)!
             scnScene.rootNode.addChildNode(fireworkNode)
               fireworkNode.addParticleSystem(firework)
                scnView.pointOfView = FrontcameraNode
               let turn1 = SCNAction.rotate(by: CGFloat(M_PI/2), around: SCNVector3Make(0, 1, 0), duration: 8)
          self.cameraOrbitNode.runAction(turn1)
                //game.playSound(scnScene.rootNode, name: "windBell")
               // backgroundMusicPlayer.stop()
                playBackgroundMusic("GeometryFighter.scnassets/Sounds/bensound-happyrock.mp3")
            
               target = 4
            }
            
        } else if contactNode.physicsBody?.categoryBitMask == CollisionCategoryTarget1&&target==0 {
            
            game.playSound(scnScene.rootNode, name: "foghorn")
            game.playSound(scnScene.rootNode, name: "windBell")
            self.geometryNode.transform = self.geometryNode.presentation.transform
            self.geometryNode.eulerAngles.y = Float(M_PI/2)
           // spawnShape11()
            
            
            
            target = 1
            
        }else if contactNode.physicsBody?.categoryBitMask == CollisionCategoryTarget2&&target==1 {
           // contactNode.hidden = true
            game.playSound(scnScene.rootNode, name: "foghorn")
            game.playSound(scnScene.rootNode, name: "windBell")
            self.geometryNode.transform = self.geometryNode.presentation.transform
            self.geometryNode.eulerAngles.y = Float(M_PI)
            target = 2
        }else if contactNode.physicsBody?.categoryBitMask == CollisionCategoryTarget3&&target==2 {
           // contactNode.hidden = true
            game.playSound(scnScene.rootNode, name: "foghorn")
            game.playSound(scnScene.rootNode, name: "windBell")
            self.geometryNode.transform = self.geometryNode.presentation.transform
            self.geometryNode.eulerAngles.y = Float(3*M_PI/2)
            target = 3
            plates[0].isHidden = false
        }
       
    }
    
 func setupNodes() {
    
        // Setup Ball Node
      //  ballNode = scnScene.rootNode.childNode(withName: "p0", recursively: true)!
       // ballNode.physicsBody?.contactTestBitMask = CollisionCategoryStone
    }
    
    
}



extension GameViewController: SCNSceneRendererDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time:
        TimeInterval) {
        
        updateScene()
        //spawnShape1()
       // handleGoodCollision();

      }
}

/*
extension GameViewController: SCNPhysicsContactDelegate {
   
   /* optional public func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact)
    optional public func physicsWorld(world: SCNPhysicsWorld, didUpdateContact contact: SCNPhysicsContact)
    optional public func physicsWorld(world: SCNPhysicsWorld, didEndContact contact: SCNPhysicsContact)
   */
    
    
      func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
        
        // Set Contact Node
        var contactNode:SCNNode!
        if contact.nodeA.name == "g1" {
            contactNode = contact.nodeB
        } else {
            contactNode = contact.nodeA
        }
        if contactNode.physicsBody?.categoryBitMask == CollisionCategoryLantern {
            contactNode.hidden = true
            game.playSound(scnScene.rootNode, name: "ExplodeGood")
        }

        // Contact with Pearls
       /* if contactNode.physicsBody?.categoryBitMask == CollisionCategoryPearl {
            contactNode.isHidden = true
            contactNode.runAction(SCNAction.waitForDurationThenRunBlock(30) { (node:SCNNode!) -> Void in
                node.isHidden = false
                })
        }
        */
        // Contact with Pillars & Crates go bump in the night
       // if contactNode.physicsBody?.categoryBitMask == CollisionCategoryPillar ||
        //    contactNode.physicsBody?.categoryBitMask == CollisionCategoryCrate {
        //}
    }
}
*/

