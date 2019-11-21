//
//  SideMenuViewController.swift
//  WakePenguinUp
//
//  Created by 무릉 on 20/09/2019.
//  Copyright © 2019 lgbin. All rights reserved.
//

import Foundation
import UIKit
import SideMenu

protocol getURLProtocol {
    func getURL(url: String)
}

class Favorites : NSObject, NSCoding{
    var name : String
    var url : String
    var thumbnailColor : UIColor
    var thumbnailText : String
    init(name: String, url: String, thumbnailColor : UIColor, thumbnailText : String) {
        self.name = name
        self.url = url
        self.thumbnailColor = thumbnailColor
        self.thumbnailText = thumbnailText
        
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let url = aDecoder.decodeObject(forKey: "url") as! String
        let thumbnailColor = aDecoder.decodeObject(forKey: "thumbnailColor") as! UIColor
        let thumbnailText = aDecoder.decodeObject(forKey: "thumbnailText") as! String
        self.init(name: name, url: url, thumbnailColor: thumbnailColor, thumbnailText : thumbnailText)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(url, forKey: "url")
        aCoder.encode(thumbnailColor, forKey: "thumbnailColor")
        aCoder.encode(thumbnailText, forKey: "thumbnailText")
        
    }
    
}


class SideMenuViewController : BaseViewController {
    
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var favoritesList : [Favorites] = []
    
    var getUrlDelegate : getURLProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setFont()
        setTableView()
        favoritesDataSet()
    }
    
    func setTableView(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        
        let bottomView = UIView()
        bottomView.backgroundColor = UIColor.clear
        self.tableView.tableFooterView = bottomView  //빈공간 밑줄 제거
        //밑줄 좌우 공백 적용
        self.tableView.cellLayoutMarginsFollowReadableWidth = false
        self.tableView.separatorInset.left = 15
        self.tableView.separatorInset.right = 15
        
//        self.tableView.isEditing = true
    }
    
    func setEmptyView(){
        emptyView.isHidden = false
    }
 
    func setFont(){
        emptyLabel.text = R.string.Message_03
    }
    func favoritesDataSet(){
        favoritesList = []
        let userDefault = UserDefaults.standard
        if let decoded = userDefault.data(forKey: "FavoritesData") {
            do{
                let decodeList = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded) as! [Favorites]
                favoritesList = decodeList
                if favoritesList.count == 0 {
                    setEmptyView()
                }
            }catch {
                setEmptyView()
                print("error.")
            }
        }else {
            setEmptyView()
        }
    }
    
    @IBAction func editAction(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if #available(iOS 13.0, *) {
            if let vc = sb.instantiateViewController(identifier: "EditVC") as? FavoritesEditViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            if let vc = sb.instantiateViewController(withIdentifier: "EditVC") as? FavoritesEditViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func alarmAction(_ sender: UIButton) {
        dismiss(animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                if let vc = UIApplication.topMostViewController as? MainViewController{
                    if vc.view.viewWithTag(10001) == nil {
                        let popupView = TimerPopupView()
                        popupView.tag = 10001
                        popupView.frame.size = CGSize(width: 300, height: 250)
                        popupView.center = vc.view.center
                        popupView.alpha = 1
                        popupView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
                        vc.view.addSubview(popupView)
                        
                        
                        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
                            vc.darkBackgroundView.isHidden = false
                            vc.darkBackgroundView.alpha = 0.8
                            popupView.transform = .identity
                        })
                    }
                }
            }
        }
        
    }
}



extension SideMenuViewController : UITableViewDelegate {
}

extension SideMenuViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            UIView.animate(withDuration: 0.4) {
                cell.transform = CGAffineTransform.identity
            }
        }
        let item = favoritesList[indexPath.row]
        getUrlDelegate?.getURL(url: item.url)
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : FavoritesItemCell = tableView.dequeueReusableCell(withIdentifier: "favoritesItemCellID", for: indexPath) as! FavoritesItemCell
        
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        
        let favorites = favoritesList[indexPath.row]
        cell.favoriteName.text = favorites.name
        cell.thumbnailView.backgroundColor = favorites.thumbnailColor
        cell.thumbnailText.text = favorites.thumbnailText
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.4) {
            cell.transform = CGAffineTransform.identity
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    
}
