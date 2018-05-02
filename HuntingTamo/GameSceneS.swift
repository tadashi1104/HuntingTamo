//
//  GameSceneS.swift
//  HuntingTamo
//
//  Created by 鈴木 義 on 2015/07/12.
//  Copyright (c) 2015年 Tadashi.S. All rights reserved.
//

import Foundation
import SceneKit
import AVFoundation
import CoreLocation
import CoreMotion

class GameSceneS: UIViewController, CLLocationManagerDelegate, SCNPhysicsContactDelegate, NADInterstitialDelegate {
    //ゲーム共通クラス
    let commFunc = GameCommonFunction()
    
    //NSUserDefaultsを生成
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var myLocationManager:CLLocationManager!
    var myMotionManager:CMMotionManager!
    
    //加速度センサー値取得用
    var gravity:Double = 0
    
    //シーンビュー
    let sceneView = SCNView()
    
    // セッション.
    var mySession : AVCaptureSession!
    // デバイス.
    var myDevice : AVCaptureDevice!
    // 画像のアウトプット.
    var myImageOutput : AVCaptureStillImageOutput!
    
    var fstFlg = true
    var fstHeading = 0.0
    
    // 方位
    var heading:Double = 0
    
    //タイマー
    var timer:NSTimer?
    var timer2:NSTimer?
    //タイムインターバル
    let interval = 2.0
    
    //完了ラベル
    let compLabel = UILabel(frame: CGRectMake(0,0,600,600))
    //GameOrverラベル
    let gameorverLabel = UILabel(frame: CGRectMake(0,0,600,600))
    
    let rem = NSLocalizedString("Remainder", comment: "comment")
    // 残Labelを作成.
    let remLabel: UILabel = UILabel(frame: CGRectMake(0,0,200,50))
    var remTamo = 10
    
    //死亡フラグ
    var flgDeth = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NADInterstitial.sharedInstance().loadAdWithApiKey("82f932a25f7582d24f3734e83c79d219bbb30129", spotId: "415390")
        
        //シーンの初期化
        initScene()
        //カメラの配置
        setCamera()
        //哀
        settingJ("哀", colorA: UIColor.blueColor(), colorB: UIColor.purpleColor(), vector3: SCNVector3(x: 0, y: 0, z: -100))
        //キャラの設定
        setChara()
        //ラベルのセット
        setLabel()
        
        //使用可能かどうかチェック
        if CLLocationManager.headingAvailable() {
            //CLLocationManagerを作成
            myLocationManager = CLLocationManager()
            myLocationManager.delegate = self
            myLocationManager.startUpdatingHeading()
        }
        
