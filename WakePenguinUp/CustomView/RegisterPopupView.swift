//
//  PopupViewController.swift
//  WakePenguinUp
//
//  Created by 무릉 on 20/09/2019.
//  Copyright © 2019 lgbin. All rights reserved.
//

import Foundation
import UIKit

protocol popupConfirmProtocol {
    func confirm(favorites : Favorites)
    func editConfirm(favorites : Favorites , indexPath : IndexPath?)
    func cancel()
}
class RegisterPopupView : UIView{
    var favoritesName = ""
    var favoritesUrl = ""
    var isFavoritesCheck = false
    
    var checkIndexPath : IndexPath?
    var savedEditName = ""
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var favoritesNameTextField: UITextField!
    @IBOutlet weak var favoritesUrlTextField: UITextField!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var thumnailView: ARoundView!
    @IBOutlet weak var thumnailText: UILabel!
    
    var delegate : popupConfirmProtocol?
    
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
        favoritesNameTextField.placeholder = R.string.Message_08
    }
    
    private func commonInit(){
        
        Bundle.main.loadNibNamed("RegisterPopupView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        
        setFont()
        
        setToolbar()
        thumnailView.cornerRadius = thumnailView.frame.width / 2
        
        setNotificationCenter()
        
    }
    
    func setNotificationCenter(){
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let notificationCenter = NotificationCenter.default
//        UIKeyboardWillHide
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow),
                                       name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide),
                                       name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setToolbar(){
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.frame.size.width, height: 30))
        //create left side empty space so that done button set on right side
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: R.string.Basic_close, style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        
        favoritesNameTextField.inputAccessoryView = toolbar
        favoritesUrlTextField.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonAction() {
        self.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("notification: Keyboard will show")
            if self.contentView.frame.origin.y == 0{
                self.contentView.frame.origin.y -= keyboardSize.height / 2
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("notification: Keyboard will hidden")
            if self.contentView.frame.origin.y != 0 {
                self.contentView.frame.origin.y += keyboardSize.height / 2
            }
        }
    }
    
    
    func setView(name : String, url : String, check : Bool){
        favoritesName = name
        favoritesUrl = url
        isFavoritesCheck = check
        
        favoritesNameTextField.text = name
        favoritesUrlTextField.text = url
        
        if url == "" {
            favoritesUrlTextField.text = "https://"
            favoritesUrlTextField.isEnabled = true
        }
        
        if check {
            savedEditName = name
            actionButton.setTitle(R.string.Basic_edit, for: .normal)
            
            let userDefault = UserDefaults.standard
            if let decoded = userDefault.data(forKey: "FavoritesData") {
                do{
                    let decodeList = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded) as! [Favorites]
                    decodeList.forEach { (item) in
                        if item.name == name {
                            thumnailText.text = item.thumbnailText
                            thumnailView.backgroundColor = item.thumbnailColor
                        }
                    }
                }catch {
                    print("error.")
                }
            }
        }else {
            actionButton.setTitle(R.string.Basic_save, for: .normal)
            
            let urlArray = url.components(separatedBy: ".")
            var thumbnailFirstText : Character = R.string.Basic_shortcuts.first!
            if urlArray.count > 1 {
                thumbnailFirstText = url.components(separatedBy: ".")[1].first ?? "?"
            }else {
                thumbnailFirstText = R.string.Basic_shortcuts.first!
            }
            thumnailText.text = "\(thumbnailFirstText.uppercased())"
            thumnailView.backgroundColor = UIColor.random
        }
    }
    
    @IBAction func urlTextFieldReturnAction(_ sender: UITextField){
        self.endEditing(true)
    }
    
    @IBAction func urlTextFieldReturnAction2(_ sender: UITextField){
        self.endEditing(true)
    }
    
    
    @IBAction func rightButtonAction(_ sender: UIButton) {
        
        if isFavoritesCheck{
            //수정 로직
            saveEditFavoritesData()
            popupClose()
            guard let name = favoritesNameTextField.text else { return }
            guard let url  = favoritesUrlTextField.text else { return }
            guard let thumbnailColor  = thumnailView.backgroundColor else { return }
            guard let thumbnailText  = thumnailText.text else { return }
            delegate?.editConfirm(favorites: Favorites(name: name, url: url, thumbnailColor: thumbnailColor, thumbnailText: thumbnailText), indexPath: checkIndexPath)
        }else{
            //저장 로직
            saveFavoritesData()
            popupClose()
            guard let name = favoritesNameTextField.text else { return }
            guard let url  = favoritesUrlTextField.text else { return }
            guard let thumbnailColor  = thumnailView.backgroundColor else { return }
            guard let thumbnailText  = thumnailText.text else { return }
            delegate?.confirm(favorites: Favorites(name: name, url: url, thumbnailColor: thumbnailColor, thumbnailText: thumbnailText))
        }
    }
    
    @IBAction func nameTextChangeAction(_ sender: UITextField) {
        if let text = sender.text, text != "" {
            if let firstChar = text.first {
                thumnailText.text = "\(firstChar.uppercased())"
            }
        }else {
            thumnailText.text = "?"
        }
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
//        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
//            self.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
//            if let darkView = self.superview?.viewWithTag(9909) {
//                darkView.isHidden = false
//                darkView.alpha = 0
//            }
//        }) { (success) in
//            self.removeFromSuperview()
//        }
    }
    
    func saveFavoritesData(){
        guard let name = favoritesNameTextField.text else {return}
        guard let url = favoritesUrlTextField.text else {return}
        guard let thumbnailColor  = thumnailView.backgroundColor else { return }
        guard let thumbnailText  = thumnailText.text else { return }
        let data : Favorites = Favorites(name: name, url: url, thumbnailColor: thumbnailColor, thumbnailText: thumbnailText)
        
        let userDefault = UserDefaults.standard
        if let decoded = userDefault.data(forKey: "FavoritesData") {
            do{
                let decodeList = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded) as! [Favorites]
                var favoritesList = decodeList
                favoritesList.append(data)
                
                do{
                    let encodedData : Data = try NSKeyedArchiver.archivedData(withRootObject: favoritesList, requiringSecureCoding: false)
                    userDefault.removeObject(forKey: "FavoritesData")
                    userDefault.set(encodedData, forKey: "FavoritesData")
                    userDefault.set(true, forKey: "InitAppSetting")
                    userDefault.synchronize()
                }catch {
                }
                
            }catch {
                print("error.")
            }
        }else {
            do{
                let encodedData : Data = try NSKeyedArchiver.archivedData(withRootObject: [data], requiringSecureCoding: false)
                userDefault.set(encodedData, forKey: "FavoritesData")
                userDefault.set(true, forKey: "InitAppSetting")
                userDefault.synchronize()
            }catch {
                
            }
        }
    }
    
    func saveEditFavoritesData(){
        guard let name = favoritesNameTextField.text else {return}
        guard let url = favoritesUrlTextField.text else {return}
        guard let thumbnailColor  = thumnailView.backgroundColor else { return }
        guard let thumbnailText  = thumnailText.text else { return }
        
        let data : Favorites = Favorites(name: name, url: url, thumbnailColor: thumbnailColor, thumbnailText: thumbnailText)
        
        let userDefault = UserDefaults.standard
        if let decoded = userDefault.data(forKey: "FavoritesData") {
            do{
                let decodeList = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded) as! [Favorites]
                var favoritesList : [Favorites] = []
                let tempFavoritesList : [Favorites] = decodeList
                
                var row = 0
                for (index,value) in tempFavoritesList.enumerated() {
                    if value.name != savedEditName {
                        favoritesList.append(value)
                    }else {
                        row = index
                    }
                }
                
                if let index = checkIndexPath {
                    favoritesList.insert(data, at: index.row)
                }else {
                    favoritesList.insert(data, at: row)
                }
                
                do{
                    let encodedData : Data = try NSKeyedArchiver.archivedData(withRootObject: favoritesList, requiringSecureCoding: false)
                    userDefault.removeObject(forKey: "FavoritesData")
                    userDefault.set(encodedData, forKey: "FavoritesData")
                    userDefault.set(true, forKey: "InitAppSetting")
                    userDefault.synchronize()
                }catch {
                }
                
            }catch {
                print("error.")
            }
        }
    }
    
    
}
