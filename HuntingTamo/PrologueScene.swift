//
//  PrologueScene.swift
//  HuntingTamo
//
//  Created by 鈴木 義 on 2015/06/21.
//  Copyright (c) 2015年 Tadashi.S. All rights reserved.
//

import Foundation
import SpriteKit

class PrologueScene: SKScene {
    
    //Tamo構造体
    struct tamoStruct {
        //Playerの画像
        static let tamoImage = ["Tamo_H_1", "Tamo_H_2", "Tamo_H_3", "Tamo_H_4"]
    }
    
    //ゲーム共通クラス
    let commFunc = GameCommonFunction()
    
    //プロローグの数
    let cntPrologue1 = 6
    let cntPrologue2 = 6
    
    //プロローグのシーン数
    let prologueScene = 3
    
    //Tamoノード
    var tamo = SKSpriteNode()
    
    //1番目のシーン用ノード
    var firstNode = SKNode()
    //2番目のシーン用ノード
    var secondNode = SKNode()
    //3番目のシーン用ノード
    var thirdNode = SKNode()
    
    //Nextラベル
    var nextLabel = SKLabelNode()
    
    //現在のシーン
    var nowScene = 1
    
    
    override func didMoveToView(view: SKView) {
        //重力の設定
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        //背景色の設定
        self.backgroundColor = UIColor.greenColor()
        //Tamoの配置
        setTamo()
        //プロローグの配置
        setPrologue()
        //ラベルの配置
        setNextLabel()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.nowScene += 1
        
        if self.nowScene == 2 {
            self.firstNode.removeAllActions()
            self.firstNode.removeAllChildren()
            setSecondScene()
        } else if self.nowScene == 3 {
            self.secondNode.removeAllActions()
            self.secondNode.removeAllChildren()
            setThirdScene()
        } else if self.nowScene == 4 {
            self.removeAllChildren()
            let transition = SKTransition.doorwayWithDuration(1.0)
            let titleScene = TitleScene()
            titleScene.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
            self.view?.window?.rootViewController?.presentViewController(titleScene, animated: true, completion: nil)
        }
    }
    
    //Tamoの配置
    func setTamo() {
        var tamo = SKSpriteNode(imageNamed: "Tamo_H_1")
        //Playerのパラパラアニメーション作成に必要なSKTextureクラスの配列を定義
        var tamoTexture = [SKTexture]()
        //パラパラアニメーションに必要な画像を読み込む
        for imageName in tamoStruct.tamoImage {
            let texture = SKTexture(imageNamed: imageName)
            texture.filteringMode = .Linear
            tamoTexture.append(texture)
        }
        
        //パラパラ漫画のアニメーションを作成
        //第１引数playerTextureはパラパラさせたいSKTextureの配列、第２引数timePerFrameはぱらぱらさせる間隔
        let animation = SKAction.animateWithTextures(tamoTexture, timePerFrame: 0.2)
        let loopAnimation = SKAction.repeatActionForever(animation)
        tamo = SKSpriteNode(texture: tamoTexture[0])
        tamo.runAction(loopAnimation)
        
        //スタート時の位置
        tamo.position = CGPoint(x: self.size.width * 0.5, y: self.size.height)
        
        //上から移動のアニメーション
        let move = SKAction.moveToY(self.size.height * 0.78, duration: 3.0)
        tamo.runAction(move, completion: { () -> Void in
            tamo.removeAllActions()
            tamo.texture = SKTexture(imageNamed: "Tamo_H_1")
        })
        
        self.addChild(tamo)
        self.tamo = tamo
    }
    