        //CMMotionManagerを作成
        myMotionManager = CMMotionManager()
        //使用可能かどうかチェック
        if myMotionManager.deviceMotionAvailable {
            myMotionManager.deviceMotionUpdateInterval = 0.01
            let handler:CMDeviceMotionHandler = {(motion:CMDeviceMotion!, error:NSError!) -> Void in
                // 加速度を設定する
                self.gravity = motion.gravity.z * 90
            }
            //向き更新の取得開始
            myMotionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: handler)
        }
        
        //3,2,1,Go!
        let goLabel = UILabel(frame: CGRectMake(0,0,600,600))
        // Labelに文字を代入.
        goLabel.text = "3"
        // 文字の色を白にする.
        goLabel.textColor = UIColor.blackColor()
        // 文字の影の色をグレーにする.
        goLabel.shadowColor = UIColor.grayColor()
        // Textを左寄せにする.
        goLabel.textAlignment = NSTextAlignment.Center
        // 配置する座標を設定する.
        goLabel.layer.position = CGPoint(x: self.view.bounds.size.width * 0.5, y: self.view.bounds.size.height * 0.5)
        // FontSize
        goLabel.font = UIFont.systemFontOfSize(52.0)
        self.view.addSubview(goLabel)
        //アニメーションの設定
        UIView.animateWithDuration(0.5, delay: 1.0, options: [], animations: {() -> Void in
            goLabel.alpha = 1.0
            }, completion: {(Bool) -> Void in
                UIView.animateWithDuration(0.5, delay: 1.0, options: [], animations: {() -> Void in
                    goLabel.alpha = 0.0
                    }, completion: {(Bool) -> Void in
                        UIView.animateWithDuration(0.5, delay: 1.0, options: [], animations: {() -> Void in
                            goLabel.alpha = 1.0
                            goLabel.text = "2"
                            }, completion: {(Bool) -> Void in
                                UIView.animateWithDuration(0.5, delay: 1.0, options: [], animations: {() -> Void in
                                    goLabel.alpha = 0.0
                                    }, completion: {(Bool) -> Void in
                                        UIView.animateWithDuration(0.5, delay: 1.0, options: [], animations: {() -> Void in
                                            goLabel.alpha = 1.0
                                            goLabel.text = "1"
                                            }, completion: {(Bool) -> Void in
                                                UIView.animateWithDuration(0.5, delay: 1.0, options: [], animations: {() -> Void in
                                                    goLabel.alpha = 0.0
                                                    }, completion: {(Bool) -> Void in
                                                        UIView.animateWithDuration(0.5, delay: 1.0, options: [], animations: {() -> Void in
                                                            goLabel.alpha = 1.0
                                                            goLabel.text = "Go!!"
                                                            }, completion: {(Bool) -> Void in
                                                                goLabel.alpha = 0.0
                                                                self.timerStart()
                                                        })
                                                })
                                        })
                                })
                        })
                })
        })
    }
    
    func timerStart() {
        //タイマーを生成
        self.timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: "createTamo", userInfo: nil, repeats: true)
        //タイマーを生成
        self.timer2 = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "setLife", userInfo: nil, repeats: true)
    }
    
    func timerEnd() {
        //タイマーを破棄
        self.timer?.invalidate()
        self.timer2?.invalidate()
    }
    
    func createTamo() {
        let generator = SCNBox(width: 30.0, height: 40.0, length: 35.0, chamferRadius: 20.0)
        
        let imageRight = SCNMaterial()
        let imageLeft = SCNMaterial()
        let imageTop = SCNMaterial()
        let imageBottom = SCNMaterial()
        let imageFront = SCNMaterial()
        let imageBack = SCNMaterial()
        imageRight.diffuse.contents = UIImage(named: "S_Tamo_Right")
        imageLeft.diffuse.contents = UIImage(named: "S_Tamo_Left")
        imageTop.diffuse.contents = UIImage(named: "S_Tamo_Top")
        imageBottom.diffuse.contents = UIImage(named: "S_Tamo_Bottom")
        imageFront.diffuse.contents = UIImage(named: "S_Tamo_Front")
        imageBack.diffuse.contents = UIImage(named: "S_Tamo_Back")
        
        generator.materials = [imageFront, imageLeft, imageBack, imageRight, imageTop, imageBottom]
        
        let generatorNode = SCNNode()
        generatorNode.geometry = generator
        
        //0は真ん中、x:+値は右、-値は左。y:+値は上、-値は下。z:+値は手前、-値は奥
        var X:Float = 1.0
        var Y:Float = 1.0
        var Z:Float = 1.0
        
        let randIntX = arc4random_uniform(650)
        let randIntY = arc4random_uniform(800)
        let randIntZ = arc4random_uniform(800)
        let aX = arc4random_uniform(2)
        let aY = arc4random_uniform(2)
        
        if aX == 1 {
            X = -Float(randIntX)
        }else{
            X = Float(randIntX)
        }
        if aY == 1 {
            Y = -Float(randIntY)
        }else{
            Y = Float(randIntY)
        }
        Z = -Float(randIntZ)
        
        generatorNode.position = SCNVector3(x: X, y: Y, z: Z - 150)
        generatorNode.name = "Tamo"
        generatorNode.physicsBody = SCNPhysicsBody.dynamicBody()
        generatorNode.physicsBody?.physicsShape = SCNPhysicsShape(node: generatorNode, options: nil)
        generatorNode.physicsBody?.collisionBitMask = 3
        generatorNode.physicsBody?.categoryBitMask = 3
        
        let move = SCNAction.moveTo(SCNVector3(x: 0.0, y: 0.0, z: 0.0), duration: 10)
        let del = SCNAction.fadeOutWithDuration(0.5)
        let lortation = SCNAction.rotateToAxisAngle(SCNVector4(x: 0.0, y: 0.0, z: 0.0, w: Float(M_PI * 2)), duration: 1)
        let seq = SCNAction.sequence([lortation, move, del, SCNAction.removeFromParentNode()])
        
        generatorNode.runAction(seq)
        
        self.sceneView.scene?.rootNode.addChildNode(generatorNode)
    }
    
    //シーンの設定とカメラとの同期
    func initScene() {
        // セッションの作成.
        mySession = AVCaptureSession()
        // デバイス一覧の取得
        let devices = AVCaptureDevice.devices()
        // バックカメラをmyDeviceに格納.
        for device in devices{
            if(device.position == AVCaptureDevicePosition.Back){
                myDevice = device as! AVCaptureDevice
            }
        }
        // バックカメラからVideoInputを取得.
        let videoInput = AVCaptureDeviceInput.deviceInputWithDevice(myDevice, error: nil) as AVCaptureDeviceInput
        // セッションに追加.
        mySession.addInput(videoInput)
        // 出力先を生成.
        myImageOutput = AVCaptureStillImageOutput()
        // セッションに追加.
        mySession.addOutput(myImageOutput)
        // 画像を表示するレイヤーを生成.
        let myVideoLayer : AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer.layerWithSession(mySession) as AVCaptureVideoPreviewLayer
        myVideoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        //セッション開始
        mySession.startRunning()
        
        myVideoLayer.frame = self.view.bounds
        self.view.layer.addSublayer(myVideoLayer)
        
        sceneView.frame = self.view.bounds
        sceneView.backgroundColor = UIColor.clearColor()
        myVideoLayer.frame = self.view.bounds
        let scene = SCNScene()
        sceneView.autoenablesDefaultLighting = true
        //カメラの操作の有無
        sceneView.allowsCameraControl = false
        sceneView.scene = scene
        sceneView.scene?.physicsWorld.contactDelegate = self
        sceneView.autoenablesDefaultLighting = true
        self.view?.addSubview(sceneView)
    }
    
    // 緯度・経度を受信
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if fstFlg == true {
            if newHeading.magneticHeading != 0.0 {
                fstFlg = false
            }
            fstHeading = newHeading.magneticHeading
        }
        if (newHeading.magneticHeading - fstHeading) < 0.0 {
            self.heading = newHeading.magneticHeading - fstHeading + 360
        } else {
            self.heading = newHeading.magneticHeading - fstHeading
        }
        if self.heading >= 180 {
            self.heading = self.heading - 360
        }
        let gra = self.gravity
        if abs(gra) < abs(self.heading) {
            if abs(gra) >= 60 {
                self.sceneView.pointOfView?.rotation.w = Float(abs(gra) * M_PI / 180)
            }else{
                self.sceneView.pointOfView?.rotation.w = Float(abs(self.heading * M_PI / 180))
            }
        }else{
            self.sceneView.pointOfView?.rotation.w = Float(abs(gra) * M_PI / 180)
        }
        if abs(self.heading * M_PI / 180) > 0.0 {
            if self.heading < 0 {
                self.sceneView.pointOfView?.rotation.y = abs(Float(self.heading / 180))
            }else{
                self.sceneView.pointOfView?.rotation.y = -abs(Float(self.heading / 180))
            }
        }else{
            self.sceneView.pointOfView?.rotation.y = 0.0
        }
        if (abs(gra) * M_PI / 180) > 0.0 {
            if self.gravity > 0 {
                self.sceneView.pointOfView?.rotation.x = abs(Float(self.gravity / 180))
            }else{
                self.sceneView.pointOfView?.rotation.x = -abs(Float(self.gravity / 180))
            }
        }else{
            self.sceneView.pointOfView?.rotation.x = 0.0
        }
    }
    
    func setCamera(){
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zFar = 1000
        cameraNode.camera?.zNear = 10
        cameraNode.name = "camera"
        self.sceneView.scene?.rootNode.addChildNode(cameraNode)
        //x:+が右、-が左、y:+が上、-が下、z:+値が後ろへ、-値が前へ(差がzFar以上になると見えなくなる)
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        //x:+値だと上向き、-値だと下向き。y:+値だと左向き、-値だと右向き
        cameraNode.rotation = SCNVector4(x: 0, y: 0, z: 0, w: 0)
    }
    
    func settingJ(jash:String, colorA:UIColor, colorB:UIColor, vector3:SCNVector3) {
        //色の設定
        let color1 = SCNMaterial()
        let color2 = SCNMaterial()
        //喜怒哀楽
        let string = SCNText(string: jash, extrusionDepth: 2)
        string.font = UIFont(name: "Impact", size: 12)
        color1.diffuse.contents = colorA
        color2.diffuse.contents = colorB
        string.materials = [color1,color2,color2]
        let stringNode = SCNNode()
        stringNode.geometry = string
        //0は真ん中、x:+値は右、-値は左。y:+値は上、-値は下。z:+値は手前、-値は奥
        stringNode.position = vector3
        sceneView.scene?.rootNode.addChildNode(stringNode)
    }
    
    func setChara() {
        let generator = SCNBox(width: 20.0, height: 20.0, length: 20.0, chamferRadius: 0.1)
        generator.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)
        //generator.firstMaterial?.diffuse.contents = UIImage(named: "Tamo3")
        let generatorNode = SCNNode()
        generatorNode.geometry = generator
        //0は真ん中、x:+値は右、-値は左。y:+値は上、-値は下。z:+値は手前、-値は奥
        generatorNode.position = SCNVector3(x: 0, y: 0, z: 0)
        generatorNode.name = "Chara"
        generatorNode.physicsBody = SCNPhysicsBody.staticBody()
        generatorNode.physicsBody?.physicsShape = SCNPhysicsShape(node: generatorNode, options: nil)
        generatorNode.physicsBody?.collisionBitMask = 5
        generatorNode.physicsBody?.categoryBitMask = 5
        
        self.sceneView.scene?.rootNode.addChildNode(generatorNode)
    }
    
    func setLabel() {
        //残
        // Labelに文字を代入.
        remLabel.text = "\(rem)Tamo:\(remTamo)"
        // 文字の色を白にする.
        remLabel.textColor = UIColor.blackColor()
        // 文字の影の色をグレーにする.
        remLabel.shadowColor = UIColor.grayColor()
        // Textを左寄せにする.
        remLabel.textAlignment = NSTextAlignment.Left
        // 配置する座標を設定する.
        remLabel.layer.position = CGPoint(x: 120, y: 30)
        // FontSize
        remLabel.font = UIFont.systemFontOfSize(24.0)
        
        // ViewにLabelを追加.
        self.view.addSubview(remLabel)
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
        if remTamo > 0 {
            if (contact.nodeA.name? == "Chara" && contact.nodeB.name? == "Tamo") || (contact.nodeA.name? == "Tamo" && contact.nodeB.name? == "Chara") {
                UIView.animateWithDuration(0.0, animations: { () -> Void in
                    self.sceneView.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.4)
                    }, completion: { finished in
                        self.sceneView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
                })
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                
                flgDeth = true
            }
        }
    }
    
    func setLife() {
        if flgDeth == true {
            gameorver()
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        if flgDeth == true || compLabel.text == NSLocalizedString("Complete", comment: "comment") {
            sleep(1)
            stageChange()
            return
        }
        
        let p = touches.anyObject()!.locationInView(self.sceneView)
        
        if let hitResults = self.sceneView.hitTest(p, options: nil) {
            if hitResults.count > 0 {
                var result:SCNNode?
                result = hitResults.first?.node
                
                if result?.name? == "Tamo"{
                    setBullet(result!.position)
                    remTamo -= 1
                    if remTamo == 0 {
                        completeStage()
                    }else if remTamo > 0 {
                        remLabel.text = "\(rem)Tamo:\(remTamo)"
                    }
                    //パーティクルの作成
                    let particle =  SCNParticleSystem(named: "MyParticleSystem.scnp", inDirectory: "")
                    result!.addParticleSystem(particle)
                    result!.runAction(SCNAction.sequence([
                        SCNAction.fadeOutWithDuration(0.1),
                        SCNAction.removeFromParentNode()
                        ]))
                }
            }else{
                setBullet(SCNVector3(x:Float(self.heading * 20), y:Float(self.gravity * 20), z:-1000))
            }
            
            self.sceneView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        }
    }
    
    func setBullet(position:SCNVector3) {
        let bullet = SCNSphere(radius: 10.0)
        bullet.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
        let bulletNode = SCNNode()
        bulletNode.geometry = bullet
        //0は真ん中、x:+値は右、-値は左。y:+値は上、-値は下。z:+値は手前、-値は奥
        bulletNode.position = SCNVector3(x: 0, y: 0, z: 0)
        bulletNode.name = "bullet"
        
        //アニメーションの作成
        let move = SCNAction.moveTo(position, duration: 0.1)
        let del = SCNAction.fadeOutWithDuration(0)
        let seq = SCNAction.sequence([move, del, SCNAction.removeFromParentNode()])
        bulletNode.runAction(seq)
        
        self.sceneView.scene?.rootNode.addChildNode(bulletNode)
    }
    
    func completeStage() {
        timerEnd()
        
        remLabel.text = "\(rem)Tamo:\(remTamo)"
        
        // Labelに文字を代入.
        compLabel.text = NSLocalizedString("Complete", comment: "comment")
        
        // 文字の色を白にする.
        compLabel.textColor = UIColor.blackColor()
        
        // 文字の影の色をグレーにする.
        compLabel.shadowColor = UIColor.grayColor()
        
        // Textを左寄せにする.
        compLabel.textAlignment = NSTextAlignment.Center
        
        // 配置する座標を設定する.
        compLabel.layer.position = CGPoint(x: self.view.bounds.size.width * 0.5, y: self.view.bounds.size.height * 0.5)
        
        // FontSize
        compLabel.font = UIFont.systemFontOfSize(46.0)
        
        self.view.addSubview(compLabel)
        
        defaults.setObject(1, forKey: "S_COMP")
    }
    
    func gameorver() {
        timerEnd()
        
        self.flgDeth = true
        
        // Labelに文字を代入.
        gameorverLabel.text = "GameOrver..."
        
        // 文字の色を白にする.
        gameorverLabel.textColor = UIColor.blackColor()
        
        // 文字の影の色をグレーにする.
        gameorverLabel.shadowColor = UIColor.grayColor()
        
        // Textを左寄せにする.
        gameorverLabel.textAlignment = NSTextAlignment.Center
        
        // 配置する座標を設定する.
        gameorverLabel.layer.position = CGPoint(x: self.view.bounds.size.width * 0.5, y: self.view.bounds.size.height * 0.5)
        
        // FontSize
        gameorverLabel.font = UIFont.systemFontOfSize(46.0)
        
        self.view.addSubview(gameorverLabel)
    }
    
    func stageChange() {
        //nend広告の表示
        showNend()
        //解放
        myLocationManager = nil
        myMotionManager = nil
        mySession = nil
        myDevice = nil
        sceneView.removeFromSuperview()
        
        var subviews = self.view.subviews
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
        
        self.removeFromParentViewController()
        // 遷移するViewを定義する.
        let mySecondViewController: UIViewController = TitleScene()
        // アニメーションを設定する.
        mySecondViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        // Viewの移動する.
        self.presentViewController(mySecondViewController, animated: true, completion: nil)
    }
    
    func showNend() {
        // SpotIDを指定する場合
        var showResult: NADInterstitialShowResult
        showResult = NADInterstitial.sharedInstance().showAdWithSpotId("415390")
    }
}
