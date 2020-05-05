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

//<physicsBodyのビットマスク>
//categoryBitMask:  自分が属するカテゴリ値
//collisionBitMask:  この値とぶつかってくる相手のcategoryBitMaskの値とをAND算出結果が1で衝突する
//contactTestBitMask:  物体と衝突した時に、通知として送る値

// MARK: -
//import UIKit ：削除
import SpriteKit //2Dゲーム用フレームワーク

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    var scrollNode:SKNode!  //scrollNodeは SKNodeを継承した「UI部品」
    var wallNode:SKNode!    //wallNodeは SKNodeを継承した「UI部品」
    var bird:SKSpriteNode!  //birdは SKSpriteNodeを継承した「UI部品」
    var star:SKSpriteNode!  //starは SKSpriteNodeを継承した「UI部品」
    
    // 衝突判定カテゴリー 「<<」はビットをずらし、ビットの位置で
    let birdCategory: UInt32 = 1 << 0       // 0...00001
    let groundCategory: UInt32 = 1 << 1     // 0...00010
    let wallCategory: UInt32 = 1 << 2       // 0...00100
    let scoreCategory: UInt32 = 1 << 3      // 0...01000
    let starCategory: UInt32 = 1 << 4       // 0...10000
      
    // スコア用
    var score = 0
    //現在のスコアとベストスコアを画面上部に設置するラベル
    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    //UserDefaultsクラス...スコアを保存(Realmとは異なる保存方法)するクラス
    let userDefaults:UserDefaults = UserDefaults.standard //キー("BEST")、値を指定して保存
    

// MARK: - touchBegan <画面をタップした時に呼ばれる>
     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //親ノードのスピードが0以上(動いている)
         if scrollNode.speed > 0 {
         // 鳥の速度をゼロにする
        bird.physicsBody?.velocity = CGVector.zero
        
         // 鳥に縦方向の力を与える
         bird.physicsBody?.applyImpulse(CGVector(dx: 4, dy: 15))
     }else if bird.speed == 0 {
         restart()
    }
    }
// MARK: - リスタート処理 <①スコア0 ②鳥位置を初期値 ③壁取り除き、鳥のspeedを1へ>
    func restart() {
           score = 0
           scoreLabelNode.text = "Score:\(score)"  //スコア"0"のラベルを表示
        
           bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
           // 鳥の速度をゼロにする
           bird.physicsBody?.velocity = CGVector.zero
           //鳥のcollisionBitMaskを（groundCategory | wallCategory）に設定
           bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
           bird.zRotation = 0

           wallNode.removeAllChildren()

           bird.speed = 1
           scrollNode.speed = 1
       }
// MARK: - SKPhysicsContactDelegateのメソッド <衝突したときに呼ばれる>
    
    func didBegin(_ contact: SKPhysicsContact) {
        // ゲームオーバーのときは何もしない <壁に衝突すると地面にも必ず衝突するので２度目の処理を行わないようにしている>
        if scrollNode.speed <= 0 {
            //returnは、func didBeginメソッド終了し、呼び出し元に戻る
            return
        }
    // SKPhysicsContactクラスは「bodyA,B」という、SKPhysicsBodyクラスで表されるプロパティを持つ
       //設定したカテゴリーで何と何が衝突したか判定する
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            // スコア用の物体と衝突した　=>スコア +1
            print("ScoreUp")
            score += 1
            scoreLabelNode.text = "Score:\(score)"
            
            // ベストスコア更新か確認する
            var bestScore = userDefaults.integer(forKey: "BEST")
            //ベストスコアと過去のスコアの比較
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "Best Score:\(bestScore)"
                
                //set(_:forKey:)メソッドで「値・キー」指定して保存(この時点で保存されない)
                userDefaults.set(bestScore, forKey: "BEST")
                userDefaults.synchronize() //即座に保存される
            }
            
            
        } else {
            // 壁か地面と衝突した
            print("GameOver")

            // 壁か地面と衝突したのでスクロールを停止させる。親ノード（scrollNode）のspeedを0
            scrollNode.speed = 0 //speedプロパティ: 1=>設定値が反映。 速:1より大きくする。
            
            //collisionBitMaskを地面だけにすることで、壁と衝突しないようにする。
            //目的：衝突を表現させる（鳥を転がす際に、壁はすり抜ける？）
            bird.physicsBody?.collisionBitMask = groundCategory

            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01, duration:1)
            bird.run(roll, completion:{
                //birdのspeedも0にし、完全に停止
                self.bird.speed = 0
            })
        }
    }
