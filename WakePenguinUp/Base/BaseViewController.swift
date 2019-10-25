//
//  BaseViewController.swift
//  WakePenguinUp
//
//  Created by 무릉 on 16/09/2019.
//  Copyright © 2019 lgbin. All rights reserved.
//

import Foundation
import UIKit

class BaseViewController : UIViewController {
    var toolbar:UIToolbar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardDoneInsert()
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
    

}
