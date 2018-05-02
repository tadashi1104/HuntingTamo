//
//  TitleScene.swift
//  HuntingTamo
//
//  Created by 鈴木 義 on 2015/06/26.
//  Copyright (c) 2015年 Tadashi.S. All rights reserved.
//

import Foundation
import SceneKit
import AVFoundation
import iAd

class TitleScene: UIViewController {
    
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
    
    var button1 = UIButton()
    var button2 = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //シーンの初期化
        initScene()
        //カメラの配置
        setCamera()
        //タイトルの配置
        setTitle()
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
    
    func setTitle() {
        let myGreen = SCNMaterial()
        myGreen.diffuse.contents = UIColor.greenColor()
        let myRed = SCNMaterial()
        myRed.diffuse.contents = UIColor.redColor()
        
        let titleHunting = SCNText(string: "Hunting", extrusionDepth: 2)
        titleHunting.font = UIFont(name: "Zapfino", size: 16)
        titleHunting.materials = [myGreen,myRed,myRed]
        let titleHuntingNode = SCNNode()
        titleHuntingNode.geometry = titleHunting
        //0は真ん中、x:+値は右、-値は左。y:+値は上、-値は下。z:+値は手前、-値は奥
        titleHuntingNode.position = SCNVector3(x: 20, y: -20, z: -500)
        titleHuntingNode.orientation = SCNQuaternion(x: 0.1, y: 0, z: 0.5, w: 0)
    
        let fstMove1 = SCNAction.moveTo(SCNVector3(x: 20, y: -20, z: 15), duration: 1.0)
        let scdMove1 = SCNAction.moveTo(SCNVector3(x: 20, y: -20, z: 8), duration: 0.1)
        titleHuntingNode.runAction(SCNAction.sequence([fstMove1,scdMove1]))
        
        self.sceneView.scene?.rootNode.addChildNode(titleHuntingNode)
        
        let titleTamo = SCNText(string: "Tamo", extrusionDepth: 2)
        titleTamo.font = UIFont(name: "Zapfino", size: 24)
        titleTamo.materials = [myGreen,myRed,myRed]
        let titleTamoNode = SCNNode()
        titleTamoNode.geometry = titleTamo
        //0は真ん中、x:+値は右、-値は左。y:+値は上、-値は下。z:+値は手前、-値は奥
        titleTamoNode.position = SCNVector3(x: 35, y: -25, z: -500)
        titleTamoNode.orientation = SCNQuaternion(x: 0.1, y: 0, z: 0.5, w: 0)
        
        let wait = SCNAction.waitForDuration(0.5)
        let fstMove2 = SCNAction.moveTo(SCNVector3(x: 35, y: -55, z: 15), duration: 1.0)
        let scdMove2 = SCNAction.moveTo(SCNVector3(x: 35, y: -55, z: 5), duration: 0.1)
        titleTamoNode.runAction(SCNAction.sequence([wait,fstMove2,scdMove2]))
        
        self.sceneView.scene?.rootNode.addChildNode(titleTamoNode)
    }
    
    func setCamera(){
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zFar = 1000
        cameraNode.camera?.zNear = 10
        cameraNode.name = "camera"
        self.sceneView.scene?.rootNode.addChildNode(cameraNode)
        //x:+が右、-が左、y:+が上、-が下、z:+値が後ろへ、-値が前へ(差がzFar以上になると見えなくなる)
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 60)
        cameraNode.orientation = SCNQuaternion(x: -0.26, y: -0.32, z: 0, w: 0.91)
    }
    
    func setButton() {
        //アーケードボタンの配置
        let arcadeButton = commFunc.setUIButton("Arcade", textColor: UIColor.greenColor(), rect: CGRectMake(0, 0, 200, 60), point: CGPoint(x:self.view.bounds.width * 0.5, y:self.view.bounds.height * 0.72), fontName: "Zapfino", fontSize: 30, target: self, action: "touchArcade", tag: 1)
        arcadeButton.setTitleShadowColor(UIColor.grayColor(), forState: .Normal)
        arcadeButton.titleLabel?.shadowOffset = CGSizeMake( 3, 3 )
        self.view?.addSubview(arcadeButton)
        self.button1 = arcadeButton
        //全クリアしてる時だけスコアアタックボタンを配置（0:してない、1:してる）
        let allComplete:Int = defaults.integerForKey("GAME_COMP")
        if allComplete == 1 {
            //スコアアタックボタンの配置
            let scoreAtackButton = commFunc.setUIButton("Score Atack", textColor: UIColor.redColor(), rect: CGRectMake(0, 0, 250, 60), point: CGPoint(x:self.view.bounds.width * 0.5, y:self.view.bounds.height * 0.82), fontName: "Zapfino", fontSize: 30, target: self, action: "touchScoreAtack", tag: 1)
            scoreAtackButton.setTitleShadowColor(UIColor.grayColor(), forState: .Normal)
            scoreAtackButton.titleLabel?.shadowOffset = CGSizeMake( 3, 3 )
            self.view?.addSubview(scoreAtackButton)
            self.button2 = scoreAtackButton
        }
    }
    
    func touchArcade() {
        //解放
        mySession = nil
        myDevice = nil
        sceneView.removeFromSuperview()
        self.removeFromParentViewController()
        sleep(1)
        // 遷移するViewを定義する.
        let mySecondViewController: UIViewController = SelectStageScene()
        // アニメーションを設定する.
        mySecondViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        // Viewの移動する.
        self.presentViewController(mySecondViewController, animated: true, completion: nil)
    }
    
    func touchScoreAtack() {
        //解放
        mySession = nil
        myDevice = nil
        sceneView.removeFromSuperview()
        self.removeFromParentViewController()
        sleep(1)
        // 遷移するViewを定義する.
        let mySecondViewController: UIViewController = GameScoreAttack()
        // アニメーションを設定する.
        mySecondViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        // Viewの移動する.
        self.presentViewController(mySecondViewController, animated: true, completion: nil)
    }
    
}