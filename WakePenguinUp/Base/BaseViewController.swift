//
//  BaseViewController.swift
//  WakePenguinUp
//
//  Created by 무릉 on 16/09/2019.
//  Copyright © 2019 lgbin. All rights reserved.
//

import Foundation
import UIKit
import CoreMotion
import AVKit
import AudioToolbox
import GoogleMobileAds

class BaseViewController : UIViewController {
    var toolbar:UIToolbar?
    
    lazy var motionManager: CMMotionManager = {
           return CMMotionManager()
       }()

    static var accelerationThreshold = 3.0
    
    
    var interstitial: GADInterstitial!
    
    var adsCheckCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardDoneInsert()
        setMotion()
        setfrontAds()
    }
    
    
    func setfrontAds() {
        interstitial = createAndLoadInterstitial()
    }
    func createAndLoadInterstitial() -> GADInterstitial {
//      var interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-2028686242886111/8160313398")
      interstitial.delegate = self
      interstitial.load(GADRequest())
      return interstitial
    }

    
    func keyboardDoneInsert(){
        //가상 키보드 취소하기 버튼 추가
        toolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: view.frame.size.width, height: 30))
        //create left side empty space so that done button set on right side
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: R.string.Basic_close, style: .done, target: self, action: #selector(doneButtonAction))
        toolbar?.setItems([flexSpace, doneBtn], animated: false)
        toolbar?.sizeToFit()
    }
    
    @objc func doneButtonAction() {
        view.endEditing(true)
    }
    
    func setMotion() {
        let userDefault = UserDefaults.standard
        
        if !userDefault.bool(forKey: "isStartApp") {
            BaseViewController.accelerationThreshold = 3.0
            userDefault.setValue(3, forKey: "shakeLevel")
        }else {
            BaseViewController.accelerationThreshold = Double(userDefault.integer(forKey: "shakeLevel"))
        }
        
        motionManager.startDeviceMotionUpdates(to: OperationQueue.current!) { [weak self] (motion, error) in
            if let userAcceleration = motion?.userAcceleration,
                let _self = self {
                
                //                print("\(userAcceleration.x) / \(userAcceleration.y)")
                
                if (fabs(userAcceleration.x) > BaseViewController.accelerationThreshold
                    || fabs(userAcceleration.y) > BaseViewController.accelerationThreshold
                    || fabs(userAcceleration.z) > BaseViewController.accelerationThreshold)
                {
                    if let topController = UIApplication.topMostViewController{
                        if let lockView = topController.view.viewWithTag(1000) as? LockView {
                            if lockView.contentView.isHidden {
                                
                                if self?.adsCheckCount ?? 0 > 1 {
                                    self?.adsCheckCount = 0
                                    if (self?.interstitial.isReady)! {
                                        self?.interstitial.present(fromRootViewController: topController)
                                    } else {
                                      print("Ad wasn't ready")
                                    }
                                }else {
                                    self?.adsCheckCount += 1
                                }
                                
                                
                                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                                UIApplication.shared.endIgnoringInteractionEvents()
                                
                                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
                                    lockView.contentView.alpha = 1.0
                                    lockView.contentView.isHidden = false
                                    lockView.lockImage.image = UIImage(named: "icon_lock_opened")
                                    lockView.lockImage.isHidden = false
                                }, completion: {(isCompleted) in
                                    lockView.contentView.isHidden = false
                                    lockView.contentView.shake(duration: 1)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                                        lockView.countLabel.isHidden = true
                                        lockView.countLabel.text = "3"
                                    }
                                })
                                
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
                                
                                
                                if topController.view.viewWithTag(10002) == nil{
                                    if let sleepView = topController.view.viewWithTag(10001) {
                                        sleepView.removeFromSuperview()
                                    }
                                    
                                    //                            let frame = CGRect(origin: topController.view.center, size: CGSize(width: 88, height: 167.5))
                                    //                            guard let wakeupImageView = UIImageView.fromGif(frame: frame, resourceName: "icon_penguin_wakeup_gif") else { return }
                                    
                                    let wakeupImageView = UIImageView(image: UIImage(named: "icon_penguin_wakeup_1"))
                                    
                                    let images: [UIImage] = [UIImage(named: "icon_penguin_wakeup_1")!, UIImage(named: "icon_penguin_wakeup_2")!]
                                    wakeupImageView.animationImages = images
                                    
                                    wakeupImageView.translatesAutoresizingMaskIntoConstraints = false
                                    wakeupImageView.tag = 10002
                                    wakeupImageView.animationDuration = 1
                                    topController.view.addSubview(wakeupImageView)
                                    
                                    wakeupImageView.bottomAnchor.constraint(equalTo: topController.view.bottomAnchor).isActive = true
                                    wakeupImageView.trailingAnchor.constraint(equalTo: topController.view.trailingAnchor, constant: -10).isActive = true
                                    
                                    wakeupImageView.heightAnchor.constraint(equalToConstant: 220).isActive = true
                                    wakeupImageView.widthAnchor.constraint(equalToConstant: 220).isActive = true
                                    
                                    //
                                    
                                    wakeupImageView.startAnimating()
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                                        wakeupImageView.removeFromSuperview()
                                    }
                                    
                                    LockView.alarmTimerState = false
                                    LockView.alarmTimer?.invalidate()
                                    
                                }
                                
                            }
                        }
                    }
                }
                
            } else {
                print("Motion error: \(error)")
            }
        }
    }
}

extension BaseViewController : GADInterstitialDelegate {
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
      print("interstitialDidReceiveAd")
    }

    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
      print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
      print("interstitialWillPresentScreen")
    }

    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
      print("interstitialWillDismissScreen")
    }

    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
      interstitial = createAndLoadInterstitial()
    }

    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
      print("interstitialWillLeaveApplication")
    }
}
