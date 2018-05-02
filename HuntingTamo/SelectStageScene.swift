//
//  SelectStageScene.swift
//  HuntingTamo
//
//  Created by 鈴木 義 on 2015/06/28.
//  Copyright (c) 2015年 Tadashi.S. All rights reserved.
//

import Foundation
import SceneKit
import AVFoundation

class SelectStageScene: UIViewController {
    //ゲーム共通クラス
    let commFunc = GameCommonFunction()
    
    //NSUserDefaultsを生成
    let defaults = NSUserDefaults.standardUserDefaults()
    
    //シーンビュー
    let sceneView = SCNView()
    
    // セッション.
    var mySession : AVCaptureSession!
    // デバイス.
    var myDevice : AVCaptureDevice!
    // 画像のアウトプット.
    var myImageOutput : AVCaptureStillImageOutput!
    
    //喜怒哀楽
    var completeJ:Int?
    var completeA:Int?
    var completeS:Int?
    var completeH:Int?
    var completeAll:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        defaults.setObject(1, forKey: "J_COMP")
//        defaults.setObject(1, forKey: "S_COMP")
//        defaults.setObject(0, forKey: "H_COMP")
//        defaults.setObject(0, forKey: "A_COMP")
        
        completeJ = defaults.integerForKey("J_COMP")
        completeA = defaults.integerForKey("A_COMP")
        completeS = defaults.integerForKey("S_COMP")
        completeH = defaults.integerForKey("H_COMP")
        completeAll = defaults.integerForKey("GAME_COMP")
        
