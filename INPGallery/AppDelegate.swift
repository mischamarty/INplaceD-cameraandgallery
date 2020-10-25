//
//  AppDelegate.swift
//  INPGallery
//
//  Created by mischa on 19/06/2019.
//  Copyright © 2019 mischa. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let colorNormal : UIColor = UIColor.black
        let colorSelected : UIColor = UIColor.black
        let titleFontAll : UIFont = UIFont(name: "Verdana", size: 16.0)!
        
        let attributesNormal = [
            NSAttributedString.Key.foregroundColor : colorNormal,
            NSAttributedString.Key.font : titleFontAll
        ]
        
        let attributesSelected = [
            NSAttributedString.Key.foregroundColor : colorSelected,
            NSAttributedString.Key.font : titleFontAll
        ]
        
        let greyLightTransparent =  UIColor(red: 238/255, green: 240/255, blue: 244/255, alpha: 0.75)
        let grey =  UIColor(red: 114/255, green: 111/255, blue: 116/255, alpha: 1.0)


        
        
        
        UIBarButtonItem.appearance().setTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 0), for: UIBarMetrics.default)
        UIBarButtonItem.appearance().setTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 5), for: UIBarMetrics.compact)


        
        //--
        UINavigationBar.appearance().tintColor = UIColor.black
        UINavigationBar.appearance().barTintColor = greyLightTransparent
        UINavigationBar.appearance().isTranslucent = false
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.font: titleFontAll, NSAttributedString.Key.foregroundColor: UIColor.black]
        //--
        
        UITabBarItem.appearance().setTitleTextAttributes(attributesNormal, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(attributesSelected, for: .selected)
        
        //hair line 0.5 px on grey color !!!
        //UITabBar.appearance().backgroundImage = getImageWithColor(color: greyLightTransparent, size: CGSize(width: 0.5, height: 0.5))
        
        //UITabBar.appearance().backgroundColor = UIColor.black
        
        //UITabBar.appearance().shadowImage = getImageWithColor(color: Colors.grey, size: CGSize(width: 0.5, height: 0.5));
        //UITabBar.appearance().shadowImage = getImageWithColor(color: Colors.grey, size: CGSize(width: 1, height: 1));
        UITabBar.appearance().shadowImage = UIImage(named:"1x1")
        return true
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


}

