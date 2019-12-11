//
//  AppDelegate.swift
//  WakePenguinUp
//
//  Created by 무릉 on 05/09/2019.
//  Copyright © 2019 lgbin. All rights reserved.
//

import UIKit
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static var isLock = false

    var shouldSupportAllOrientation = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Thread.sleep(forTimeInterval: 0.7)
        
        let navigationBarApperace = UINavigationBar.appearance()
        navigationBarApperace.tintColor = UIColor.black
        navigationBarApperace.isTranslucent = true //반투명 제거
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        navigationBarApperace.titleTextAttributes = textAttributes
        
//        투명 상태바 설정
        navigationBarApperace.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        navigationBarApperace.shadowImage = UIImage()
//        navigationBarApperace.backgroundColor = UIColor.clear
        
        //구글 광고 시작
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        let userDefault = UserDefaults.standard
        
        if userDefault.bool(forKey: "isStartApp") {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "MainNaviVC")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
            return true
        }else {
            return true
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //화면회전을 잠그고 고정할 목적의 플래그 변수를 추가한다.
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if (shouldSupportAllOrientation == true){
            return UIInterfaceOrientationMask.all
            }
        return UIInterfaceOrientationMask.portrait
        
    }

}