        //シーンの初期化
        initScene()
        //カメラの配置
        setCamera()
        //喜怒哀楽の配置
        setJASH()
        //ボタンの配置
        setButton()
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
        sceneView.allowsCameraControl = true
        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = true
        self.view?.addSubview(sceneView)
    }
    
    func setCamera(){
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zFar = 1000
        cameraNode.camera?.zNear = 10
        cameraNode.name = "camera"
        self.sceneView.scene?.rootNode.addChildNode(cameraNode)
        //x:+が右、-が左、y:+が上、-が下、z:+値が後ろへ、-値が前へ(差がzFar以上になると見えなくなる)
        cameraNode.position = SCNVector3(x: 30, y: 30, z: 15)
        //x:+値だと上向き、-値だと下向き。y:+値だと左向き、-値だと右向き
        cameraNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: -Float(M_PI_4 / 2))
    }
    
    func setJASH() {
        //喜
        settingJASH("喜", complete: self.completeJ!, colorA: UIColor.yellowColor(), colorB: UIColor.orangeColor(), vector3: SCNVector3(x: 0, y: 20, z: -100))
        //怒
        settingJASH("怒", complete: self.completeA!, colorA: UIColor.redColor(), colorB: UIColor.brownColor(), vector3: SCNVector3(x: 17, y: 20, z: -100))
        //哀
        settingJASH("哀", complete: self.completeS!, colorA: UIColor.blueColor(), colorB: UIColor.purpleColor(), vector3: SCNVector3(x: 33, y: 20, z: -100))
        //楽
        settingJASH("楽", complete: self.completeH!, colorA: UIColor.greenColor(), colorB: UIColor.cyanColor(), vector3: SCNVector3(x: 49, y: 20, z: -100))
        
        //愛
        if self.completeA == 1 {
            settingJASH("愛", complete: self.completeAll!, colorA: UIColor(red: 1.0, green: 0.2, blue: 0.4, alpha: 1.0), colorB: UIColor(red: 1.0, green: 0.753, blue: 0.796, alpha: 1.0), vector3: SCNVector3(x: 25, y: 15, z: -70))
        }
    }
    
    func settingJASH(jash:String, complete:Int, colorA:UIColor, colorB:UIColor, vector3:SCNVector3) {
        //色の設定
        let color1 = SCNMaterial()
        let color2 = SCNMaterial()
        //回転の設定
        let move = SCNAction.rotateToAxisAngle(SCNVector4(x: 1, y: 1, z: 1, w: Float(M_PI * 2)), duration: 3)
        //喜怒哀楽
        let string = SCNText(string: jash, extrusionDepth: 2)
        string.font = UIFont(name: "Impact", size: 12)
        if complete == 0 {
            color1.diffuse.contents = UIColor.grayColor()
            color2.diffuse.contents = UIColor.blackColor()
        } else {
            color1.diffuse.contents = colorA
            color2.diffuse.contents = colorB
        }
        string.materials = [color1,color2,color2]
        let stringNode = SCNNode()
        stringNode.geometry = string
        //0は真ん中、x:+値は右、-値は左。y:+値は上、-値は下。z:+値は手前、-値は奥
        stringNode.position = vector3
        stringNode.runAction(SCNAction.repeatActionForever(move))
        sceneView.scene?.rootNode.addChildNode(stringNode)
    }
    
    func setButton() {
        var color = UIColor.blackColor()
        
        //Stage1:喜
        if self.completeJ == 1 {
            color = UIColor.yellowColor()
        } else {
            color = UIColor.blackColor()
        }
        let stage1Button = commFunc.setUIButton("Stage1:喜", textColor: color, rect: CGRectMake(0, 0, 250, 60), point: CGPoint(x:self.view.bounds.width * 0.5, y:self.view.bounds.height * 0.35), fontName: "Zapfino", fontSize: 30, target: self, action: "touchStageJ", tag: 1)
        stage1Button.setTitleShadowColor(UIColor.grayColor(), forState: .Normal)
        stage1Button.titleLabel?.shadowOffset = CGSizeMake( 3, 3 )
        self.view?.addSubview(stage1Button)
        //Stage2:哀
        if self.completeS == 1 {
            color = UIColor.blueColor()
        } else {
            color = UIColor.blackColor()
        }
        if self.completeJ == 1 {
            let stage2Button = commFunc.setUIButton("Stage2:哀", textColor: color, rect: CGRectMake(0, 0, 250, 60), point: CGPoint(x:self.view.bounds.width * 0.5, y:self.view.bounds.height * 0.5), fontName: "Zapfino", fontSize: 30, target: self, action: "touchStageS", tag: 2)
            stage2Button.setTitleShadowColor(UIColor.grayColor(), forState: .Normal)
            stage2Button.titleLabel?.shadowOffset = CGSizeMake( 3, 3 )
            self.view?.addSubview(stage2Button)
        }
        //Stage3:楽
        if self.completeH == 1 {
            color = UIColor.greenColor()
        } else {
            color = UIColor.blackColor()
        }
        if self.completeS == 1 {
            let stage3Button = commFunc.setUIButton("Stage3:楽", textColor: color, rect: CGRectMake(0, 0, 250, 60), point: CGPoint(x:self.view.bounds.width * 0.5, y:self.view.bounds.height * 0.65), fontName: "Zapfino", fontSize: 30, target: self, action: "touchStageH", tag: 3)
            stage3Button.setTitleShadowColor(UIColor.grayColor(), forState: .Normal)
            stage3Button.titleLabel?.shadowOffset = CGSizeMake( 3, 3 )
            self.view?.addSubview(stage3Button)
        }
        //Stage4:怒
        if self.completeA == 1 {
            color = UIColor.redColor()
        } else {
            color = UIColor.blackColor()
        }
        if self.completeH == 1 {
            let stage4Button = commFunc.setUIButton("Stage4:怒", textColor: color, rect: CGRectMake(0, 0, 250, 60), point: CGPoint(x:self.view.bounds.width * 0.5, y:self.view.bounds.height * 0.8), fontName: "Zapfino", fontSize: 30, target: self, action: "touchStageA", tag: 4)
            stage4Button.setTitleShadowColor(UIColor.grayColor(), forState: .Normal)
            stage4Button.titleLabel?.shadowOffset = CGSizeMake( 3, 3 )
            self.view?.addSubview(stage4Button)
        }
        
        
        //Stage5:愛
        if self.completeAll == 1 {
            color = UIColor(red: 1.0, green: 0.2, blue: 0.4, alpha: 1.0)
        } else {
            color = UIColor.blackColor()
        }
        if self.completeA == 1 {
            let stage4Button = commFunc.setUIButton("Stage5:愛", textColor: color, rect: CGRectMake(0, 0, 250, 60), point: CGPoint(x:self.view.bounds.width * 0.5, y:self.view.bounds.height * 0.575), fontName: "Zapfino", fontSize: 38, target: self, action: "touchStageLove", tag: 4)
            stage4Button.setTitleShadowColor(UIColor.grayColor(), forState: .Normal)
            stage4Button.titleLabel?.shadowOffset = CGSizeMake( 3, 3 )
            self.view?.addSubview(stage4Button)
        }
        
        let titleButton = commFunc.setUIButton("Title", textColor: UIColor.blackColor(), rect: CGRectMake(0, 0, 250, 60), point: CGPoint(x:self.view.bounds.width * 0.85, y:self.view.bounds.height * 0.95), fontName: "Zapfino", fontSize: 16, target: self, action: "touchTitle", tag: 5)
        titleButton.setTitleShadowColor(UIColor.grayColor(), forState: .Normal)
        titleButton.titleLabel?.shadowOffset = CGSizeMake( 3, 3 )
        self.view?.addSubview(titleButton)
        
    }
    
    func touchStageJ() {
        //解放
        mySession = nil
        myDevice = nil
        sceneView.removeFromSuperview()
        self.removeFromParentViewController()
        sleep(1)
        // 遷移するViewを定義する.
        let mySecondViewController: UIViewController = DiscriptionScene()
        // アニメーションを設定する.
        mySecondViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        // Viewの移動する.
        self.presentViewController(mySecondViewController, animated: true, completion: nil)
    }
    
    func touchStageS() {
        //解放
        mySession = nil
        myDevice = nil
        sceneView.removeFromSuperview()
        self.removeFromParentViewController()
        sleep(1)
        // 遷移するViewを定義する.
        let mySecondViewController: UIViewController = GameSceneS()
        // アニメーションを設定する.
        mySecondViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        // Viewの移動する.
        self.presentViewController(mySecondViewController, animated: true, completion: nil)
    }
    
    func touchStageH() {
        //解放
        mySession = nil
        myDevice = nil
        sceneView.removeFromSuperview()
        self.removeFromParentViewController()
        sleep(1)
        // 遷移するViewを定義する.
        let mySecondViewController: UIViewController = GameSceneH()
        // アニメーションを設定する.
        mySecondViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        // Viewの移動する.
        self.presentViewController(mySecondViewController, animated: true, completion: nil)
    }
    
    func touchStageA() {
        //解放
        mySession = nil
        myDevice = nil
        sceneView.removeFromSuperview()
        self.removeFromParentViewController()
        sleep(1)
        // 遷移するViewを定義する.
        let mySecondViewController: UIViewController = GameSceneA()
        // アニメーションを設定する.
        mySecondViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        // Viewの移動する.
        self.presentViewController(mySecondViewController, animated: true, completion: nil)
    }
    
    func touchStageLove() {
        //解放
        mySession = nil
        myDevice = nil
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        sleep(1)
        // 遷移するViewを定義する.
        let mySecondViewController: UIViewController = GameSceneLove()
        // アニメーションを設定する.
        mySecondViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        // Viewの移動する.
        self.presentViewController(mySecondViewController, animated: true, completion: nil)
    }
    
    
    func touchTitle() {
        //解放
        mySession = nil
        myDevice = nil
        sceneView.removeFromSuperview()
        self.removeFromParentViewController()
        sleep(1)
        // 遷移するViewを定義する.
        let mySecondViewController: UIViewController = TitleScene()
        // アニメーションを設定する.
        mySecondViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        // Viewの移動する.
        self.presentViewController(mySecondViewController, animated: true, completion: nil)
    }
    
}