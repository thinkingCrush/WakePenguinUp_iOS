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
    static var alarmTimer : Timer?
    static var alarmTimerState = false
    
    static var soundPlayer : AVAudioPlayer!
    
    let userDefault = UserDefaults.standard
    
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
                        if let sideMenuViewController = UIApplication.topMostViewController as? SideMenuViewController{
                            sideMenuViewController.dismiss(animated: true) {
                                self.timeLimitStop()
                            }
                        }else {
                            self.timeLimitStop()
                        }
                        
                        
                    }
                }
            })
        }
    }
    
    func timeLimitStop(){
        
        let path = Bundle.main.path(forResource: "sound_lock", ofType : "wav")!
        let url = URL(fileURLWithPath : path)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            
            LockView.soundPlayer = try AVAudioPlayer(contentsOf: url)
            LockView.soundPlayer.prepareToPlay()
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
                sleepImageView.animationDuration = 1
                topController.view.insertSubview(sleepImageView, at: 2)
                
                
                
                sleepImageView.bottomAnchor.constraint(equalTo: topController.view.bottomAnchor).isActive = true
                sleepImageView.trailingAnchor.constraint(equalTo: topController.view.trailingAnchor, constant: -10).isActive = true
                
                sleepImageView.heightAnchor.constraint(equalToConstant: 220).isActive = true
                sleepImageView.widthAnchor.constraint(equalToConstant: 220).isActive = true
                
                
                sleepImageView.startAnimating()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                    sleepImageView.removeFromSuperview()
                }
                
                if userDefault.bool(forKey: "isAlarmTimer") {
                    if let date = userDefault.value(forKey: "alarmCheck") as? Date {
                        if !LockView.alarmTimerState {
                            LockView.alarmTimerState = true
                            let dateformatter = DateFormatter()
                            dateformatter.dateFormat = "HH.mm"
                            let dateString = dateformatter.string(from: date)
                            let dateArr = dateString.components(separatedBy: ".")
                            
                            let second = (Int(dateArr[0])! * 3600) + (Int(dateArr[1])! * 60)
                            LockView.alarmTimer = Timer.scheduledTimer(timeInterval: TimeInterval(second), target: self, selector: #selector(appFinish), userInfo: nil, repeats: false)
                            
                            
                            let timerView = UIView()
                            timerView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                            timerView.translatesAutoresizingMaskIntoConstraints = false
                            
                            let timerLabel = UILabel()
                            
                            var hourString = ""
                            if dateArr[0].first == "0"{
                                var hour = dateArr[0]
                                hour.removeFirst()
                                hourString = "\(hour)"
                            }else {
                                hourString = "\(dateArr[0])"
                            }
                            
                            var minString = ""
                            if dateArr[1].first == "0"{
                                var min = dateArr[1]
                                min.removeFirst()
                                minString = "\(min)"
                            }else {
                                minString = "\(dateArr[1])"
                            }
                            
                            if Locale.current.languageCode == "ko" {
                                timerLabel.font = UIFont.systemFont(ofSize: 26, weight: .bold)
                                if hourString == "0"{
                                    timerLabel.text = "\(minString)\(R.string.Basic_min) \(R.string.Message_13)"
                                }else {
                                    timerLabel.text = "\(hourString)\(R.string.Basic_hour) \(minString)\(R.string.Basic_min) \(R.string.Message_13)"
                                }
                                
                            }else {
                                timerLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
                                timerLabel.text = String(format: R.string.Message_13, arguments: [hourString,minString])
                            }
                            
                            timerLabel.numberOfLines = 2
                            timerLabel.textAlignment = .center
                            timerLabel.textColor = .white
                            timerLabel.translatesAutoresizingMaskIntoConstraints = false
                            timerView.addSubview(timerLabel)
                            timerLabel.centerXAnchor.constraint(equalTo: timerView.centerXAnchor, constant: 0).isActive = true
                            timerLabel.centerYAnchor.constraint(equalTo: timerView.centerYAnchor, constant: 0).isActive = true
                            
                            
                            topController.view.addSubview(timerView)
                            timerView.topAnchor.constraint(equalTo: topController.view.topAnchor, constant: 70).isActive = true
                            timerView.centerXAnchor.constraint(equalTo: topController.view.centerXAnchor, constant: 0).isActive = true
                            
                            timerView.widthAnchor.constraint(equalToConstant: 280).isActive = true
                            timerView.heightAnchor.constraint(equalToConstant: 100).isActive = true
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                                timerView.removeFromSuperview()
                            }
                        }
                    }
                }
                
            }
        }
        
    }
    
    @objc func appFinish(){
        if let topController = UIApplication.topMostViewController {
            let timerView = UIView()
            timerView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            timerView.translatesAutoresizingMaskIntoConstraints = false

            let timerLabel = UILabel()
            timerLabel.font = UIFont.systemFont(ofSize: 26, weight: .bold)

            timerLabel.text = R.string.Message_16
            timerLabel.numberOfLines = 2
            timerLabel.textAlignment = .center
            timerLabel.textColor = .white
            timerLabel.translatesAutoresizingMaskIntoConstraints = false
            timerView.addSubview(timerLabel)
            timerLabel.centerXAnchor.constraint(equalTo: timerView.centerXAnchor, constant: 0).isActive = true
            timerLabel.centerYAnchor.constraint(equalTo: timerView.centerYAnchor, constant: 0).isActive = true


            topController.view.addSubview(timerView)
            timerView.topAnchor.constraint(equalTo: topController.view.topAnchor, constant: 70).isActive = true
            timerView.centerXAnchor.constraint(equalTo: topController.view.centerXAnchor, constant: 0).isActive = true

            timerView.widthAnchor.constraint(equalToConstant: 280).isActive = true
            timerView.heightAnchor.constraint(equalToConstant: 100).isActive = true

            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                timerView.removeFromSuperview()
                exit(0)
            }
        }
    }
    
}