    //プロローグの配置
    func setPrologue() {
        //四角の作成
        let square = SKShapeNode(rectOfSize: CGSize(width: self.size.width * 0.95, height: self.size.height * 0.62), cornerRadius: 20.0)
        //四角の位置を指定
        square.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.37)
        //四角の色を指定
        square.fillColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        square.strokeColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        //プロローグ文章の作成
        if self.nowScene == 1 {     //1番目のシーン
            for i in 1...cntPrologue1 {
                let prologue = commFunc.setSKLabel("k8x12", color: UIColor.whiteColor(), fontSize: 21.0, zPosition: 1, point: CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.68 - 45 * CGFloat(i)))
                prologue.alpha = 0.0
                prologue.text = NSLocalizedString("Prologue1_\(i)", comment: "comment")
                let wait = SKAction.waitForDuration(1 * Double(i))
                let animation = SKAction.fadeInWithDuration(1)
                let seq = SKAction.sequence([wait, animation])
                prologue.runAction(seq)
                self.firstNode.addChild(prologue)
            }
            self.firstNode.addChild(square)
            self.addChild(self.firstNode)
        } else if self.nowScene == 3 {      //3番目のシーン
            for i in 1...cntPrologue2 {
                let prologue = commFunc.setSKLabel("k8x12", color: UIColor.whiteColor(), fontSize: 21.0, zPosition: 1, point: CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.68 - 45 * CGFloat(i)))
                prologue.alpha = 0.0
                prologue.text = NSLocalizedString("Prologue2_\(i)", comment: "comment")
                let wait = SKAction.waitForDuration(1.5 * Double(i))
                let animation = SKAction.fadeInWithDuration(1.5)
                let seq = SKAction.sequence([wait, animation])
                prologue.runAction(seq)
                self.thirdNode.addChild(prologue)
            }
            self.thirdNode.addChild(square)
            self.addChild(self.thirdNode)
        }
    }
    
    //ラベルの配置
    func setNextLabel() {
        self.nextLabel = commFunc.setSKLabel("k8x12", color: UIColor.redColor(), fontSize: 24.0, zPosition: 1, point: CGPoint(x:self.size.width - 45, y:6.0))
        self.nextLabel.text = NSLocalizedString("SkipLabel", comment: "skip")
        let fadein = SKAction.fadeAlphaTo(0, duration: 1.0)
        let fadeout = SKAction.fadeAlphaTo(1, duration: 1.0)
        let sequence = SKAction.sequence([fadein, fadeout])
        let loop = SKAction.repeatActionForever(sequence)
        self.nextLabel.runAction(loop)
        self.addChild(self.nextLabel)
    }
    
    //2番目のシーンのセット
    func setSecondScene() {
        
        //Tamoの再表示
        setReTamo()
        
        //Tamo分裂アニメーション
        let moveRight = SKAction.moveToX(self.tamo.position.x + 10, duration: 0.1)
        let moveLeft = SKAction.moveToX(self.tamo.position.x - 20, duration: 0.1)
        let `repeat` = SKAction.repeatAction(SKAction.sequence([moveRight, moveLeft]), count: 10)
        
        self.tamo.runAction(`repeat`, completion: { () -> Void in
            self.tamo.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.78)
            //影を出す
            for i in 1...4 {
                let texture = SKTexture(imageNamed: "Shade")
                let shade = SKSpriteNode(texture: texture)
                shade.zPosition = 1
                shade.position = self.tamo.position
                let move = SKAction.moveTo(CGPoint(x: self.size.width * (CGFloat(i) * 0.2), y: self.size.height * 0.5), duration: 0.1)
                let wait = SKAction.waitForDuration(1)
                let out = SKAction.scaleTo(2.0, duration: 0.1)
                self.secondNode.addChild(shade)
                if i == 1 {
                  self.addChild(self.secondNode)   
                }
                shade.runAction(SKAction.sequence([move, wait, out]), { () -> Void in
                    self.setCrash()
                    shade.removeFromParent()
                })
            }
        })
    }
    
    //Tamoの再表示
    func setReTamo() {
        self.tamo.removeAllActions()
        tamo.texture = SKTexture(imageNamed: "Tamo_H_1")
        self.tamo.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.78)
    }
    
    //画面が割れた画像の配置
    func setCrash() {
        let crashTexture = SKTexture(imageNamed: "Crash")
        let crash = SKSpriteNode(texture: crashTexture)
        crash.size = CGSize(width: self.size.width, height: self.size.height)
        crash.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.5)
        self.addChild(crash)
    }
    
    //3番目のシーンのセット
    func setThirdScene() {
        //Tamoの再表示
        setReTamo()
        //画面が割れた画像の配置
        setCrash()
        //プロローグの配置
        setPrologue()
    }
}