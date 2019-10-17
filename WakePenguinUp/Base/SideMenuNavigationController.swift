//
//  SideMenuNavigationController.swift
//  WakePenguinUp
//
//  Created by 무릉 on 20/09/2019.
//  Copyright © 2019 lgbin. All rights reserved.
//

import UIKit
import SideMenu


class SideMenuNavigationController:UISideMenuNavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let presentationStyle : SideMenuPresentationStyle = .viewSlideOut
        presentationStyle.backgroundColor = UIColor.white
        var settings = SideMenuSettings()
        settings.presentationStyle = presentationStyle
        
        self.settings = settings
        
        self.leftSide = false
        self.menuWidth = UIScreen.main.bounds.width * 0.45
        
    }
}
