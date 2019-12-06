//
//  ViewController.swift
//  MRTowerDiffence
//
//  Created by 洞井僚太 on 2019/08/24.
//  Copyright © 2019 洞井僚太. All rights reserved.
//　ハートが減らない

import UIKit
import SceneKit
import ARKit
import SpriteKit
import GameplayKit
import AVFoundation
class ViewController: UIViewController, ARSCNViewDelegate,SCNPhysicsContactDelegate{
    var enemies:[SCNNode]=[]
    @IBOutlet var sceneView: ARSCNView!
    let scoreLabel = UILabel()
    var score:Int=0
    var bulletPlayer:AVAudioPlayer!
    var explosionPlayer:AVAudioPlayer!
    var bossHP = 10
    var playerHP = 5
    let gameOverLabel = UILabel()
    let backTitleButton = UIButton()
    let continueButton = UIButton()
 //   var playerHPNode:[UIImage]=[]
    var playerHPView:[UIImageView]=[]
    var enemyHP:[Int] = []
    let aim = UIImage(named:"aim.png")
    let damaged = UIImage(named:"hit.png")
    var bullets:[SCNNode] = []
    let bulletCategory = 0x0000
    let enemyCategory = 0x0100
    let continueCategory = 0x0010
    let bossCategory = 0x0001
    var spawnTimer:Timer!
    var updateTimer:Timer!
    var bossTimer:Timer!
    var warningTimer:Timer!
    var addEnemyDuration = 3.0
    var counter = 0
    var theta = 0.0
    var str:SCNText!
    var textNode:SCNNode!
    let upperWarn = UIImageView(image:UIImage(named:"warn"))
    let lowerWarn = UIImageView(image:UIImage(named: "downwarn"))
    var gameoverNode:SCNNode!
    var continueNode:SCNNode!
    var panelNode:SCNNode!
    let scene = SCNScene(/*)*/named: "art.scnassets/enemy_red_walk2")!
    var bossNode:SCNNode!
    let bulletAudioNode = SCNNode()
    var explosionAudioNodes:[SCNNode] = []
    var alarmAudioPlayer = SCNAudioPlayer(source: SCNAudioSource(named: "Warning-Siren01-3.mp3")!)
    var isGameOver = false
    var isBossAppear = false
    var isRingAlarm = false
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreLabel.text = "score:\(score)"
        scoreLabel.font = UIFont(name: "PixelMplus12-Bold", size: 50)
        scoreLabel.textColor = .white
        scoreLabel.frame = CGRect(x:0,y:0,width:1000,height:100)
        view.addSubview(scoreLabel)
        //aim?.size = CGSize(width: 0.4, height: 0.4)
        let aimView = UIImageView(image: aim)
        aimView.alpha = 0.5
        aimView.frame = CGRect(x: 0, y: 0, width: aim!.size.width/10, height: aim!.size.width/10)
        aimView.center = CGPoint(x:view.frame.width/2,y:view.frame.height/2-10)
        view.addSubview(aimView)
        addHearts()
        str = SCNText(string: "score:\(score)", extrusionDepth: 0)
        str.font = UIFont(name: "PixelMplus12-Bold", size: 5)
        textNode = SCNNode(geometry: str)
        let shown = SCNText(string: "おと：まおうだましい", extrusionDepth: 1)
        shown.font = UIFont(name: "PixelMplus12-Bold", size: 5)
        let shownNode = SCNNode(geometry: shown)
        sceneView.showsStatistics = true
        spawnTimer = Timer.scheduledTimer(withTimeInterval: addEnemyDuration, repeats: true, block: {
            _ in self.addEnemy()
            self.addEnemyDuration -= 0.01
        })
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {_ in self.update()})
        bossTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: {_ in self.bossAppear()})
        let bgmAudioNode = SCNNode()
        let audioSource = SCNAudioSource(named:"bgm.mp3")!
        audioSource.loops = true
        bgmAudioNode.position = SCNVector3(0,-100,0)
        bgmAudioNode.addAudioPlayer(SCNAudioPlayer(source: audioSource))
        sceneView.scene = scene
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.scene.physicsWorld.gravity = SCNVector3(CGFloat(0.0),CGFloat(0.0),CGFloat(0.0))
        textNode.position = SCNVector3(0, 10, -30)
        shownNode.position = SCNVector3(0,20,-30)
     //   sceneView.scene.rootNode.addChildNode(textNode)
     //   sceneView.scene.rootNode.addChildNode(shownNode)
        sceneView.scene.rootNode.addAudioPlayer(SCNAudioPlayer(source: audioSource))
        sceneView.scene.rootNode.addChildNode(bgmAudioNode)
        backTitleButton.frame = CGRect(x:0,y:0,width:view.frame.width/2,height:view.frame.height/10)
        backTitleButton.center = CGPoint(x:view.frame.width/2,y:view.frame.height/2)
        backTitleButton.setTitle("タイトルに戻る", for: .normal)
        backTitleButton.titleLabel!.font = UIFont(name: "PixelMplus12-Bold", size: 20)
        backTitleButton.backgroundColor = .red
        backTitleButton.addTarget(self, action: #selector(backTitle(sender:)), for: .touchUpInside)
        backTitleButton.isEnabled = false
        backTitleButton.isHidden = true
        view.addSubview(backTitleButton)
        continueButton.frame = CGRect(x:0,y:0,width:view.frame.width/2,height:view.frame.height/10)
        continueButton.center = CGPoint(x:view.frame.width/2,y:view.frame.height/2+backTitleButton.frame.height+10)
        continueButton.setTitle("つづける", for: .normal)
        continueButton.titleLabel!.font = UIFont(name: "PixelMplus12-Bold", size: 20)
        continueButton.backgroundColor = .red
        continueButton.isEnabled = false
        continueButton.isHidden = true
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.font = UIFont(name: "PixelMplus12-Bold", size: 80)
        gameOverLabel.frame = CGRect(x:view.frame.width/10,y:view.frame.height/4,width:1000,height:100)
      //  gameOverLabel.center = CGPoint(x:0,y:backTitleButton.frame.minY-100)
        gameOverLabel.textColor = .white
        gameOverLabel.isHidden = true
        view.addSubview(gameOverLabel)
        continueButton.addTarget(self, action: #selector(playAgain(sender:)), for: .touchUpInside)
        view.addSubview(continueButton)
    }
    func addHearts(){
        playerHP = 5
        for i in 0..<5{
            let image = UIImage(named:"heart.png")
            let imageView = UIImageView(image:image)
            imageView.frame = CGRect(x:CGFloat(i)*(image!.size.width/2+10),y:100,width:image!.size.width/2,height:image!.size.height/2)
            view.addSubview(imageView)
            playerHPView.append(imageView)
        }
    }
    func addEnemy(){
        if isGameOver{
            return
        }
        let box:SCNGeometry = SCNBox(width: 4, height: 4, length: 4, chamferRadius: 0)
        let circle:SCNGeometry = SCNSphere(radius: 4)
        let material = SCNMaterial()
        let random =  Int.random(in:1...4)
        var enemy = SCNNode()
        if random == 4{
            enemy.geometry = box
             material.diffuse.contents = UIImage(named:"asteroid\(random)")
             let materialTop = SCNMaterial()
            materialTop.diffuse.contents = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0)
            let materialButtom = SCNMaterial()
            materialButtom.diffuse.contents = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0)
              enemy.geometry?.materials = [material,material,material,material,materialTop,materialButtom]
        }else{
            enemy.geometry = circle
            material.diffuse.contents = UIImage(named:"asteroid\(random)")
                   enemy.geometry?.materials = [material]
        }
        let physicsshape = SCNPhysicsShape(geometry: box, options: nil)

        let theta = Float.random(in:-90...90)
        enemy.physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsshape)
        
         enemy.name = "enemy"
        enemy.physicsBody?.categoryBitMask = enemyCategory
        enemy.physicsBody?.collisionBitMask = bulletCategory
        enemy.physicsBody?.contactTestBitMask = bulletCategory
        enemy.position = SCNVector3Make(100*Float(sin(theta*Float.pi/180)),10*Float.random(in:-10...10),-100*Float(cos(theta*Float.pi/180)))
        enemies.append(enemy)
        if random == 4{
            enemyHP.append(3)
        }else{
            enemyHP.append(1)
        }
        let targetPos = SCNVector3(0,0,0)
        let action = SCNAction.move(to: targetPos, duration: 20)
         let remove = SCNAction.removeFromParentNode()
        if random != 4{
        let rotate = SCNAction.rotateBy(x: CGFloat(1000.0*Float.random(in: 1.0...3.0)), y: CGFloat(1000.0*Float.random(in: 1.0...3.0)), z: CGFloat(1000.0*Float.random(in: 1.0...3.0)), duration: 20)
            enemy.runAction(SCNAction.sequence([SCNAction.group([action,rotate]),remove]))
        }else{
         enemy.runAction(SCNAction.sequence([action,remove]))
        }
        
        sceneView.scene.rootNode.addChildNode(enemy)
        counter += 10
    }
    func gameOver(){
        //let audioSource = SCNAudioSource(named:"Warning-Siren01-3.mp3")!
        let audioSource = SCNAudioSource(named:"Warning.mp3")!
        sceneView.scene.rootNode.removeAudioPlayer(SCNAudioPlayer(source:audioSource))
       // sceneView.scene.rootNode.removeAudioPlayer(alarmAudioPlayer)
        spawnTimer.invalidate()
        backTitleButton.isEnabled = true
        backTitleButton.isHidden = false
        continueButton.isEnabled = true
        continueButton.isHidden = false
        isGameOver = true
        gameOverLabel.isHidden = false
        sceneView.scene.isPaused = true
        isBossAppear = false
        isRingAlarm = false
        upperWarn.layer.removeAllAnimations()
        lowerWarn.layer.removeAllAnimations()
                /* let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
             tapRecognizer.delegate = self
             sceneView.addGestureRecognizer(tapRecognizer)*/
             for i in 0..<enemies.count{
                 enemies[i].removeFromParentNode()
             }
             enemies.removeAll()
             let str = SCNText(string: "GAME OVER", extrusionDepth: 1)
             str.font = UIFont(name: "PixelMplus12-Bold", size: 5)
             gameoverNode = SCNNode(geometry: str)
             gameoverNode.position = SCNVector3Make(0, 0, -30)
             //sceneView.scene.rootNode.addChildNode(gameoverNode)
             let cont = SCNText(string: "もういちど？", extrusionDepth: 1)
             cont.font = UIFont(name: "PixelMplus12-Bold", size: 5)
             continueNode = SCNNode(geometry: cont)
             continueNode.position = SCNVector3Make(0, -10, -30)
             //continueNode.name = "continue"
            // let (min,max) = (continueNode.boundingBox)
         //    let textWidth = max.x-min.x
         //    let textHeight = max.y-min.y
             let textBox = SCNBox(width: 10.0, height: 10.0, length: 5, chamferRadius: 0)
             var material = SCNMaterial()
             material.diffuse.contents = UIColor.brown
             panelNode = SCNNode(geometry: textBox)
             let textPhysicsShape = SCNPhysicsShape(geometry: textBox, options: nil)
             panelNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: textPhysicsShape)
             panelNode.physicsBody?.categoryBitMask = continueCategory
             panelNode.physicsBody?.collisionBitMask = bulletCategory
             panelNode.physicsBody?.contactTestBitMask = bulletCategory
             panelNode.geometry?.materials = [material]
             panelNode.position = SCNVector3Make(0, -10, -40)
             material.diffuse.contents = UIColor.white
             continueNode.geometry?.materials = [material]
             continueNode.physicsBody?.categoryBitMask = continueCategory
             continueNode.physicsBody?.collisionBitMask = bulletCategory
             continueNode.physicsBody?.contactTestBitMask = bulletCategory
          //   sceneView.scene.rootNode.addChildNode(continueNode)
    }
    func update(){
        if isGameOver{
            return
        }
        scoreLabel.text = "score:\(score)"
        startAlarm()
       /* textNode.removeFromParentNode()
        str = SCNText(string: "score:\(score)", extrusionDepth: 1)
        str.font = UIFont(name: "PixelMplus12-Bold", size: 5)
        textNode = SCNNode(geometry: str)
        textNode.position = SCNVector3(0, 10, -30)
        self.sceneView.scene.rootNode.addChildNode(textNode)*/
        if isBossAppear{
          //  print(bossNode.position)

            if bossNode.position.z == 0{
                print("a")
                gameOver()
            }
        }
        if enemies.count>0{
        for i in 0..<enemies.count-1{
            if enemies[i].position.x == 0 && enemies[i].position.z == 0 {
                enemies[i].removeFromParentNode()
                enemies.remove(at: i)
                enemyHP.remove(at: i)
                playerHP -= 1
                playerHPView[playerHPView.count-1].removeFromSuperview()
                playerHPView.remove(at: playerHPView.count-1)
                dameged()
                print(playerHP)
                if playerHP == 0{
                    print(playerHP)
                    gameOver()
                }
                break
            }
        }
        }
    }
    func dameged(){
        let imageView = UIImageView(image:damaged)
        imageView.frame = CGRect(x:0,y:0,width:damaged!.size.width,height:damaged!.size.height)
        imageView.center = CGPoint(x:view.frame.width/2,y:view.frame.height/2-10)
        imageView.alpha = 0.5
        view.addSubview(imageView)
        let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            imageView.removeFromSuperview()
        })
        let audioSource = SCNAudioSource(named:"hit.mp3")!
        audioSource.loops = false
        audioSource.volume = 10.0
        isRingAlarm = false
        upperWarn.layer.removeAllAnimations()
        lowerWarn.layer.removeAllAnimations()
        sceneView.scene.rootNode.addAudioPlayer(SCNAudioPlayer(source:audioSource))
    }
    func startAlarm(){
        if enemies.count>0{
        for i in 0..<enemies.count{
            if sqrt(pow(enemies[i].position.z,2)+pow(enemies[i].position.x,2)) <= 10{
                if isRingAlarm{
                    return
                    }
                
                upperWarn.frame = CGRect(x:0,y:0,width:view.frame.width,height:view.frame.height/15)
                lowerWarn.frame = CGRect(x:0,y:view.frame.height-upperWarn.frame.height,width:view.frame.width,height:view.frame.height)
                upperWarn.alpha = 0.5
                lowerWarn.alpha = 0.5
                view.addSubview(upperWarn)
                view.addSubview(lowerWarn)
                UIView.animate(withDuration: 1.0,
                                   delay: 0.0,
                                   options: [.repeat,.autoreverse],
                                   animations: {
                                        self.upperWarn.alpha = 0.0
                                        self.lowerWarn.alpha = 0.0
                        }, completion: nil)
              /*  warningTimer = Timer.scheduledTimer(withTimeInterval:0.5, repeats: false, block: {_ in
                    upperWarn.removeFromSuperview()
                    lowerWarn.removeFromSuperview()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.view.addSubview(upperWarn)
                        self.view.addSubview(lowerWarn)
                    }
                })*/
                let alarmAudioNode = SCNNode(geometry: SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0))
                     alarmAudioNode.position = SCNVector3(0,-100,0)
                     alarmAudioNode.name = "explosion"
                     let material = SCNMaterial()
                     material.diffuse.contents = UIImage(named:"explosion")
                     alarmAudioNode.geometry?.materials = [material]
                    // let audioSource = SCNAudioSource(named:"Warning-Siren01-3.mp3")!
                    let audioSource = SCNAudioSource(named:"Warning.mp3")!
                     audioSource.loops = false
                    audioSource.volume = 10.0
                  //   let action = SCNAction.scale(to: 2, duration: 2)
                     let audio = SCNAction.playAudio(audioSource, waitForCompletion: false)
                     let remove = SCNAction.removeFromParentNode()
                     alarmAudioNode.runAction(SCNAction.sequence([audio,remove]))
                     sceneView.scene.rootNode.addChildNode(alarmAudioNode)
                     sceneView.scene.rootNode.addAudioPlayer(SCNAudioPlayer(source:audioSource))
               // enemies[i].addAudioPlayer(alarmAudioPlayer)
                isRingAlarm = true
                return
                }
            if i == enemies.count-1{
                //let audioSource = SCNAudioSource(named:"Warning-Siren01-3.mp3")!
                 let audioSource = SCNAudioSource(named:"Warning.mp3")!
                sceneView.scene.rootNode.removeAudioPlayer(SCNAudioPlayer(source:audioSource))
                isRingAlarm = false
                upperWarn.layer.removeAllAnimations()
                lowerWarn.layer.removeAllAnimations()
            }
            }
        }
    }
    func bossAppear(){
        if isBossAppear {
            return
        }
        isBossAppear = true
        bossNode = scene.rootNode.childNode(withName:"material", recursively: true)!
        let body = bossNode.childNode(withName: "body", recursively: false)!
        let physicsshape = SCNPhysicsShape(geometry: body.geometry!, options: nil)
          bossNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsshape)
          let material = SCNMaterial()
          material.diffuse.contents = UIImage(named:"asteroid1")
          bossNode.geometry?.materials = [material]
          bossNode.physicsBody?.categoryBitMask = bossCategory
          bossNode.physicsBody?.collisionBitMask = bulletCategory
          bossNode.physicsBody?.contactTestBitMask = bulletCategory
          bossNode.position = SCNVector3(0,0,-300)
          bossNode.scale = SCNVector3(0.5,0.5,0.5)
          bossNode.rotation = SCNVector4(0, 1, 0, -0.5*Float.pi)
          bossNode.name = "boss"
          let targetPos = SCNVector3(0,0,0)
          let action = SCNAction.move(to: targetPos, duration: 60)

          bossNode.runAction(action)
          bossHP = 10
          sceneView.scene.rootNode.addChildNode(bossNode)
    }
    func resetGame(){
        if enemies.count > 0{
        for i in 0..<enemies.count{
            enemies[i].removeFromParentNode()
        }
    }
        if bullets.count > 0{
        for i in 0..<bullets.count{
            bullets[i].removeFromParentNode()
        }
    }
        enemies.removeAll()
        bullets.removeAll()
        enemyHP.removeAll()
        score = 0
        gameoverNode.removeFromParentNode()
        continueNode.removeFromParentNode()
        isGameOver = false
        updateTimer.invalidate()
     //   bossTimer.invalidate()
        addEnemyDuration = 1.0
        sceneView.scene.isPaused = false
        spawnTimer = Timer.scheduledTimer(withTimeInterval: addEnemyDuration, repeats: true, block: {
            _ in self.addEnemy()
            self.addEnemyDuration -= 0.01
        })
        addHearts()
        backTitleButton.isEnabled = false
        backTitleButton.isHidden = true
        continueButton.isEnabled = false
        continueButton.isHidden = true
        gameOverLabel.isHidden = true
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {_ in self.update()})
      //  bossTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: {_ in self.bossAppear()})
        bossNode.position.z = -300
    }
    @objc func playAgain(sender:UIButton){
        resetGame()
    }
    @objc func backTitle(sender:UIButton){
        sceneView.scene.rootNode.removeAllAudioPlayers()
         self.navigationController?.popViewController(animated: true)
       //  self.dismiss(animated: true, completion: nil)
       // performSegue(withIdentifier: "backTitle", sender: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let camera = sceneView.pointOfView else {
            return
        }
        let sphere:SCNGeometry = SCNSphere(radius: 0.5)
        let physicsshape = SCNPhysicsShape(geometry: sphere, options: nil)
        var bullet = SCNNode(geometry: sphere)
        bullet.physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsshape)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.brown
        bullet.geometry?.materials = [material]
        bullet.position = camera.position
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.collisionBitMask = enemyCategory+bossCategory+continueCategory
        bullet.physicsBody?.contactTestBitMask = enemyCategory+bossCategory+continueCategory
        bullet.name = "bullet"
        
        let audioSource = SCNAudioSource(named:"gun.mp3")
        audioSource?.loops = false
        let targetPos = SCNVector3Make(0,0,-100)
        let target = camera.convertPosition(targetPos, to: nil)
        let action = SCNAction.move(to: target, duration: 1)
        let remove = SCNAction.removeFromParentNode()
        let audio = SCNAction.playAudio(audioSource!, waitForCompletion: false)
        bullet.runAction(SCNAction.sequence([SCNAction.group([action,audio]),remove]))
        sceneView.scene.rootNode.addChildNode(bullet)
        bullets.append(bullet)
    }
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if isGameOver {
            return
        }
        score += 1000
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        var enemy = SCNNode()
        var bullet = SCNNode()
        if nodeA.name == "bullet"{
            enemy = nodeB
            bullet = nodeA
        }else{
            enemy = nodeA
            bullet = nodeB
        }
        for i in 0..<bullets.count{
            if bullets.count <= i{
                break
            }
            if bullet.position.z == bullets[i].position.z{
                bullets[i].removeFromParentNode()
                bullets.remove(at:i)
            }
        }
        let explosionAudioNode = SCNNode()
        explosionAudioNode.geometry = SCNBox(width: 5, height: 5, length: 5, chamferRadius: 0)
        explosionAudioNode.position = enemy.position
        explosionAudioNode.name = "explosion"
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named:"explosion")
        explosionAudioNode.geometry?.materials = [material]
        let audioSource = SCNAudioSource(named:"explosion.mp3")!
        audioSource.loops = false
        let action = SCNAction.scale(to: 2, duration: 2)
   //     let audio = SCNAction.playAudio(audioSource, waitForCompletion: false)
        let remove = SCNAction.removeFromParentNode()
        explosionAudioNode.runAction(SCNAction.sequence([action,remove]))
        sceneView.scene.rootNode.addChildNode(explosionAudioNode)
        explosionAudioNodes.append(explosionAudioNode)
        sceneView.scene.rootNode.addAudioPlayer(SCNAudioPlayer(source: audioSource))
        if enemy.name == "enemy"{
            for i in 0..<enemies.count{
                if enemy.position.x == enemies[i].position.x{
                    enemyHP[i] -= 1
                    if enemyHP[i] <= 0{
                        enemies[i].removeFromParentNode()
                        enemies.remove(at:i)
                        enemyHP.remove(at: i)
                        break
                    }
                }
            }
        }else{
            bossHP -= 1
                       if bossHP <= 0{
                     //   bossNode.position.z = -300
                        bossNode.removeAllActions()
                        isBossAppear = false
                        let defaultPos = SCNVector3(0,0,-300)
                        let back = SCNAction.move(to:defaultPos,duration:1)
                        let targetPos = SCNVector3(0,0,0)
                        let act = SCNAction.move(to: targetPos, duration: 60)
                        bossNode.runAction(SCNAction.sequence([back,act]))
                        bossHP = 10
                        //bossTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: {_ in self.bossAppear()})
                       }
        }
        
        bullet.removeFromParentNode()
    }
   /* @objc func tap(_ tapRecognizer: UITapGestureRecognizer){
        if !isGameOver{
            return
        }
        let touchPoint = tapRecognizer.location(in: self.sceneView)
        let results = self.sceneView.hitTest(touchPoint, options: [SCNHitTestOption.searchMode : SCNHitTestSearchMode.all.rawValue])
        if let result = results.first {
            if result.node.name == "continue"{
                resetGame()
            }
            
        }
    }*/
    // MARK: - ARSCNViewDelegate
    
    
     // Override to create and configure nodes for anchors added to the view's session.
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
       
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
}
