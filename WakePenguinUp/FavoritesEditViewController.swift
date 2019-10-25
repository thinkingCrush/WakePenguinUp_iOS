//
//  FavoritesEditViewController.swift
//  WakePenguinUp
//
//  Created by 무릉 on 20/09/2019.
//  Copyright © 2019 lgbin. All rights reserved.
//

import Foundation
import UIKit

protocol EditDelegateProtocol {
    func editCommit()
}
class FavoritesEditViewController: BaseViewController {
    
    @IBOutlet weak var navigationTitleLabel: UINavigationItem!
    @IBOutlet weak var helpLabel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var darkBackgroundView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var favoritesList : [Favorites] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setFont()
        setTableView()
        favoritesDataSet()
    }
        
    
    func setFont(){
        helpLabel.text = R.string.Message_02
        navigationTitleLabel.title = R.string.Basic_edit
    }
    override func viewWillAppear(_ animated: Bool) {
        super.navigationController?.isNavigationBarHidden = false
        let buttonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(addTapped))
        buttonItem.image = UIImage(named: "icon_add")
        self.navigationItem.rightBarButtonItem = buttonItem
    }
    
    @objc func addTapped(){
        if navigationController?.view.viewWithTag(10000) == nil {
            let popupView = RegisterPopupView()
            popupView.tag = 10000
            popupView.frame.size = CGSize(width: 300, height: 250)
            popupView.center = view.center
            popupView.alpha = 1
            popupView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
            
            popupView.setView(name: R.string.Basic_shortcuts, url: "", check: false)
            popupView.delegate = self
            navigationController?.view.addSubview(popupView)
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
                self.darkBackgroundView.isHidden = false
                self.darkBackgroundView.alpha = 0.8
                
                popupView.transform = .identity
            })
        }
    }
    
    func setEmptyView(){
        emptyView.isHidden = false
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
        self.tableView.isEditing = true
    }
    
    
    func favoritesDataSet(){
        let userDefault = UserDefaults.standard
        if let decoded = userDefault.data(forKey: "FavoritesData") {
            do{
                let decodeList = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded) as! [Favorites]
                favoritesList = decodeList
                print("chekc count : \(favoritesList.count)")
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
}



extension FavoritesEditViewController : UITableViewDelegate {
}

extension FavoritesEditViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let delete = UITableViewRowAction(style: .destructive, title: R.string.Basic_delete) { (action, indexPath) in
            // delete item at indexPath
            self.favoritesList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            let userDefault = UserDefaults.standard
            do{
                if self.favoritesList.count == 0 {
                    self.setEmptyView()
                    userDefault.removeObject(forKey: "FavoritesData")
                    userDefault.set(true, forKey: "InitAppSetting")
                }else {
                    let encodedData : Data = try NSKeyedArchiver.archivedData(withRootObject: self.favoritesList, requiringSecureCoding: false)
                    userDefault.removeObject(forKey: "FavoritesData")
                    userDefault.set(encodedData, forKey: "FavoritesData")
                    userDefault.set(true, forKey: "InitAppSetting")
                }
                userDefault.synchronize()
            }catch {
                self.setEmptyView()
                print("error.")
            }
            
        }

        let modify = UITableViewRowAction(style: .default, title: R.string.Basic_edit) { (action, indexPath) in
            // share item at indexPath
            print("I want to share: \(self.favoritesList[indexPath.row])")
            let item = self.favoritesList[indexPath.row]
            if self.view.viewWithTag(10000) == nil {
                let popupView = RegisterPopupView()
                popupView.tag = 10000
                popupView.frame.size = CGSize(width: 300, height: 250)
                popupView.center = self.view.center
                popupView.alpha = 1
                popupView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
                popupView.checkIndexPath = indexPath
                popupView.setView(name: item.name, url: item.url, check: true)
                popupView.delegate = self
                
                self.navigationController?.view.addSubview(popupView)
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
                    self.darkBackgroundView.isHidden = false
                    self.darkBackgroundView.alpha = 0.8
                    
                    popupView.transform = .identity
                })
                
            }
        }

        modify.backgroundColor = UIColor.lightGray

        return [delete, modify]

    }


    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.favoritesList[sourceIndexPath.row]
        favoritesList.remove(at: sourceIndexPath.row)
        favoritesList.insert(movedObject, at: destinationIndexPath.row)
        
        let userDefault = UserDefaults.standard
        do{
            let encodedData : Data = try NSKeyedArchiver.archivedData(withRootObject: self.favoritesList, requiringSecureCoding: false)
            userDefault.removeObject(forKey: "FavoritesData")
            userDefault.set(encodedData, forKey: "FavoritesData")
            userDefault.set(true, forKey: "InitAppSetting")
            userDefault.synchronize()
        }catch {
            print("error.")
        }
        
        debugPrint("\(sourceIndexPath.row) => \(destinationIndexPath.row)")
        
    }
    
}
extension FavoritesEditViewController : popupConfirmProtocol {
    func cancel() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func confirm(favorites: Favorites) {
        emptyView.isHidden = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        favoritesList.append(favorites)
        let indexPath = IndexPath(row: favoritesList.count - 1, section: 0)
        
        self.tableView.insertRows(at: [indexPath], with: .automatic)
//        self.tableView.reloadData()
    }
    
    func editConfirm(favorites: Favorites, indexPath: IndexPath?) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        if let index = indexPath {
            favoritesList.remove(at: index.row)
            favoritesList.insert(favorites, at: index.row)
            self.tableView.reloadData()
        }
    }
    
}
