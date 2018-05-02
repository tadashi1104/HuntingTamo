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

class DiscriptionScene: UIViewController {
    //ゲーム共通クラス
    let commFunc = GameCommonFunction()
    
    let selectStageScene = SelectStageScene()
    
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
    //スタート合図
    let signalLabel: UILabel = UILabel(frame: CGRectMake(0,0,500,100))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //シーンの初期化
        initScene()
        //カメラの配置
        setCamera()
        //ステージ説明
        setStageDescription()
        
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
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        //x:+値だと上向き、-値だと下向き。y:+値だと左向き、-値だと右向き
        cameraNode.rotation = SCNVector4(x: 0, y: 0, z: 0, w: 0)
    }
    
    func setStageDescription() {
        //喜
        settingJ("喜", colorA: UIColor.yellowColor(), colorB: UIColor.orangeColor(), vector3: SCNVector3(x: 0, y: 0, z: -100))
        //説明文の配置
        setDiscription()
        //スタート合図の配置
        setStartSignal()
    }
    
    func settingJ(jash:String, colorA:UIColor, colorB:UIColor, vector3:SCNVector3) {
        //色の設定
        let color1 = SCNMaterial()
        let color2 = SCNMaterial()
        //回転の設定
        let move = SCNAction.rotateToAxisAngle(SCNVector4(x: 1, y: 1, z: 1, w: Float(M_PI * 2)), duration: 3)
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
        stringNode.runAction(SCNAction.repeatActionForever(move))
        sceneView.scene?.rootNode.addChildNode(stringNode)
    }
    
    func setDiscription() {
        for i in 1...15 {
            var position:CGFloat = 30 * CGFloat(i)
            let descriptionLabel: UILabel = UILabel(frame: CGRectMake(0,0,self.view.bounds.size.width,50))
            // Labelに文字を代入.
            descriptionLabel.text =  NSLocalizedString("Description\(i)", comment: "comment")
            // 文字の色を白にする.
            descriptionLabel.textColor = UIColor.redColor()
            // 文字の影の色をグレーにする.
            descriptionLabel.shadowColor = UIColor.grayColor()
            // Textを左寄せにする.
            descriptionLabel.textAlignment = NSTextAlignment.Left
            // 配置する座標を設定する.
            descriptionLabel.layer.position = CGPoint(x: self.view.bounds.size.width * 0.5, y: self.view.bounds.size.height * 0.5 - 250 + position)
            // FontSize
            descriptionLabel.font = UIFont.systemFontOfSize(24.0)
            //中央寄せ
            descriptionLabel.textAlignment = .Center
            //アニメーションの設定
            let delayInterval:Double = Double(1 * i)
            UIView.animateWithDuration(3.0, delay: delayInterval, options: [], animations: {() -> Void in
                descriptionLabel.alpha = 1.0
                }, completion: {(Bool) -> Void in
                    UIView.animateWithDuration(3.0, delay: delayInterval, options: [], animations: {() -> Void in
                        descriptionLabel.alpha = 0.0
                        }, completion: {(Bool) -> Void in
                            //特になし
                    })
            })
            // ViewにLabelを追加.
            self.view.addSubview(descriptionLabel)
            
            position = position - 20
        }
    }
    
    func setStartSignal() {
        // Labelに文字を代入.
        signalLabel.text =  NSLocalizedString("Signal", comment: "comment")
        // 文字の色を白にする.
        signalLabel.textColor = UIColor.redColor()
        // 文字の影の色をグレーにする.
        signalLabel.shadowColor = UIColor.grayColor()
        // Textを左寄せにする.
        signalLabel.textAlignment = NSTextAlignment.Left
        // 配置する座標を設定する.
        signalLabel.layer.position = CGPoint(x: self.view.bounds.size.width * 0.5, y: self.view.bounds.size.height * 0.5)
        // FontSize
        signalLabel.font = UIFont.systemFontOfSize(42.0)
        //中央寄せ
        signalLabel.textAlignment = .Center
        signalLabel.alpha = 0.0
        
        // ViewにLabelを追加.
        self.view.addSubview(signalLabel)
        
        UIView.animateWithDuration(3.0, delay: 5.0, options: [], animations: {() -> Void in
            self.signalLabel.alpha = 0.0
            }, completion: {(Bool) -> Void in
                UIView.animateWithDuration(3.0, delay: 12.0, options: [], animations: {() -> Void in
                    self.signalLabel.alpha = 1.0
                    }, completion: {(Bool) -> Void in
                        self.signalLabel.text = NSLocalizedString("StartSignal", comment: "comment")
                })
        })
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if signalLabel.text == NSLocalizedString("StartSignal", comment: "comment") {
            UIView.animateWithDuration(1.0, delay: 1.0, options: [], animations: {() -> Void in
                self.signalLabel.text = "Go!!"
                }, completion: {(Bool) -> Void in
                    UIView.animateWithDuration(1.0, delay: 1.0, options: [], animations: {() -> Void in
                        self.signalLabel.alpha = 0.0
                        }, completion: {(Bool) -> Void in
                            //解放
                            self.mySession = nil
                            self.myDevice = nil
                            self.sceneView.removeFromSuperview()
                            self.removeFromParentViewController()
                            sleep(1)
                            // 遷移するViewを定義する.
                            let mySecondViewController: UIViewController = GameSceneJ()
                            // Viewの移動する.
                            self.presentViewController(mySecondViewController, animated: false, completion: nil)
                    })
            })
        } else {
            //解放
            mySession = nil
            myDevice = nil
            sceneView.removeFromSuperview()
            self.removeFromParentViewController()
            sleep(1)
            // 遷移するViewを定義する.
            let mySecondViewController: UIViewController = GameSceneJ()
            // Viewの移動する.
            self.presentViewController(mySecondViewController, animated: false, completion: nil)
        }
    }
}