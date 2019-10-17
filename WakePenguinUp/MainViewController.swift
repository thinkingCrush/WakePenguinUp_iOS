//
//  MainViewController.swift
//  WakePenguinUp
//
//  Created by 무릉 on 16/09/2019.
//  Copyright © 2019 lgbin. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import AudioToolbox
import SideMenu

class MainViewController : BaseViewController, WKUIDelegate {
    var webView : WKWebView!
    var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet weak var webContainerView: UIView!
    @IBOutlet weak var searchBarContainer: ARoundView!
    @IBOutlet weak var searchMenuContainer: UIView!
    @IBOutlet weak var searchBarPenguinImage: UIImageView!
    @IBOutlet weak var urlTextFiled: UITextField!
    @IBOutlet weak var mainContainerView: UIView!
    
    @IBOutlet weak var darkBackgroundView: UIView!
    @IBOutlet weak var favoritesStarImage: UIImageView!
    
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var emptyFavoritesView: UIView!
    @IBOutlet weak var webViewTopConstraint: NSLayoutConstraint!
    
    var lockButton : UIButton?
    var time = 4
    var timer = Timer()
    var startTimer = false
    
    var scrollContentOff : CGFloat = 0.0
    var isScrollingCheck = false
    
    let userDefault = UserDefaults.standard
    
    var viewConstraint : [NSLayoutConstraint] = []
    
    var lockView = LockView()
    
    var favoritesList : Array<Favorites> = []
    var favoritesName : String = ""
    
    var isFavoritesCheck = false
    