// MARK: -  didMove <ゲーム画面表示時に呼び出されるメソッド>
    
    // SKView上にシーンが表示されたときに呼ばれるメソッド
    override func didMove(to view: SKView) {
    
    //物理演算-開始
        // (シーン全体の)　重力を設定
        physicsWorld.gravity = CGVector(dx: -1, dy: -4)
    //物理演算-終了
        
        //physicsWorldは代理人として、GameSceneクラスを呼ぶ
        physicsWorld.contactDelegate = self
        
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
        setupBird()
        setupStar()
        setupScoreLabel()   // スコアラベル初期化用
    }

// MARK: -　『地面』 ①地面の読み込み　②スプライト作成　③スプライトの表示位置指定
        
    func setupGround(){
    // ①　地面の画像を読み込む <SKTexture:SpriteKitで扱う画像の扱うクラス>
        let groundTexture = SKTexture(imageNamed: "ground") //@2,@3、拡張子不要（デバイス自動判定される）
        
        
        //.nearestの前の省略はfilteringModeの継承元「SKTextureFilteringMode」が省略
        //.nearestは「画質:低、処理速度:早」設定。.linearで「画質:高、処理速度:遅」
        groundTexture.filteringMode = .nearest
        // 必要な枚数を計算 < +2 は (地面の個数) > (画面サイズの横幅) にし、端が切れないようにしている>
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
    //物理演算-開始
        // スプライトに物理演算を設定(長方形)する
        sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            
        // 衝突のカテゴリー設定
        //categoryBitMaskプロパティで自身のカテゴリーを設定する
        sprite.physicsBody?.categoryBitMask = groundCategory
            
        // 重力の影響を受けなくなる設定（衝突時に止まる）
        sprite.physicsBody?.isDynamic = false
    //物理演算-終了
            
        // シーンにスプライトを追加(画面に表示)する
          scrollNode.addChild(sprite)
            
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
                sprite.zPosition = -100 // 一番後ろになるようにする zPosition:(x,y,z)のz軸

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
                wall.zPosition = -50 // 雲より手前、地面より奥 zPosition:(x,y,z)のz軸

                // 0〜random_y_rangeまでのランダム値を生成
                let random_y = CGFloat.random(in: 0..<random_y_range)
                // Y軸の下限にランダムな値を足して、下の壁のY座標を決定
                let under_wall_y = under_wall_lowest_y + random_y

                // 下側の壁を作成
                let under = SKSpriteNode(texture: wallTexture)
                under.position = CGPoint(x: 0, y: under_wall_y)
    //物理演算-開始（壁:下側）
                // スプライトに物理演算を設定する
                under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
                
                //categoryBitMaskプロパティで自身のカテゴリーを設定する
                under.physicsBody?.categoryBitMask = self.wallCategory

                // 重力の影響を受けなくなる設定（衝突時に止まる）
                under.physicsBody?.isDynamic = false
    //物理演算-終了（壁:下側）

                wall.addChild(under)

                // 上側の壁を作成
                let upper = SKSpriteNode(texture: wallTexture)
                upper.position = CGPoint(x: 0, y: under_wall_y + wallTexture.size().height + slit_length)
     //物理演算-開始（壁:上側）
                // スプライトに物理演算を設定する
                upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
                
                //categoryBitMaskプロパティで自身のカテゴリーを設定する
                upper.physicsBody?.categoryBitMask = self.wallCategory

                // 重力の影響を受けなくなる設定（衝突時に止まる）
                upper.physicsBody?.isDynamic = false
     //物理演算-終了（壁:上側）

                wall.addChild(upper)

// MARK: -
            // スコアアップ用のノード
                let scoreNode = SKNode()
                scoreNode.position = CGPoint(x: upper.size.width + birdSize.width / 2, y: self.frame.height / 2)
                scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
                // 重力の影響を受けなくなる設定（動かない）
                scoreNode.physicsBody?.isDynamic = false
                 //categoryBitMaskプロパティで自身のカテゴリーを設定する
                scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
                //contactTestBitMaskプロパティで衝突することを判定する相手のカテゴリーを設定
                scoreNode.physicsBody?.contactTestBitMask = self.birdCategory

                wall.addChild(scoreNode)
// MARK: -
                wall.run(wallAnimation)

                self.wallNode.addChild(wall)
            })

            // 次の壁作成までの時間待ちのアクションを作成
            let waitAnimation = SKAction.wait(forDuration: 2)

            // 壁を作成->時間待ち->壁を作成を無限に繰り返すアクションを作成
            let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))

            wallNode.run(repeatForeverAnimation)
            }

