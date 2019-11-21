//
//  TimerPopupView.swift
//  WakePenguinUp
//
//  Created by 무릉 on 2019/11/21.
//  Copyright © 2019 lgbin. All rights reserved.
//

import Foundation
import UIKit

protocol timerPopupConfirmProtocol {
    func confirm(favorites : Favorites)
    func editConfirm(favorites : Favorites , indexPath : IndexPath?)
    func cancel()
}
class TimerPopupView : UIView{
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var timerSwitch: UISwitch!
    @IBOutlet weak var timerTitleLabel: UILabel!
    @IBOutlet weak var timerSubLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var confirmButton: UIButton!
    
    var delegate : timerPopupConfirmProtocol?
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
    
    func setTimer(){
        if userDefault.bool(forKey: "isAlarmTimer") {
            timePicker.isEnabled = true
            timerSwitch.isOn = true
            
            if let date = userDefault.value(forKey: "alarmCheck") as? Date {
                timePicker.setDate(date, animated: true)
            }
        }else {
            timePicker.isEnabled = false
            timerSwitch.isOn = false
        }
    }
    
    func setFont(){
        cancelButton.setTitle(R.string.Basic_cancel, for: .normal)
        confirmButton.setTitle(R.string.Basic_confirm, for: .normal)
        timerTitleLabel.text = R.string.Message_14
        timerSubLabel.text = R.string.Message_15
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("TimerPopupView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        setFont()
        setTimer()
    }
    
    
    @objc func doneButtonAction() {
        self.endEditing(true)
    }
    
    @IBAction func btnHideTapped(_ sender: Any) {
        popupClose()
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
        if timerSwitch.isOn {
            userDefault.setValue(true, forKey: "isAlarmTimer")
            userDefault.setValue(timePicker.date, forKey: "alarmCheck")

        }else {
            userDefault.setValue(false, forKey: "isAlarmTimer")
        }
        popupClose()
        
    }
    @IBAction func alarmSwitchAction(_ sender: UISwitch) {
        if sender.isOn {
            timePicker.isEnabled = true
        }else {
            timePicker.isEnabled = false
        }
    }
    
}