    var isInitStartCheck = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder()
        setNotification()
        setWebView()
        setLockView()
        setView()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
//        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setFavoritesList()
    }
    
    
    func setFavoritesList(){
        favoritesList = []
        let initAppSetting = userDefault.bool(forKey: "InitAppSetting")
        if initAppSetting {
            if let decoded = userDefault.data(forKey: "FavoritesData") {
                do{
                    let decodeList = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded) as! [Favorites]
                    decodeList.forEach { (item) in
                        favoritesList.append(item)
//                        favoritesUrlList.append(item.url)
                    }
                    if let item = decodeList.first {
                        emptyFavoritesView.isHidden = true
                        isFavoritesCheck = true
                        favoritesStarImage.image = UIImage(named: "icon_star_on")
                        let url = URL(string: item.url)
                        self.webView.load(URLRequest(url: url!))
                    }else {
                        if isInitStartCheck {
                            urlTextFiled.text = ""
                            favoritesStarImage.image = UIImage(named: "icon_star_off")
                            emptyFavoritesView.isHidden = false
                        }
                    }
                }catch {
                    if isInitStartCheck {
                        urlTextFiled.text = ""
                        favoritesStarImage.image = UIImage(named: "icon_star_off")
                        emptyFavoritesView.isHidden = false
                    }
                    print("error.")
                }
            }else {
                urlTextFiled.text = ""
                favoritesStarImage.image = UIImage(named: "icon_star_off")
                emptyFavoritesView.isHidden = false
            }
            
        }else {
            let dataList : [Favorites] = [
                Favorites(name: "유튜브", url: "https://m.youtube.com", thumbnailColor: UIColor.colorFromHex(15348515), thumbnailText: "Y"),
                Favorites(name: "네이버", url: "https://m.naver.com", thumbnailColor: UIColor.colorFromHex(6212714), thumbnailText: "N"),
                Favorites(name: "구글", url: "https://www.google.com", thumbnailColor: UIColor.colorFromHex(5473260), thumbnailText: "G")
            ]
            favoritesList = dataList
            
            do{
                let encodedData : Data = try NSKeyedArchiver.archivedData(withRootObject: dataList, requiringSecureCoding: false)
                userDefault.set(encodedData, forKey: "FavoritesData")
                userDefault.set(true, forKey: "InitAppSetting")
                userDefault.synchronize()
            }catch {
                
            }
            emptyFavoritesView.isHidden = false
            
        }
    }
    
    func setView(){
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        urlTextFiled.inputAccessoryView = toolbar
        //왼쪽 스와이프 이벤트
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.isInitStartCheck = false
        }
        
    }
    
    //왼쪽 스와이프시 사이드 메뉴 호출
    @objc func handleGesture(gesture : UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            self.moveSideMenu()
        }
    }
    
    //사이드 메뉴 호출
    func moveSideMenu(){
        let mainSB : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let sideMenuVC = mainSB.instantiateViewController(withIdentifier: "SideMenu") as? SideMenuNavigationController {
            if let vc = sideMenuVC.topViewController as? SideMenuViewController {
                vc.getUrlDelegate = self
            }
            self.present(sideMenuVC, animated: true, completion: nil)
        }
    }
    
    
    func setLockView(){
        lockView = LockView(frame: CGRect(x: self.view.frame.maxX / 2 - 40, y: self.view.frame.maxY - 100, width: 80, height: 80))
        view.addSubview(lockView)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView))
        lockView.isUserInteractionEnabled = true
        lockView.addGestureRecognizer(panGesture)
        
    }
    @objc func draggedView(_ sender:UIPanGestureRecognizer) {
        if let vc = UIApplication.topMostViewController{
            self.view.bringSubviewToFront(lockView)
            let translation = sender.translation(in: self.view)
            lockView.center = CGPoint(x: lockView.center.x + translation.x, y: lockView.center.y + translation.y)
            sender.setTranslation(CGPoint.zero, in: vc.view)
        }
        
    }
    @IBAction func favoritesAddAction(_ sender: UIButton) {
        if var text = urlTextFiled.text{
            
            if !(text.contains("http://") || text.contains("https://")) {
                text = "https://\(text)"
            }
            
            print(verifyUrl(urlString: text))
            if text == "" {
                Common.showToast(message: "URL 주소를 입력해주세요")
            }else if !verifyUrl(urlString: text){
                Common.showToast(message: "URL 형식을 입력하세요.")
            }else {
                view.endEditing(true)
                
                if view.viewWithTag(10000) == nil {
                    let popupView = RegisterPopupView()
                    popupView.tag = 10000
                    popupView.frame.size = CGSize(width: 300, height: 250)
                    popupView.center = view.center
                    popupView.alpha = 1
                    popupView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
                    
                    var urlName = ""
                    if text.components(separatedBy: ".").count < 2 {
                        urlName = "?"
                    }else {
                        urlName = text.components(separatedBy: ".")[1]
                    }
                    
                    let name = isFavoritesCheck ? favoritesName : urlName
                    popupView.setView(name: name, url: text, check: isFavoritesCheck)
                    popupView.delegate = self
                    self.view.addSubview(popupView)
                    
                    
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
                        self.darkBackgroundView.isHidden = false
                        self.darkBackgroundView.alpha = 0.8
                        
                        popupView.transform = .identity
                    })
                }
            }
        }
    }
    
    @IBAction func urlTextFieldChangeAction(_ sender: UITextField) {
        if let inputText = urlTextFiled.text {
            var lastRemoveUrl = inputText
            
            if let lastChar = lastRemoveUrl.last, lastChar == "/" {
                lastRemoveUrl.removeLast()
            }
            
            
            favoritesStarImage.image = UIImage(named: "icon_star_off")
            isFavoritesCheck = false
            favoritesName = ""
            favoritesList.forEach { (item) in
                if item.url == inputText || item.url == lastRemoveUrl{
                    favoritesStarImage.image = UIImage(named: "icon_star_on")
                    isFavoritesCheck = true
                    favoritesName = item.name
                }
            }
        }
    }
    
    @IBAction func urlTextFieldRetrunAction(_ sender: UITextField) {
        emptyFavoritesView.isHidden = true
        if let text = sender.text, !text.contains("http://"), !text.contains("https://") {
            sender.text = "https://\(text)"
            urlTextFiled.text = "https://\(text)"
        }
        if verifyUrl(urlString: sender.text) {
            let url = URL(string: sender.text ?? "")
            self.webView.load(URLRequest(url: url!))
            self.view.endEditing(true)
        }else {
            Common.showToast(message: "URL 형식을 입력하세요.")
        }
    }
    @IBAction func sideMenuAction(_ sender: Any) {
        self.view.endEditing(true)
        moveSideMenu()
    }
    
    func setNotification() {
        //관찰자 선언
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidBecomeVisible), name: UIWindow.didBecomeVisibleNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidBecomeHidden), name: UIWindow.didBecomeHiddenNotification, object: nil)
    }
    
    func setWebView(){
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        
        webView = WKWebView(frame: webContainerView.frame, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        webContainerView.addSubview(webView)
        
        if #available(iOS 11.0, *) {
            let safeArea = self.view.safeAreaLayoutGuide
            viewConstraint.append(webView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor))
            viewConstraint.append(webView.topAnchor.constraint(equalTo: webContainerView.topAnchor))
            viewConstraint.append(webView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor))
            viewConstraint.append(webView.bottomAnchor.constraint(equalTo: webContainerView.bottomAnchor))
            NSLayoutConstraint.activate(viewConstraint)
        }else {
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            webView.topAnchor.constraint(equalTo: searchBarContainer.bottomAnchor).isActive = true
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            webView.bottomAnchor.constraint(equalTo: webContainerView.bottomAnchor).isActive = true
        }
        
        self.webView.navigationDelegate = self
        self.webView.scrollView.delegate = self
        self.webView.allowsBackForwardNavigationGestures = true
