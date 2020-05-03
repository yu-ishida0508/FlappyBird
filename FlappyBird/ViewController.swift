//
//  ViewController.swift
//  FlappyBird
//
//  Created by 石田悠 on 2020/04/30.
//  Copyright © 2020 yuu.ishida. All rights reserved.
//

import UIKit
// MARK: - SpriteKit(フレームワーク設置：iOS 2D向けゲーム用)
import SpriteKit

class ViewController: UIViewController {
// MARK: -
   override func viewDidLoad() {
        super.viewDidLoad()
    
        // SKViewに型を変換する
        let skView = self.view as! SKView

        // FPSを表示する
        skView.showsFPS = true

        // ノードの数を表示する
        skView.showsNodeCount = true

        // ビューと同じサイズでシーンを作成する
        //SKScenem→GameSceneに（ViewController.swiftで使えるように）変更
        let scene = GameScene(size:skView.frame.size)// ←GameSceneクラスに変更

        // ビューにシーンを表示する
        skView.presentScene(scene)
    }
    // ステータスバーを消す --- ここから ---
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    } // --- ここまで追加 ---
}

