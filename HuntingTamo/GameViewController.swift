//
//  GameViewController.swift
//  HuntingTamo
//
//  Created by 鈴木 義 on 2015/06/21.
//  Copyright (c) 2015年 Tadashi.S. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //シーンの作成
        let scene = PrologueScene()
        //View ControllerのViewをSKView型として取り出す
        let view = self.view as! SKView
        //シーンのサイズをビューに合わせる
        scene.size = view.frame.size
        scene.scaleMode = .AspectFill
        //ビュー上にシーンを表示
        view.presentScene(scene)
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.AllButUpsideDown
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