//        let urlString = "https://www.youtube.com"
//
//        let url = URL(string: urlString)
//        self.webView.load(URLRequest(url: url!))
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if var urlString = urlString {
            // create NSURL instance
            if let url = URL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
    
    
    
    
    @objc func windowDidBecomeHidden(notification: NSNotification) {
        print("windowDidBecomeHidden")
        if let _ = UIApplication.topMostViewController as? MainViewController {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
                if let topController = UIApplication.topMostViewController{
                    topController.view.addSubview(self.lockView)
                }
            }
        }
        
    }
    
    @objc func windowDidBecomeVisible(notification: NSNotification) {
        print("windowDidBecomeVisible")
        if let _ = UIApplication.topMostViewController as? MainViewController {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
                if let topController = UIApplication.topMostViewController{
                    topController.view.addSubview(self.lockView)
                }
            }
        }
    }
    
    // We are willing to become first responder to get shake motion
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    func showLoding(){
        if view.viewWithTag(9999) == nil {
            activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
            activityIndicator.color = UIColor.blue
            activityIndicator.frame = CGRect(x: view.frame.midX-25, y: view.frame.midY-25, width: 50, height: 50)
            activityIndicator.hidesWhenStopped = true
            activityIndicator.startAnimating()
            activityIndicator.tag = 9999
            view.addSubview(activityIndicator)
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    func removeLoding(){
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    
    
}

extension MainViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        errorView.isHidden = true
        showLoding()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        removeLoding()
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        errorView.isHidden = false
        removeLoding()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        removeLoding()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        if let urlString = webView.url?.absoluteString {
            urlTextFiled.text = urlString
            var lastRemoveUrl = urlString
            var mobileUrl = urlString
            if lastRemoveUrl.last! == "/" {
                lastRemoveUrl.removeLast()
            }
            
            if urlString.contains("://m") {
                mobileUrl = mobileUrl.replacingOccurrences(of: "://m", with: "://www")
                if mobileUrl.last! == "/" {
                    mobileUrl.removeLast()
                }
            }
            
            
            favoritesStarImage.image = UIImage(named: "icon_star_off")
            isFavoritesCheck = false
            favoritesName = ""
            
            favoritesList.forEach { (item) in
                if item.url == urlString || item.url == lastRemoveUrl || item.url == mobileUrl{
                    favoritesStarImage.image = UIImage(named: "icon_star_on")
                    isFavoritesCheck = true
                    favoritesName = item.name
                }
            }
        }
        if navigationAction.request.url?.scheme == "tel" {
            UIApplication.shared.openURL(navigationAction.request.url!)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
}

extension MainViewController : UIScrollViewDelegate {
    //잠시 막아둠
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.contentOffset.y < 0 {
//            return
//        }
//        if scrollContentOff < scrollView.contentOffset.y {
//            if self.searchBarContainer.frame.origin.y == 0.0, !isInitStartCheck{
//                UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
//                    self.searchBarContainer.frame = CGRect(x: self.searchBarContainer.frame.origin.x , y: -44.0, width: self.searchBarContainer.frame.width, height: 44.0)
//                    self.searchBarContainer.alpha = 0.0
//
//                    self.webViewTopConstraint.constant = 0.0
//                    self.view.layoutIfNeeded()
//                }) { (result) in
//
//                }
//            }
//        }else {
//            if self.searchBarContainer.frame.origin.y == -44.0{
//                if !isScrollingCheck {
//                    isScrollingCheck = true
//                    UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
//                        self.searchBarContainer.frame = CGRect(x: self.searchBarContainer.frame.origin.x , y: 0.0, width: self.searchBarContainer.frame.width, height: 44.0)
//                        self.searchBarContainer.alpha = 1.0
//
//                        self.webViewTopConstraint.constant = 44.0
//                        self.view.layoutIfNeeded()
//
//                    }) { (result) in
//                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
//                            self.isScrollingCheck = false
//                        })
//                    }
//                }
//            }
//        }
//        scrollContentOff = scrollView.contentOffset.y
//
//    }
}

extension MainViewController : getURLProtocol {
    func getURL(url: String) {
        self.emptyFavoritesView.isHidden = true
        if !webView.isLoading {
            let url = URL(string: url)
            self.webView.load(URLRequest(url: url!))
        }
    }
}


extension MainViewController : popupConfirmProtocol {
    func cancel() {
    }
   func confirm(favorites: Favorites) {
        self.emptyFavoritesView.isHidden = true
        favoritesList.append(favorites)
        if let inputText = urlTextFiled.text {
            var lastRemoveUrl = inputText
            if lastRemoveUrl.last! == "/" {
                lastRemoveUrl.removeLast()
            }
            
            favoritesStarImage.image = UIImage(named: "icon_star_off")
            isFavoritesCheck = false
            favoritesName = ""
            favoritesList.forEach { (item) in
                if item.url == inputText || item.url == lastRemoveUrl {
                    favoritesStarImage.image = UIImage(named: "icon_star_on")
                    isFavoritesCheck = true
                    favoritesName = item.name
                }
            }
        }
    }
    
    func editConfirm(favorites: Favorites, indexPath: IndexPath?) {
        self.emptyFavoritesView.isHidden = true
        favoritesList.append(favorites)
        if let inputText = urlTextFiled.text {
            var lastRemoveUrl = inputText
            if lastRemoveUrl.last! == "/" {
                lastRemoveUrl.removeLast()
            }
            
            favoritesStarImage.image = UIImage(named: "icon_star_off")
            isFavoritesCheck = false
            favoritesName = ""
            favoritesList.forEach { (item) in
                if item.url == inputText || item.url == lastRemoveUrl {
                    favoritesStarImage.image = UIImage(named: "icon_star_on")
                    isFavoritesCheck = true
                    favoritesName = item.name
                }
            }
        }
    }
    
    
}