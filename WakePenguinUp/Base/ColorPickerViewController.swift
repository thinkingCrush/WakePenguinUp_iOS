//
//  ColorPickerViewController.swift
//  WakePenguinUp
//
//  Created by 무릉 on 2019/11/22.
//  Copyright © 2019 lgbin. All rights reserved.
//

import Foundation
import UIKit
import FlexColorPicker



class ColorPickerViewController : CustomColorPickerViewController {
    
    @IBOutlet weak var pickerController: RadialPaletteControl!
    var color : UIColor?
    var colorDelegate : sendColorValueDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let checkColor = color {
            //            pickerController.selectedColor = checkColor
            colorPicker.selectedColor = checkColor
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        colorDelegate?.colorValue(color: colorPicker.selectedColor)
    }
    
//
//    @IBAction func selectColorAction(_ sender: Any) {
//        colorDelegate?.colorValue(color: colorPicker.selectedColor)
//        self.navigationController?.popViewController(animated: true)
//    }
    
}