// MARK: -　『鳥』 ①鳥の読み込み　②スプライト作成　③スプライトの表示位置指定
    
    func setupBird() {
        // 鳥の画像を2種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear

        // 2種類のテクスチャを交互に変更するアニメーションを作成
        let texturesAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texturesAnimation)

        // スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
    //物理演算-開始
        
        // 物理演算を設定 <半径を指定して円形の物理体を設定>
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        
        // 衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false
        
        // 衝突のカテゴリー設定
        //collisionBitMaskプロパティは当たった時に跳ね返る動作をする相手を設定
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory
    //物理演算-終了
        
        // アニメーションを設定
        bird.run(flap)

        // スプライトを追加する
        addChild(bird)
    }
    // MARK: -　『星』 ①星の読み込み　②スプライト作成　③スプライトの表示位置指定
    
    func setupStar() {
        // 星の画像を2種類読み込む
        let starTextureA = SKTexture(imageNamed: "star_a")
        starTextureA.filteringMode = .linear
        let starTextureB = SKTexture(imageNamed: "star_b")
        starTextureB.filteringMode = .linear

            
        // 2種類のテクスチャを交互に変更するアニメーションを作成
        let texturesAnimation = SKAction.animate(with: [starTextureA, starTextureB], timePerFrame: 0.1)
        let flap = SKAction.repeatForever(texturesAnimation)
        
        //ランダムの係数作成
        let index = CGFloat( (arc4random_uniform(9))) / 10

        // スプライトを作成
        star = SKSpriteNode(texture: starTextureA)
        star.position = CGPoint(x: self.frame.size.width * index, y:self.frame.size.height)

    //物理演算-開始
        // 物理演算を設定 <半径を指定して円形の物理体を設定>
        star.physicsBody = SKPhysicsBody(circleOfRadius: star.size.height / 2)

        // 重力の影響を無視させる
        //star.physicsBody?.affectedByGravity = false
    //物理演算-終了
        
        // アニメーションを設定
        star.run(flap)

        // スプライトを追加する
        self.addChild(star)
        //addChild(star)
}
        
        
        

// MARK: -　『スコア』 ①初期化　②スプライト作成　③スプライトの表示位置指定
    
    func setupScoreLabel() {
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        scoreLabelNode.zPosition = 100 // 一番手前に表示する zPosition:(x,y,z)のz軸
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)

        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        bestScoreLabelNode.zPosition = 100 // 一番手前に表示する　zPosition:(x,y,z)のz軸
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left //テキストの水平位置

        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
    }
    
}
