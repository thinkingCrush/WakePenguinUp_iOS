//
//  LockView.swift
//  WakePenguinUp
//
//  Created by 무릉 on 18/09/2019.
//  Copyright © 2019 lgbin. All rights reserved.
//

import UIKit
import AudioToolbox
import MBCircularProgressBar
import AVKit

class LockView: UIView {
    
    @IBOutlet weak var circularProgress: MBCircularProgressBarView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var cycleContainerView: ARoundView!
    @IBOutlet weak var lockImage: UIImageView!
    
    var time = 3
    var startTimer = false
    
    static var soundPlayer : AVAudioPlayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        // Setup view from .xib file
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("LockView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        
        cycleContainerView.cornerRadius = 35
        setView()
    }
    
    func setView(){
        self.tag = 1000
    }
    
    var isCancel = false
    @IBAction func lockButtonAction(_ sender: UIButton) {
        
        contentView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.4) {
            self.contentView.transform = CGAffineTransform.identity
        }
        
        
        if startTimer == false {
            startTimer = true
            timeCheck()
        }else {
            isCancel = true
        }
                
    }
    

    
    func timeCheck(){
        if isCancel {
            time = 3
            countLabel.text = "3"
            countLabel.isHidden = true
            lockImage.isHidden = false
            startTimer = false
            isCancel = false
            return
        }
        
        countLabel.isHidden = false
        lockImage.isHidden = true
        UIView.animate(withDuration: 1.0, animations: {
            self.circularProgress.value = 1
        }) { (result) in
            self.circularProgress.value = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50), execute: {
                if self.time > 1 {
                    self.time -= 1
                    self.countLabel.text  = "\(self.time)"
                    self.timeCheck()
                }else {
                    if self.isCancel {
                        self.time = 3
                        self.countLabel.text = "3"
                        self.countLabel.isHidden = true
                        self.lockImage.isHidden = false
                        self.startTimer = false
                        self.isCancel = false
                        return
                    }else {
                        self.timeLimitStop()
                    }
                }
            })
        }
    }
    
    func timeLimitStop(){
        
        let path = Bundle.main.path(forResource: "sound_lock", ofType : "mp3")!
        let url = URL(fileURLWithPath : path)
        do {
            LockView.soundPlayer = try AVAudioPlayer(contentsOf: url)
            LockView.soundPlayer.play()
        } catch {
            print ("There is an issue with this code!")

        }
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        
        startTimer = false
        time = 3
//        Common.showToast(message: "잠김!!")
        countLabel.isHidden = true
        countLabel.text = "3"
        
        lockImage.image = UIImage(named: "icon_lock_closeed")
        lockImage.isHidden = false
        AppDelegate.isLock = true
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        contentView.shake(duration: 2)
        UIView.animate(withDuration: 1.0, delay: 1, options: .curveEaseOut, animations: {
            self.contentView.alpha = 0.0
        }, completion: {(isCompleted) in
            self.contentView.isHidden = true
            self.lockImage.isHidden = true
            self.lockImage.image = UIImage(named: "icon_lock_opened")
        })
        
        if let topController = UIApplication.topMostViewController{
            if topController.view.viewWithTag(10001) == nil {
                if let wakeupView = topController.view.viewWithTag(10002) {
                    wakeupView.removeFromSuperview()
                }
//                let frame = CGRect(origin: topController.view.center, size: CGSize(width: 111.3, height: 121.5))
//                guard let sleepImageView = UIImageView.fromGif(frame: frame, resourceName: "icon_penguin_sleep_gif") else { return }
                
                let sleepImageView = UIImageView(image: UIImage(named: "icon_penguin_sleep_0"))
                
                let images: [UIImage] = [UIImage(named: "icon_penguin_sleep_0")!, UIImage(named: "icon_penguin_sleep_1")!, UIImage(named: "icon_penguin_sleep_2")!, UIImage(named: "icon_penguin_sleep_3")!]
                sleepImageView.animationImages = images
                
                sleepImageView.translatesAutoresizingMaskIntoConstraints = false
                sleepImageView.tag = 10001
                sleepImageView.animationDuration = 0.6
                topController.view.insertSubview(sleepImageView, at: 1)
                
                
                
                sleepImageView.bottomAnchor.constraint(equalTo: topController.view.bottomAnchor).isActive = true
                sleepImageView.trailingAnchor.constraint(equalTo: topController.view.trailingAnchor, constant: -30).isActive = true
                
                
                if UIDevice.current.orientation.isLandscape {
//                    sleepImageView.widthAnchor.constraint(equalTo: topController.view.widthAnchor, multiplier: 0.4).isActive = true
                    sleepImageView.heightAnchor.constraint(equalTo: topController.view.heightAnchor, multiplier: 0.4).isActive = true
                    sleepImageView.widthAnchor.constraint(equalToConstant: (topController.view.frame.height * 0.4) * 0.91).isActive = true
                }else {
                    sleepImageView.widthAnchor.constraint(equalTo: topController.view.widthAnchor, multiplier: 0.4).isActive = true
                    sleepImageView.heightAnchor.constraint(equalToConstant: (topController.view.frame.width * 0.4) * 1.09).isActive = true
                }
                
                sleepImageView.startAnimating()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                    sleepImageView.removeFromSuperview()
                }
            }
        }
        
    }
    
   
    
}

