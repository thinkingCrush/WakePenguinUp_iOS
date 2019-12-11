//
//  ShakeSettingPopupView.swift
//  WakePenguinUp
//
//  Created by 무릉 on 2019/12/10.
//  Copyright © 2019 lgbin. All rights reserved.
//

import Foundation
import UIKit

protocol shakePopupConfirmProtocol {
    func confirm(favorites : Favorites)
    func editConfirm(favorites : Favorites , indexPath : IndexPath?)
    func cancel()
}
class ShakeSettingPopupView : UIView{
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var shakeTitle: UILabel!
    @IBOutlet weak var shakeSubTitle: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet var levelCollection: [ARoundButton]!
    
    var level = 0
    
    var delegate : shakePopupConfirmProtocol?
    let userDefault = UserDefaults.standard
    
    var mTimer = Timer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        // Setup view from .xib file
    }
    
    func setFont(){
        cancelButton.setTitle(R.string.Basic_cancel, for: .normal)
        confirmButton.setTitle(R.string.Basic_confirm, for: .normal)
        shakeTitle.text = R.string.Message_17
        shakeSubTitle.text = R.string.Message_18
        
        levelCollection.forEach { (item) in
            switch item.tag {
            case 1 :
                item.setTitle(R.string.VeryWeakly, for: .normal)
            case 2 :
                item.setTitle(R.string.Weakly, for: .normal)
            case 3 :
                item.setTitle(R.string.Normal, for: .normal)
            case 4 :
                item.setTitle(R.string.Strongly, for: .normal)
            case 5 :
                item.setTitle(R.string.VeryStrongly, for: .normal)
            default:
                break
            }
        }
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("ShakeSettingPopupView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        setFont()
        setShake()
    }
    
    
    @objc func doneButtonAction() {
        self.endEditing(true)
    }
    
    @IBAction func btnHideTapped(_ sender: Any) {
        popupClose()
    }
    
    func setShake(){
        level = userDefault.integer(forKey: "shakeLevel")
        
        levelCollection.forEach { (item) in
            if item.tag == level {
                item.backgroundColor = UIColor.colorFromHex(335167)
                item.setTitleColor(UIColor.white, for: .normal)
            }
        }
        
    }
    
    func popupClose(){
        self.delegate?.cancel()
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            if let darkView = self.superview?.viewWithTag(9909) {
                darkView.isHidden = false
                darkView.alpha = 0
            }
        }) { (success) in
            self.removeFromSuperview()
        }
    }
    @IBAction func actionButton(_ sender: Any) {
        userDefault.setValue(level, forKey: "shakeLevel")
        BaseViewController.accelerationThreshold = Double(level)
        userDefault.synchronize()
        popupClose()
        
    }
    @IBAction func levelAction(_ sender: ARoundButton) {
        levelCollection.forEach { (item) in
            if item.tag == level {
                item.backgroundColor = UIColor.colorFromHex(14408667)
                item.setTitleColor(UIColor.black, for: .normal)
            }
        }
        sender.backgroundColor = UIColor.colorFromHex(335167)
        sender.setTitleColor(UIColor.white, for: .normal)
        level = sender.tag
    }
    
}
