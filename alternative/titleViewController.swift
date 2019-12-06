//
//  titleViewController.swift
//  alternative
//
//  Created by 洞井僚太 on 2019/10/14.
//  Copyright © 2019 洞井僚太. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
class titleViewController:UIViewController,AVAudioPlayerDelegate{
    
    let startGame = UIButton()
    let titleImage = UIImageView(image: UIImage(named:"shot"))
    let backImage = UIImageView(image: UIImage(named:"baclgrond"))
    let soundLabel = UILabel()
    let titleLabel = UILabel()
    var audioPlayer: AVAudioPlayer!
    override func viewDidLoad() {
        // 再生する audio ファイルのパスを取得
        let audioPath = Bundle.main.path(forResource: "05 PYS4", ofType:"mp3")!
        let audioUrl = URL(fileURLWithPath: audioPath)
        
        
        // auido を再生するプレイヤーを作成する
        var audioError:NSError?
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl)
        } catch let error as NSError {
            audioError = error
            audioPlayer = nil
        }
        
        // エラーが起きたとき
        if let error = audioError {
            print("Error \(error.localizedDescription)")
        }
        
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        startGame.setTitle("Start!", for: .normal)
        startGame.titleLabel?.font = UIFont(name: "HalogenbyPixelSurplus-Regular", size: 70)
      //  startGame.setTitleColor(.white, for: .normal)
    //    startGame.isHidden = false
       // startGame.backgroundColor = .red
        startGame.frame = CGRect(x:0,y:view.frame.height/3,width:view.frame.width/2,height:view.frame.height/5)
        soundLabel.text = "sounds:まおうだましい"
        soundLabel.font = UIFont(name: "HalogenbyPixelSurplus-Regular", size: 20)
        soundLabel.frame = CGRect(x:0,y:view.frame.height-view.frame.height/5,width:view.frame.width,height:view.frame.height/5)
        soundLabel.textColor = .white
        titleLabel.text = "AR-Shooting"
        titleLabel.font = UIFont(name: "HalogenbyPixelSurplus-Regular", size: 40)
        titleLabel.frame = CGRect(x:view.frame.width/2-50,y:0,width:view.frame.width,height:view.frame.height/5)
        titleLabel.textColor = .white
        titleImage.frame = CGRect(x:0,y:0,width:view.frame.width,height:view.frame.height)
        backImage.frame = CGRect(x:0,y:0,width:view.frame.width,height:view.frame.height)
        //view.sendSubviewToBack(titleImage)
        startGame.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
        view.addSubview(backImage)
        view.addSubview(titleImage)
        view.addSubview(soundLabel)
        view.addSubview(titleLabel)
        view.addSubview(startGame)
    }
    @objc func tapped(_ sender:UIButton){
        audioPlayer.stop()
        performSegue(withIdentifier: "toPlay", sender: nil)
    }
}
