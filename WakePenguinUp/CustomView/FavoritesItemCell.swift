//
//  FavoritesItemCell.swift
//  WakePenguinUp
//
//  Created by 무릉 on 19/09/2019.
//  Copyright © 2019 lgbin. All rights reserved.
//

import Foundation
import UIKit

class FavoritesItemCell : UITableViewCell{
    
    @IBOutlet weak var favoriteName: UILabel!
    @IBOutlet weak var thumbnailView: ARoundView!
    @IBOutlet weak var thumbnailText: UILabel!
    
    func initVars() {
        self.clipsToBounds = true
        thumbnailView.cornerRadius = thumbnailView.frame.width / 2
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initVars()
    }
}
