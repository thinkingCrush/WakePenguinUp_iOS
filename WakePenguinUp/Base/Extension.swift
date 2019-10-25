//
//  Extension.swift
//  WakePenguinUp
//
//  Created by 무릉 on 16/09/2019.
//  Copyright © 2019 lgbin. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AudioToolbox

extension UIApplication {
    /// The top most view controller
    static var topMostViewController: UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController?.visibleViewController
    }
}

extension UIViewController {
    /// The visible view controller from a given view controller
    var visibleViewController: UIViewController? {
        if let navigationController = self as? UINavigationController {
            return navigationController.topViewController?.visibleViewController
        } else if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.visibleViewController
        } else if let presentedViewController = presentedViewController {
            return presentedViewController.visibleViewController
        } else {
            return self
        }
    }
}
extension UIColor {
    open class func colorFromHex(_ hex: Int) -> UIColor {
        return UIColor(red: CGFloat((hex & 0xFF0000) >> 16) / 255,
                       green: CGFloat((hex & 0x00FF00) >> 8) / 255,
                       blue: CGFloat(hex & 0x0000FF) / 255,
                       alpha: 1)
    }
    
    convenience init(colorWithHexValue value : Int, alpha: CGFloat = 1.0){
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(value & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

extension AVPlayerViewController {
    
    func goFullScreen() {
        let selectorName = "enterFullScreenAnimated:completionHandler:"
        let selectorToForceFullScreenMode = NSSelectorFromString(selectorName)
        
        if self.responds(to: selectorToForceFullScreenMode) {
            self.perform(selectorToForceFullScreenMode, with: true, with: nil)
        }
    }
    
    func quitFullScreen() {
        let selectorName = "exitFullScreenAnimated:completionHandler:"
        let selectorToForceQuitFullScreenMode = NSSelectorFromString(selectorName)
        
        if self.responds(to: selectorToForceQuitFullScreenMode) {
            self.perform(selectorToForceQuitFullScreenMode, with: true, with: nil)
        }
    }
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        print("shake!")
        if motion == .motionShake {
            if let topController = UIApplication.topMostViewController{
                if let lockView = topController.view.viewWithTag(1000) as? LockView {
                    if lockView.contentView.isHidden {
                        
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
                    }
                }
            }
        }
    }
}

extension String{
    func getArrayAfterRegex(regex: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self,
                                        range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
}


extension UIView {
    func shake(duration: CFTimeInterval) {
        let translation = CAKeyframeAnimation(keyPath: "transform.translation.x");
        translation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        translation.values = [-5, 5, -5, 5, -3, 3, -2, 2, 0]
        
        let rotation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        rotation.values = [-5, 5, -5, 5, -3, 3, -2, 2, 0].map {
            ( degrees: Double) -> Double in
            let radians: Double = (.pi * degrees) / 180.0
            return radians
        }
        
        let shakeGroup: CAAnimationGroup = CAAnimationGroup()
        shakeGroup.animations = [translation, rotation]
        shakeGroup.duration = duration
        self.layer.add(shakeGroup, forKey: "shakeIt")
        
        if let topController = UIApplication.topMostViewController{
            if let sleepView = topController.view.viewWithTag(10001){
                sleepView.removeFromSuperview()
            }
        }
        
    }
}


extension UIImageView {
    static func fromGif(frame: CGRect, resourceName: String) -> UIImageView? {
        guard let path = Bundle.main.path(forResource: resourceName, ofType: "gif") else {
            print("Gif does not exist at that path")
            return nil
        }
        let url = URL(fileURLWithPath: path)
        guard let gifData = try? Data(contentsOf: url),
            let source =  CGImageSourceCreateWithData(gifData as CFData, nil) else { return nil }
        var images = [UIImage]()
        let imageCount = CGImageSourceGetCount(source)
        for i in 0 ..< imageCount {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: image))
            }
        }
        let gifImageView = UIImageView(frame: frame)
        gifImageView.animationImages = images
        return gifImageView
    }
}


extension String {
    var localized : String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
