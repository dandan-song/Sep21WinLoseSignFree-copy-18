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
    let targetshowsAdd = false
    var startingTransform: SCNMatrix4!
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
    var count = 0
    var touch = 0
    
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
    var bubbleNode: SCNNode!
    var lantens = [SCNNode]()
    var plates = [SCNNode]()
    var bubbles = [SCNNode]()
    var rootLanterns: SCNNode!
    var geometryNode: SCNNode!
    //var unicornbody: SCNNode!
    var target = 0
    var oldtarget = -1

    
    //var geometry:SCNGeometry!
    var spawnTime = 0.0000
    var game = GameHelper.sharedInstance
    var gc = GCHelper.sharedInstance
   
    var splashNodes:[String:SCNNode] = [:]
    //    let motionManager = CMMotionManager()
    //let motionKit = MotionKit()
    let motionManager = CMMotionManager()
    var start = Date()
    var rightPosition = 0
    //var srart = 0
    var end = Date()
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
    var speed: Float!
    let imagePicker = UIImagePickerController();
    //var r1 = 0
    var playGroundN = 0
    var hasCamera = true
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    var interstitial: GADInterstitial!

    var currentIndex: Int?
    var cars: [SCNNode] = []
    let emptyScene = SCNScene()
    let plainUnicorn = SCNNode()
      var backgroundMusicPlayer = AVAudioPlayer()
     var spawnCount = 1
    
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
                        print("error ", error ?? "some error")
                    }
                }
            )
            
        }
    }
    func interstitialWillPresentScreen(_ ad: GADInterstitial){
        scnView.pause(ad);
        game.state = .paused
    }
    func interstitialDidDismissScreen(_ ad: GADInterstitial){
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
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-4069508576645875/3266542113")
        let InterRequest = GADRequest()
        interstitial.load(InterRequest)
    }
   
    
   /* func adViewDidReceiveAd(_ bannerView: GADBannerView!) {
        print("Banner loaded successfully")
        tableView.tableHeaderView?.frame = bannerView.frame
        tableView.tableHeaderView = bannerView
        
    }*/
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
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
        
        //bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        bannerView?.adUnitID = "ca-app-pub-4069508576645875/6192142251"
        bannerView?.delegate = self
        bannerView?.rootViewController = self
        bannerView?.load(request)
        
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-4069508576645875/3266542113")
        let InterRequest = GADRequest()
        interstitial.load(InterRequest)


        self.speed = 0.3
        setupView()
        setupNodes()
        spawnShape1()
        //spawnShape2()
        
        //currentIndex = 0
        setupCamera()
           setupHUD()
        
        
        setupSounds()
        
        //setupSplash()
        setLanterns()
        //setHale()

        if motionManager.isDeviceMotionAvailable {
            //motionManager.startAccelerometerUpdates()
            motionManager.deviceMotionUpdateInterval = 0.017
            motionManager.startDeviceMotionUpdates(to: OperationQueue())
            {
                motion, error in
                self.cameraNode.orientation = motion!.gaze(atOrientation:
                    UIApplication.shared.statusBarOrientation
                )
                self.rootsplashNode.orientation=self.cameraNode.orientation
                //let pi = M_PI
                var vector: SCNVector3 = SCNVector3(0,0,0)
                // let sensroll:CGFloat = 0.5
                //let senspitch: CGFloat = 0.5
                
                var a: CGFloat = 1
                var b: CGFloat = 1
                var c: CGFloat = 1
                
                b  = CGFloat( motion!.attitude.pitch)-CGFloat.pi*3/8
                
                if self.target == 0{
                    
                    a = 0.5 * CGFloat(motion!.attitude.roll)
                    
                    c  = -0.2+0.2*abs(CGFloat(motion!.attitude.pitch)*4/CGFloat.pi - 1)
                    
                    if  (CGFloat(motion!.attitude.pitch) > CGFloat.pi/2){
                        b = CGFloat.pi*1/8
                        c = 0
                    }
                    if ( motion!.attitude.pitch < 0){
                        b = 0
                        c = 0
                    }
                    if CGFloat(motion!.attitude.roll) > CGFloat.pi/2{
                        a = 0.5 * CGFloat.pi/2
                        
                    }
                    if  CGFloat(motion!.attitude.roll) < CGFloat.pi/2*(-1){
                        a = 0.5 * CGFloat.pi/2*(-1)
                    }
                    
                }
                else if self.target == 1 {
                    
                    a = -0.2+0.2*abs(CGFloat(motion!.attitude.pitch)*4/CGFloat.pi - 1)
                    c = -0.5 * CGFloat(motion!.attitude.roll)
                    
                    if  (CGFloat(motion!.attitude.pitch) > CGFloat.pi/2){
                        a = 0
                        b = CGFloat.pi*1/8
                    }
                    
                    if ( motion!.attitude.pitch < 0){
                        a = 0
                        b = -1*CGFloat.pi*3/8
                    }
                    if CGFloat(motion!.attitude.roll) > CGFloat.pi/2{
                        
                        c = -0.5 * CGFloat.pi/2
                    }
                    if  CGFloat(motion!.attitude.roll) < CGFloat.pi/2*(-1){
                        c = 0.5 * CGFloat.pi/2
                    }
                    
                }else if self.target == 2 {
                    
                    a = -0.5 * CGFloat(motion!.attitude.roll)
                    c = 0.2-0.2*abs(CGFloat(motion!.attitude.pitch)*4/CGFloat.pi - 1)
                    
                    if  (CGFloat(motion!.attitude.pitch) > CGFloat.pi/2){
                        c = 0
                        b = CGFloat.pi*1/8
                    }
                    
                    if ( motion!.attitude.pitch < 0){
                        c = 0
                        b = -1*CGFloat.pi*3/8
                    }
                    if CGFloat(motion!.attitude.roll) > CGFloat.pi/2{
                        
                        a = -0.5 * CGFloat.pi/2
                    }
                    if  CGFloat(motion!.attitude.roll) < CGFloat.pi/2*(-1){
                        a = 0.5 * CGFloat.pi/2
                    }
                    
                    
                }else if self.target == 3 {
                    a = 0.2-0.2*abs(CGFloat(motion!.attitude.pitch)*4/CGFloat.pi - 1)
                    c = 0.5 * CGFloat(motion!.attitude.roll)
                    
                    if  (CGFloat(motion!.attitude.pitch) > CGFloat.pi/2){
                        a = 0
                        b = CGFloat.pi*1/8
                    }
                    
                    if ( motion!.attitude.pitch < 0){
                        a = 0
                        b = -1*CGFloat.pi*3/8
                    }
                    if CGFloat(motion!.attitude.roll) > CGFloat.pi/2{
                        
                        c = 0.5 * CGFloat.pi/2
                    }
                    if  CGFloat(motion!.attitude.roll) < CGFloat.pi/2*(-1){
                        c = -0.5 * CGFloat.pi/2
                    }
                    
                    
                }else if self.target == 4 {
                    vector = SCNVector3(0,0,0)
                }
                //self.geometryNode.physicsBody?.clearAllForces()
                
                let d: CGFloat = sqrt(a*a + b*b + c*c)
                vector = SCNVector3(a/d, b/d, c/d)
                //self.speed = 0.3
                vector = SCNVector3(vector.x * self.speed,vector.y * self.speed, vector.z * self.speed)
                //print("speed,vector=", self.speed, vector, self.game.state)
                if self.game.state == .paused{
                    //e.g. during an interstitial
                    self.geometryNode.physicsBody?.clearAllForces()
                }
                if self.game.state == .playing{
                    self.geometryNode.physicsBody?.applyForce(vector, asImpulse: false)
                }
                
            }
        }
        
    
        
    }
    func setHale(){
        let bubbleS = SCNScene(named: "GeometryFighter.scnassets/Textures/bubble.scn")
         bubbleNode = bubbleS?.rootNode
        bubbleNode?.physicsBody = SCNPhysicsBody(
            type: .dynamic,
            shape: SCNPhysicsShape(geometry: SCNSphere(radius: 1), options: nil))
        bubbleNode?.physicsBody?.contactTestBitMask = CollisionCategoryUnicorn
        bubbleNode?.physicsBody?.categoryBitMask = CollisionCategoryStone
        bubbleNode?.physicsBody?.mass = 0.05
        bubbleNode?.physicsBody?.collisionBitMask = CollisionCategoryUnicorn
        bubbleNode?.physicsBody?.isAffectedByGravity = false
        bubbleNode?.physicsBody?.restitution = 0.9
        
        
        for i in 0...15 {
            for j in 0...3{
                for k in 0...3{
            bubbleNode?.position = SCNVector3(x: 25*Float(j-2), y: 25*Float(k-2), z: -500-1*Float(i*20))
  
            scnScene.rootNode.addChildNode((bubbleNode?.clone())!)
                }
           
            }
            
        }

    }
    func removeHale(){
        
                bubbleNode.removeFromParentNode()
  
    }
    func setRain(){
        
        let rain = SCNParticleSystem(named: "rainDrop.scnp", inDirectory: nil)!
        let rotationMatrix =
            SCNMatrix4MakeRotation(0, 0,
                                   0, 0)
        let translationMatrix =
            SCNMatrix4MakeTranslation(-900, 20,
                                      0)
        let transformMatrix =
            SCNMatrix4Mult(rotationMatrix, translationMatrix)
        // 4
        scnScene.addParticleSystem(rain, transform:
            transformMatrix)
    
    }
    func setLanterns(){
        
        let plate = SCNScene(named: "GeometryFighter.scnassets/Textures/target0.scn")
        let node = plate!.rootNode

        node.physicsBody = SCNPhysicsBody(
            type: .static,
            shape: SCNPhysicsShape(geometry: SCNBox(width: 50, height: 150, length: 50, chamferRadius: 0.0), options: nil))
        
        
        
        for _ in 0...3 {
            plates.append(node.clone());
            // plates.append(node!)
        }
      
        plates[0].physicsBody?.categoryBitMask = CollisionCategoryTarget0
        plates[0].physicsBody?.contactTestBitMask = CollisionCategoryUnicorn
        plates[0].physicsBody?.collisionBitMask = -1
        
        // plates[1].physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        plates[1].position = SCNVector3(0, 0, -1000)
        plates[1].physicsBody?.categoryBitMask = CollisionCategoryTarget1
        plates[1].physicsBody?.contactTestBitMask = CollisionCategoryUnicorn
        plates[1].physicsBody?.collisionBitMask = -1
        // plates[2].physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        plates[2].position = SCNVector3(-975, 390, -1000)
        plates[2].physicsBody?.categoryBitMask = CollisionCategoryTarget2
        plates[2].physicsBody?.contactTestBitMask = CollisionCategoryUnicorn
        plates[2].physicsBody?.collisionBitMask = -1
        plates[3].position = SCNVector3(-1000, 0, -25)
        // plates[3].physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        plates[3].physicsBody?.categoryBitMask = CollisionCategoryTarget3
        plates[3].physicsBody?.contactTestBitMask = CollisionCategoryUnicorn
        plates[3].physicsBody?.collisionBitMask = -1
        
        let stop = SCNParticleSystem(named: "Trail.scnp", inDirectory: nil)!
        
        let rm =
            SCNMatrix4MakeRotation(0, 0,
                                   0, 0)
        var tm =
            SCNMatrix4MakeTranslation(0, 32, 0)
        var tf = SCNMatrix4Mult(rm, tm)
        scnScene.addParticleSystem(stop, transform:tf)

        tm =
            SCNMatrix4MakeTranslation(0, 32, -1000)
        tf = SCNMatrix4Mult(rm, tm)
        scnScene.addParticleSystem(stop, transform:tf)
        
        tm =
            SCNMatrix4MakeTranslation(-975, 422, -1000)
        tf = SCNMatrix4Mult(rm, tm)
        scnScene.addParticleSystem(stop, transform:tf)
        
        tm =
            SCNMatrix4MakeTranslation(-1000, 32, -25)
        tf = SCNMatrix4Mult(rm, tm)
        scnScene.addParticleSystem(stop, transform:tf)
        
         for i in 0...3 {
            

            
           // plates[i].addParticleSystem(trail)
            plates[i].name = "target" + "\(i)"
            
           // print(plates[i].name)
            scnScene.rootNode.addChildNode(plates[i])

        
        }
        
     
                     /*  for i in 15...30 {
  
            bubbles[i].position = SCNVector3(x: -195+Float((i-15)*10), y: Float(-1)*15, z: Float(15))
            scnScene.rootNode.addChildNode(bubbles[i])
        }*/
        
        let lanternScene = SCNScene(named: "GeometryFighter.scnassets/Textures/arrow.scn")
        let lanten = lanternScene!.rootNode
        lanten.scale = SCNVector3Make(4.0, 4.0, 4.0)
        
       /* lanten.name = "lan"
        //lanten.physicsBody = SCNPhysicsBody(type: .Static, shape: nil)
        lanten.physicsBody = SCNPhysicsBody(
            type: .static,
            shape: SCNPhysicsShape(geometry: SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0.0), options: nil))

        lanten.physicsBody?.categoryBitMask = CollisionCategoryLantern
        lanten.physicsBody?.collisionBitMask = -1
        lanten.physicsBody?.contactTestBitMask = CollisionCategoryUnicorn
        */
        let dimondScene = SCNScene(named: "GeometryFighter.scnassets/Textures/arrow1.scn")
        let dimond = dimondScene!.rootNode
        //dimond.eulerAngles = SCNVector3(0,90,0)
        dimond.name = "lan"
        dimond.scale = SCNVector3Make(4.0, 4.0, 4.0)
       /* dimond.physicsBody = SCNPhysicsBody(
            type: .static,
            shape: SCNPhysicsShape(geometry: SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0.0), options: nil))
        dimond.physicsBody?.categoryBitMask = CollisionCategoryLantern
        dimond.physicsBody?.collisionBitMask = -1
        dimond.physicsBody?.contactTestBitMask = CollisionCategoryUnicorn
        */
        let bubbleScene = SCNScene(named: "GeometryFighter.scnassets/Textures/arrow2.scn")
        let bubble = bubbleScene!.rootNode
        bubble.scale = SCNVector3Make(4.0, 4.0, 4.0)
        //bubble.eulerAngles = SCNVector3(0,180,0)
        bubble.name = "lan"
       /* bubble.physicsBody = SCNPhysicsBody(
            type: .static,
            shape: SCNPhysicsShape(geometry: SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0.0), options: nil))
        bubble.physicsBody?.categoryBitMask = CollisionCategoryLantern
        bubble.physicsBody?.collisionBitMask = -1
        bubble.physicsBody?.contactTestBitMask = CollisionCategoryUnicorn
        */
        let ringScene = SCNScene(named: "GeometryFighter.scnassets/Textures/arrow3.scn")
        let ring = ringScene!.rootNode
        ring.scale = SCNVector3Make(4.0, 4.0, 4.0)
    
        //ring.eulerAngles = SCNVector3(0,-90,0)
        ring.name = "lan"
      /*  ring.physicsBody = SCNPhysicsBody(
            type: .static,
            shape: SCNPhysicsShape(geometry: SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0.0), options: nil))
        ring.physicsBody?.categoryBitMask = CollisionCategoryLantern
        ring.physicsBody?.collisionBitMask = -1
        ring.physicsBody?.contactTestBitMask = CollisionCategoryUnicorn
      */  

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
            lantens[i].position = SCNVector3(-20, 0, -25*i)
            scnScene.rootNode.addChildNode(lantens[i])
            //rootLanterns.addChildNode(lantens[i]);
        } /* for (index, element) in lantens.enumerate() {
         element.position = SCNVector3(-5*index, 0, 0)
         print("Item \(index): \(element)")
         }*/
        for i in 40...79 {
            lantens[i].position = SCNVector3(20, 0, -25*(i-40))
            scnScene.rootNode.addChildNode(lantens[i])
        }
        
        for i in 80...119 {
            lantens[i].position = SCNVector3(-10-(i-80)*25, (i-80)*10, -25*40)
            scnScene.rootNode.addChildNode(lantens[i])
        }
        
        for i in 120...159 {
            lantens[i].position = SCNVector3(-985, 10*(160-i), -975 + 25*(i-120))
            scnScene.rootNode.addChildNode(lantens[i])
        }
        
        for i in 160...197 {
            lantens[i].position = SCNVector3(-985+25*(i-159), 0, 0)
                        scnScene.rootNode.addChildNode(lantens[i])
        }
    }
 
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
        
       
        scnView = self.view as! SCNView
       // scnView.frame = self.view.bounds
       // scnView.backgroundColor = UIColor.clearColor();
        scnView.autoenablesDefaultLighting = true
       //scnView.allowsCameraControl = false
        scnView.delegate = self
        //scnView.showsStatistics = true
        //scnView.debugOptions=[SCNDebugOptions.showPhysicsShapes,SCNDebugOptions.showPhysicsFields]
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

        cameraNode.position = SCNVector3(x: 0, y: 18, z: 60)
        setupCarCamera()
        scnView.pointOfView = cameraNode
        
        FrontcameraNode = SCNNode()
        cameraOrbitNode = SCNNode()
        FrontcameraNode.camera = SCNCamera()
        FrontcameraNode.position = SCNVector3(x: 0, y: 18, z: 60)
        cameraOrbitNode.addChildNode(FrontcameraNode)
        geometryNode.addChildNode(cameraOrbitNode)

     
        rootsplashNode = SCNNode()
        rootsplashNode.position = SCNVector3(x: 0, y: 0, z: 10)
        rootsplashNode2 = SCNNode()
        rootsplashNode2.position = SCNVector3(x: 0, y: 0, z: -10)
        
        scnScene.rootNode.addChildNode(rootsplashNode)
        //rootsplashNode.addChildNode(rootsplashNode2)
    }
    
    func spawnShape1() {
        geometryNode = SCNNode()
        let unicornScene = SCNScene(named: "GeometryFighter.scnassets/Textures/witch.scn")
        geometryNode = unicornScene!.rootNode
        geometryNode.position = SCNVector3(x: 0, y: 15, z: -5)
        startingTransform = geometryNode.transform
        let color = UIColor.random()
        //let stars = SCNParticleSystem(named: "spark.scnp", inDirectory: nil)!
        let stars = SCNParticleSystem(named: "spark.scnp", inDirectory: nil)!
        stars.particleColor = color
        //stars.position = SCNVector3(x: 0, y: 5, z: 0)
        
        geometryNode.addParticleSystem(stars)
        
        geometryNode.physicsBody = SCNPhysicsBody(
            type: .dynamic,
           // shape: SCNPhysicsShape(geometry: SCNBox(width: 5, height: 20, length: 5, chamferRadius: 0.0), options: nil)
            shape: SCNPhysicsShape(geometry: SCNSphere(radius: 10), options: nil)
        )
        geometryNode.physicsBody?.isAffectedByGravity = false
        
        //geometryNode.physicsBody!.friction = 0.5
        geometryNode.physicsBody!.angularVelocityFactor = SCNVector3(x: 0, y: 0, z: 0)
        geometryNode.physicsBody?.categoryBitMask = CollisionCategoryUnicorn
        geometryNode.physicsBody?.collisionBitMask = CollisionCategoryStone
        
        // geometryNode.physicsBody?.collisionBitMask = -1
        geometryNode.physicsBody?.contactTestBitMask = CollisionCategoryTarget0|CollisionCategoryTarget1|CollisionCategoryTarget2|CollisionCategoryTarget3|CollisionCategoryStone
        geometryNode.name = "g1"
        //scnScene.rootNode.addChildNode(geometryNode)
     //   geometryNode.addChildNode(unicornbody)
        ghostNode1.addChildNode(geometryNode)
        cars.append(geometryNode)
    }
    
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
        
       
        

        
    }
    

    
    
    func setupHUD() {
        game.hudNode.position = SCNVector3(x: 0.0, y: 4.3, z: 0.0)
        game.gameCenterNode.position = SCNVector3(x: 0, y: 1.0, z: 0.0)
        game.homeNode.position = SCNVector3(x: -2.3, y: 4.2, z: 0.0)
        game.ManuNode.position = SCNVector3(x: -2.3, y: 3.4, z: 0.0)
        game.AdsFreeNode.position = SCNVector3(x: -2.3, y: -4, z: 0.0)
        game.splashNode.position = SCNVector3(x: 0, y: -4, z: 0.0)
        game.peekNode.position = SCNVector3(x: -2.3, y: 5, z: 0.0)
        game.fasterNode.position = SCNVector3(x: -2.3, y: -2, z: 0.0)
        game.slowerNode.position = SCNVector3(x: -2.3, y: -3, z: 0.0)
       

        rootsplashNode2.addChildNode(game.hudNode)
        rootsplashNode2.addChildNode(game.gameCenterNode)
        rootsplashNode2.addChildNode(game.AdsFreeNode)
        rootsplashNode2.addChildNode(game.ManuNode)
        rootsplashNode2.addChildNode(game.homeNode)
        rootsplashNode2.addChildNode(game.splashNode)
        rootsplashNode2.addChildNode(game.peekNode)
        rootsplashNode2.addChildNode(game.fasterNode)
        rootsplashNode2.addChildNode(game.slowerNode)
       cameraNode.addChildNode(rootsplashNode2)
        
        self.game.homeNode.isHidden = true
        self.game.ManuNode.isHidden = true
        self.game.slowerNode.isHidden = true
        self.game.fasterNode.isHidden = true
       // FrontcameraNode.addChildNode(game.hudNode)
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
        
        let plane = SCNPlane(width: 2.5, height: 2.5)
        let splashNode = SCNNode(geometry: plane)
        splashNode.position = SCNVector3(x: 0, y: -7, z: -10)
        splashNode.name = "TapToPlay"
        
        splashNode.geometry?.materials.first?.diffuse.contents = "GeometryFighter.scnassets/Textures/THTPlay.png"
        splashNodes["TapToPlay"] = splashNode
        rootsplashNode2.addChildNode(splashNode)
       /* let trail = SCNParticleSystem(named: "spark.scnp", inDirectory: nil)!
        splashNode.addParticleSystem(trail)*/
        //  return splashNode
        
        
    }
    
    func setupSounds() {
        
       game.loadSound("foghorn",fileNamed: "GeometryFighter.scnassets/Sounds/foghorn.wav")
        game.loadSound("fly",fileNamed: "GeometryFighter.scnassets/Sounds/fly.wav")
       game.loadSound("windBell", fileNamed: "GeometryFighter.scnassets/Sounds/WindBell.m4a")
        game.loadSound("Sliding-Sound",fileNamed: "GeometryFighter.scnassets/Sounds/rain.wav")
        game.loadSound("chinese", fileNamed: "GeometryFighter.scnassets/Sounds/hale.wav")
        game.loadSound("GameOver", fileNamed: "GeometryFighter.scnassets/Sounds/GameOver.wav")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        
        let Touch = touches.first
        let location = Touch!.location(in: scnView)
        let hitResults = scnView.hitTest(location, options: nil)
        
        if hitResults.count > 0 {
            let result: SCNHitTestResult! = hitResults[0]
            // if result.node.name == "pumpkin"   {
            if result.node.name == "pumpkin"   {
                webview = UIWebView(frame : self.view.bounds)
                webview.delegate = self;
                self.view.addSubview(webview)
                let url = URL(string : "itms-apps://itunes.apple.com/us/app/magical-halloween-race/id1173703328?ls=1&mt=8")
                
                let urlRequest = URLRequest(url: url!)
                self.webview.loadRequest(urlRequest)
                self.webview.removeFromSuperview()
                return;
            }else if result.node.name == "remember"{
                self.game.gameCenterNode.isHidden = true
                self.game.ManuNode.isHidden = false
            }else if result.node.name == "home"{
                self.geometryNode.transform = startingTransform;
                /*
                if self.target == 1{
                    self.geometryNode.transform = self.geometryNode.presentation.transform
                    self.geometryNode.eulerAngles.y = Float(0)
                    
                }else if self.target == 2{
                    self.geometryNode.transform = self.geometryNode.presentation.transform
                    self.geometryNode.eulerAngles.y = Float(-1*Double.pi)
                    
                }else if self.target == 3{
                    self.geometryNode.transform = self.geometryNode.presentation.transform
                    self.geometryNode.eulerAngles.y = Float(0)
                }
 */
                self.game.homeNode.isHidden = true
                self.game.gameCenterNode.isHidden = false
                self.game.AdsFreeNode.isHidden = false
                self.game.hudNode.isHidden = false
                self.game.splashNode.isHidden = false
                self.geometryNode.physicsBody?.clearAllForces()
                self.game.ManuNode.isHidden = true
                self.game.fasterNode.isHidden = true
                self.game.slowerNode.isHidden = true
                self.game.peekNode.isHidden = false
                game.state = .tapToPlay
                game.reset()
                
                
                self.scnView.pointOfView = self.cameraNode
                
                self.geometryNode.position = SCNVector3(x: 0, y: 10, z: -5)
                
                
            }else if result.node.name == "manu"{
                self.game.ManuNode.isHidden = true
                self.game.gameCenterNode.isHidden = false
            }else if result.node.name == "TapToPlay"{
                game.state = .playing
                target = 0
                start = Date()
                self.game.gameCenterNode.isHidden = true
                //self.game.AdsFreeNode.isHidden = true
                self.game.hudNode.isHidden = true
                self.game.splashNode.isHidden = true
                self.game.homeNode.isHidden = false
                self.game.ManuNode.isHidden = false
                self.game.peekNode.isHidden = false
                self.game.fasterNode.isHidden = false
                self.game.slowerNode.isHidden = false
            }else if result.node.name == "peek"&&touch == 0{
                
                scnView.pointOfView = FrontcameraNode
                let turn = SCNAction.rotate(by: CGFloat(Double.pi*2), around: SCNVector3Make(0, 1, 0), duration: 10)
                cameraOrbitNode.runAction(turn)
                self.game.peekNode.isHidden = true
                game.playSound(scnScene.rootNode, name: "foghorn")
                //touch = 1
                scnScene.rootNode.runAction(SCNAction.waitForDurationThenRunBlock(10) { (node:SCNNode!) -> Void in
                    self.scnView.pointOfView = self.cameraNode
                    
                })
            }
            else if result.node.name == "faster"{
                self.game.slowerNode.isHidden = false
                if speed < 0.6{
                    speed = speed + 0.1
                }else{
                    self.game.fasterNode.isHidden = true
                }
            }
            else if result.node.name == "slower"{
                self.game.fasterNode.isHidden = false
                if speed > 0.1{
                    speed = speed - 0.1
                }else{
                    self.game.slowerNode.isHidden = true
                }
            }
            
        }
        
        
    }

        
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        // Set Contact Node
        var contactNode:SCNNode!
        
        if contact.nodeA.name == "g1" {
            contactNode = contact.nodeB
        } else {
            contactNode = contact.nodeA
        }
       /* if contactNode.physicsBody?.categoryBitMask == CollisionCategoryLantern {
            //contactNode.hidden = true
            game.playSound(scnScene.rootNode, name: "Sliding-Sound")
           // game.playSound(scnScene.rootNode, name: "windBell")
        }*/
        
        if contactNode.physicsBody?.categoryBitMask == CollisionCategoryStone {
            //contactNode.hidden = true
            game.playSound(scnScene.rootNode, name: "chinese")
            contactNode.physicsBody?.isAffectedByGravity = true
            if count == 0 {
                self.playBackgroundMusic("GeometryFighter.scnassets/Sounds/Thunder.wav")
                //geometryNode.light = SCNLight()
                scnView.autoenablesDefaultLighting = false
                let when = DispatchTime.now() + 3 // change 2 to desired number of seconds
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.scnView.autoenablesDefaultLighting = true
                }
                

                count = 1
            }
           //game.playSound(scnScene.rootNode, name: "windBell")
        }
        

        
        
        if contactNode.physicsBody?.categoryBitMask == CollisionCategoryTarget0&&target == 0 {
            
            if (targetshowsAdd && interstitial.isReady) {
                interstitial.present(fromRootViewController: self)
            }
            self.scnView.pointOfView = self.cameraNode
            setHale()
            setRain()
           start = Date()
            count = 0
            touch = 0
            
            
            playBackgroundMusic("GeometryFighter.scnassets/Sounds/MulberryBush.m4a")
            game.playSound(scnScene.rootNode, name: "windBell")
            game.playSound(scnScene.rootNode, name: "foghorn")
             //self.showSplash("HUD")
            
           // let trail = SCNParticleSystem(named: "Explode.scnp", inDirectory: nil)!
           // plates[0].addParticleSystem(trail)

            
        }
        else if contactNode.physicsBody?.categoryBitMask == CollisionCategoryTarget0&&target == 3 {

            if (targetshowsAdd && interstitial.isReady) {
                interstitial.present(fromRootViewController: self)
            }
            touch = 0
            let trail = SCNParticleSystem(named: "Explode.scnp", inDirectory: nil)!
            plates[0].addParticleSystem(trail)
            let fireworkNode = SCNNode()
            fireworkNode.position = SCNVector3(0, 20, 0)
            let firework = SCNParticleSystem(named: "firework.scnp", inDirectory: nil)!
            scnScene.rootNode.addChildNode(fireworkNode)
            fireworkNode.addParticleSystem(firework)
            playBackgroundMusic("GeometryFighter.scnassets/Sounds/bensound-happyrock.mp3")
            game.lives = 2
            //self.showSplash("HUD")
            self.geometryNode.transform = self.geometryNode.presentation.transform
            self.geometryNode.eulerAngles.y = Float(2*Double.pi)

            scnView.pointOfView = FrontcameraNode
            let turn1 = SCNAction.rotate(by: CGFloat(Float.pi/2), around: SCNVector3Make(0, 1, 0), duration: 2)
        
            let turn3 = SCNAction.rotate(by: CGFloat(Float.pi), around: SCNVector3Make(0, 1, 0), duration: 6)
        
            
            let turn2 = SCNAction.rotate(by: CGFloat(Float.pi/2), around: SCNVector3Make(0, 1, 0), duration: 2)
            let sequence = SCNAction.sequence([turn1, turn3, turn2])
            self.cameraOrbitNode.runAction(sequence)
         
            target = 4
            self.game.state = .tapToPlay
            preloadInterstitial()
            
            
            scnScene.rootNode.runAction(SCNAction.waitForDurationThenRunBlock(15) { (node:SCNNode!) -> Void in
  
               self.game.state = .tapToPlay
                self.scnView.pointOfView = self.cameraNode
                self.game.gameCenterNode.isHidden = false
                self.game.hudNode.isHidden = false
                self.game.splashNode.isHidden = false
                self.game.AdsFreeNode.isHidden = false
                self.geometryNode.position = SCNVector3(x: 0, y: 15, z: -5)
                self.game.peekNode.isHidden = false
                self.game.fasterNode.isHidden = true
                self.game.slowerNode.isHidden = true
                
                self.target = 0
                
                //self.game.lives = 0
                fireworkNode.removeFromParentNode()
            
                if self.interstitial.isReady {
                    self.interstitial.present(fromRootViewController: self)
                } 
                //self.playBackgroundMusic("GeometryFighter.scnassets/Sounds/MulberryBush.m4a")
               
             })

            
            
        } else if contactNode.physicsBody?.categoryBitMask == CollisionCategoryTarget1&&target == 0 {
            
            if (targetshowsAdd && interstitial.isReady) {
                interstitial.present(fromRootViewController: self)
            }
            
            count = 0
            touch = 0
            playBackgroundMusic("GeometryFighter.scnassets/Sounds/MulberryBush.m4a")
            self.game.peekNode.isHidden = false
            if game.state == .playing {
                start = Date()
            }


            let trail = SCNParticleSystem(named: "Explode.scnp", inDirectory: nil)!
            plates[1].addParticleSystem(trail)
            
            game.playSound(scnScene.rootNode, name: "foghorn")
            game.playSound(scnScene.rootNode, name: "windBell")
            self.geometryNode.transform = self.geometryNode.presentation.transform
            self.geometryNode.eulerAngles.y = Float(Double.pi/2)
            // spawnShape11()
            scnView.pointOfView = FrontcameraNode
           // FrontcameraNode.addChildNode(rootsplashNode2)
           //self.showSplash("TapToPlay")
            let turn1 = SCNAction.rotate(by: CGFloat(2*Float.pi), around: SCNVector3Make(0, 1, 0), duration: 8)
            self.cameraOrbitNode.runAction(turn1)
            preloadInterstitial()
            self.cameraOrbitNode.runAction(turn1)
            
            scnScene.rootNode.runAction(SCNAction.waitForDurationThenRunBlock(8) { (node:SCNNode!) -> Void in
                self.scnView.pointOfView = self.cameraNode
            })

            
            target = 1
            
        }else if contactNode.physicsBody?.categoryBitMask == CollisionCategoryTarget2&&target == 1 {
            
            if (targetshowsAdd && interstitial.isReady) {
                interstitial.present(fromRootViewController: self)
            }
            
            self.game.peekNode.isHidden = false
            touch = 0
            start = Date()
            removeHale()
            let trail = SCNParticleSystem(named: "Explode.scnp", inDirectory: nil)!
            plates[2].addParticleSystem(trail)
            // contactNode.hidden = true
            scnView.pointOfView = FrontcameraNode
            let turn1 = SCNAction.rotate(by: CGFloat(2*Float.pi), around: SCNVector3Make(0, 1, 0), duration: 8)
            self.cameraOrbitNode.runAction(turn1)
            scnScene.rootNode.runAction(SCNAction.waitForDurationThenRunBlock(8) { (node:SCNNode!) -> Void in
                self.scnView.pointOfView = self.cameraNode
                 })

            
            
            game.playSound(scnScene.rootNode, name: "foghorn")
            game.playSound(scnScene.rootNode, name: "windBell")
            self.geometryNode.transform = self.geometryNode.presentation.transform
            self.geometryNode.eulerAngles.y = Float(Double.pi)
            preloadInterstitial()
            target = 2
        }else if contactNode.physicsBody?.categoryBitMask == CollisionCategoryTarget3&&target == 2 {
            self.game.peekNode.isHidden = false
            if (targetshowsAdd && interstitial.isReady) {
                interstitial.present(fromRootViewController: self)
            }
            touch = 0
            if count == 0 {
                self.playBackgroundMusic("GeometryFighter.scnassets/Sounds/Thunder.wav")
                //geometryNode.light = SCNLight()
                scnView.autoenablesDefaultLighting = false
                let when = DispatchTime.now() + 3 // change 2 to desired number of seconds
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.scnView.autoenablesDefaultLighting = true
                }
                
                
                count = 1
            }

            start = Date()
            let trail = SCNParticleSystem(named: "Explode.scnp", inDirectory: nil)!
            plates[3].addParticleSystem(trail)
            
            scnView.pointOfView = FrontcameraNode
            let turn1 = SCNAction.rotate(by: CGFloat(2*Float.pi), around: SCNVector3Make(0, 1, 0), duration: 8)
            self.cameraOrbitNode.runAction(turn1)
            
            scnScene.rootNode.runAction(SCNAction.waitForDurationThenRunBlock(8) { (node:SCNNode!) -> Void in
                self.scnView.pointOfView = self.cameraNode
             })

            
            game.playSound(scnScene.rootNode, name: "foghorn")
            game.playSound(scnScene.rootNode, name: "windBell")
            self.geometryNode.transform = self.geometryNode.presentation.transform
            self.geometryNode.eulerAngles.y = Float(3*Double.pi/2)
            target = 3
            plates[0].isHidden = false
            preloadInterstitial()
        }
        /*if self.game.state == .tapToPlay {
            scnView.pointOfView = cameraNode
            setupSplash()
            self.showSplash("TapToPlay")
        }*/
       
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
        
       // updateScene()
        
       // handleGoodCollision();

      }
    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval){
        
        if game.state == .playing {
 
            let end = Date()
            
            let timeInterval: Double = end.timeIntervalSince(start)
            
            
                if Double (timeInterval) > 140{
                    game.lives = 1
                    game.updateHUD()
                    self.geometryNode.physicsBody?.clearAllForces()


                    /*
                    if self.target == 1{
                        self.geometryNode.transform = self.geometryNode.presentation.transform
                        self.geometryNode.eulerAngles.y = Float(0)

                    }else if self.target == 2{
                        self.geometryNode.transform = self.geometryNode.presentation.transform
                        self.geometryNode.eulerAngles.y = Float(-1*Double.pi)
                        
                    }else if self.target == 3{
                        self.geometryNode.transform = self.geometryNode.presentation.transform
                        self.geometryNode.eulerAngles.y = Float(0)
                    }
                    */
                    self.geometryNode.transform = startingTransform
                    //self.showSplash("TapToPlay")
                    //self.setupSplash()
                    self.game.state = .tapToPlay

                    self.scnView.pointOfView = self.cameraNode
                    self.game.gameCenterNode.isHidden = false
                    self.game.hudNode.isHidden = false
                    self.game.AdsFreeNode.isHidden = false
                    self.game.splashNode.isHidden = false
                    self.game.homeNode.isHidden = true
                    self.game.ManuNode.isHidden = true
                    self.game.peekNode.isHidden = false
                    self.game.fasterNode.isHidden = true
                    self.game.slowerNode.isHidden = true
                    self.geometryNode.position = SCNVector3(x: 0, y: 5, z: -5)
                    self.target = 0
                    self.count = 0
                    self.touch = 0
                    if interstitial.isReady {
                        interstitial.present(fromRootViewController: self)
                    }
                    preloadInterstitial()

                }
            }

            
        
//print( "game.lives ", end, geometryNode.position)
           // cleanScene()
    

        game.updateHUD()
    }
   
    
}

