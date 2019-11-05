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
                            wakeupImageView.animationDuration = 0.6
                            topController.view.addSubview(wakeupImageView)
                            
                            wakeupImageView.bottomAnchor.constraint(equalTo: topController.view.bottomAnchor).isActive = true
                            wakeupImageView.trailingAnchor.constraint(equalTo: topController.view.trailingAnchor, constant: -30).isActive = true
                            
                             if UIDevice.current.orientation.isLandscape {
                                wakeupImageView.heightAnchor.constraint(equalTo: topController.view.heightAnchor, multiplier: 0.45).isActive = true
                                wakeupImageView.widthAnchor.constraint(equalToConstant: (topController.view.frame.height * 0.45) * 0.52).isActive = true
                            }else {
                                wakeupImageView.widthAnchor.constraint(equalTo: topController.view.widthAnchor, multiplier: 0.35).isActive = true
                                wakeupImageView.heightAnchor.constraint(equalToConstant: (topController.view.frame.width * 0.35) * 1.9).isActive = true
                            }
                            
                            
                            wakeupImageView.startAnimating()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                                wakeupImageView.removeFromSuperview()
                            }
                        }
                        
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
    
    func addDashedBorder() {
    
        let color = UIColor.white.cgColor
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 2
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [6,3]
        
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: frameSize.width / 2).cgPath
        
        
        self.layer.addSublayer(shapeLayer)
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
