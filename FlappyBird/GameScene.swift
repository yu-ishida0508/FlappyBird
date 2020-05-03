//
//  GameScene.swift
//  FlappyBird
//
//  Created by 石田悠 on 2020/05/01.
//  Copyright © 2020 yuu.ishida. All rights reserved.
//
// MARK: - 言葉
//スプライト:「キャラ、地面などの画像を表示するためのノード」
//ノード(SKNodeクラス):「シーン上の画面を構成する要素。SKNodeクラスを継承したクラスがじUI部品となる」
//                    ex)画面を描画する「SKSpriteNodeクラス」など

// MARK: -
//import UIKit ：削除
import SpriteKit //2Dゲーム用フレームワーク

class GameScene: SKScene {
    
    var scrollNode:SKNode!  //scrollNodeはSKNodeを継承した「UI部品」
    var wallNode:SKNode!    //wallNodeはSKNodeを継承した「UI部品」
// MARK: - ゲーム画面表示時に呼び出されるメソッド
    
    // SKView上にシーンが表示されたときに呼ばれるメソッド
    override func didMove(to view: SKView) {
        // 背景色を設定
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        // スクロールするスプライトの親ノード(SKNode)作成 <目的：GameOver時におけるスクロール一括停止>
        //親ノードが停止すれば子ノードも全て停止する
        scrollNode = SKNode()
        addChild(scrollNode)  //addChild(_:)メソッドでスプライトを画面に表示
        
        // 壁用のノード
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        
        // 各種スプライトを生成する処理をメソッドに分割
        setupGround()
        setupCloud()
        setupWall()
    }

// MARK: -　『地面』 ①地面の読み込み　②スプライト作成　③スプライトの表示位置指定
        
    func setupGround(){
    // ①　地面の画像を読み込む <SKTexture:SpriteKitで扱う画像の扱うクラス>
        let groundTexture = SKTexture(imageNamed: "ground") //@2,@3、拡張子不要（デバイス自動判定される）
        
        
        //.nearestの前の省略はfilteringModeの継承元「SKTextureFilteringMode」が省略
        //.nearestは「画質:低、処理速度:早」設定。.linearで「画質:高、処理速度:遅」
        groundTexture.filteringMode = .nearest
        // 必要な枚数を計算 <+2 は (地面の個数) > (画面サイズの横幅) にし、端が切れないようにしている>
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2
        
        // スクロールするアクションを作成
        // 左方向に画像一枚分スクロールさせるアクションを作成
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
        // 元の位置に戻すアクションを作成
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
        
        // 左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround,resetGround]))
        
// MARK: -
    // ②　テクスチャを指定してスプライト(画像を表示するもの)を作成する
        let groundSprite = SKSpriteNode(texture: groundTexture)
        
        // groundのスプライトを配置する
        for i in 0..<needNumber {
            let sprite = SKSpriteNode(texture: groundTexture)
            
// MARK: -
    // ③　スプライトの表示する位置を指定する　<SpriteKit: 左下が原点(0,0)>
        //positionで指定するのはNODE(画像)の中心位置
        //NODE(画像)の中心位置は、原点(0,0)からNODEサイズ（縦(仮)・横）の半分という意味
        sprite.position = CGPoint(
            x: groundTexture.size().width / 2 + groundTexture.size().width * CGFloat(i),
            y: groundTexture.size().height / 2
        )
        
        // スプライトにアクションを設定する
            sprite.run(repeatScrollGround)
            
        // シーンにスプライトを追加(表示)する
        addChild(groundSprite)
            
        }
        
    }
// MARK: -　『雲』 ①雲の読み込み　②スプライト作成　③スプライトの表示位置指定
    func setupCloud() {
    // 雲の画像を読み込む
            let cloudTexture = SKTexture(imageNamed: "cloud")
            cloudTexture.filteringMode = .nearest

            // 必要な枚数を計算
            let needCloudNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2

            // スクロールするアクションを作成
            // 左方向に画像一枚分スクロールさせるアクションを作成
            let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width , y: 0, duration: 20)

            // 元の位置に戻すアクションを作成
            let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0)

            // 左にスクロール->元の位置->左にスクロールと無限に繰り返すアクションを作成
            let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))

            // スプライトを配置する
            for i in 0..<needCloudNumber {
                let sprite = SKSpriteNode(texture: cloudTexture)
                sprite.zPosition = -100 // 一番後ろになるようにする

                // スプライトの表示する位置を指定する
                sprite.position = CGPoint(
                    x: cloudTexture.size().width / 2 + cloudTexture.size().width * CGFloat(i),
                    y: self.size.height - cloudTexture.size().height / 2
                )

                // スプライトにアニメーションを設定する
                sprite.run(repeatScrollCloud)

                // スプライトを追加する
                scrollNode.addChild(sprite)
            }
        }

// MARK: -　『壁』 ①壁の読み込み　②スプライト作成　③スプライトの表示位置指定
        func setupWall() {
            // 壁の画像を読み込む
            let wallTexture = SKTexture(imageNamed: "wall")
            wallTexture.filteringMode = .linear

            // 移動する距離を計算
            let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)

            // 画面外まで移動するアクションを作成
            let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration:4)

            // 自身を取り除くアクションを作成
            let removeWall = SKAction.removeFromParent()

            // 2つのアニメーションを順に実行するアクションを作成
            let wallAnimation = SKAction.sequence([moveWall, removeWall])

            // 鳥の画像サイズを取得
            let birdSize = SKTexture(imageNamed: "bird_a").size()

            // 鳥が通り抜ける隙間の長さを鳥のサイズの3倍とする
            let slit_length = birdSize.height * 3

            // 隙間位置の上下の振れ幅を鳥のサイズの3倍とする
            let random_y_range = birdSize.height * 3

            // 下の壁のY軸下限位置(中央位置から下方向の最大振れ幅で下の壁を表示する位置)を計算
            let groundSize = SKTexture(imageNamed: "ground").size()
            let center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
            let under_wall_lowest_y = center_y - slit_length / 2 - wallTexture.size().height / 2 - random_y_range / 2

            // 壁を生成するアクションを作成
            let createWallAnimation = SKAction.run({
                // 壁関連のノードを乗せるノードを作成
                let wall = SKNode()
                wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0)
                wall.zPosition = -50 // 雲より手前、地面より奥

                // 0〜random_y_rangeまでのランダム値を生成
                let random_y = CGFloat.random(in: 0..<random_y_range)
                // Y軸の下限にランダムな値を足して、下の壁のY座標を決定
                let under_wall_y = under_wall_lowest_y + random_y

                // 下側の壁を作成
                let under = SKSpriteNode(texture: wallTexture)
                under.position = CGPoint(x: 0, y: under_wall_y)

                wall.addChild(under)

                // 上側の壁を作成
                let upper = SKSpriteNode(texture: wallTexture)
                upper.position = CGPoint(x: 0, y: under_wall_y + wallTexture.size().height + slit_length)

                wall.addChild(upper)

                wall.run(wallAnimation)

                self.wallNode.addChild(wall)
            })

            // 次の壁作成までの時間待ちのアクションを作成
            let waitAnimation = SKAction.wait(forDuration: 2)

            // 壁を作成->時間待ち->壁を作成を無限に繰り返すアクションを作成
            let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))

            wallNode.run(repeatForeverAnimation)
            }
        }
