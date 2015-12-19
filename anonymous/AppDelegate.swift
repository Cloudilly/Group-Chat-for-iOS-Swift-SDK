//
//  AppDelegate.swift
//  anonymous
//
//  Created by Zhongcai Ng on 18/12/15.
//  Copyright © 2015 Cloudilly Private Limited. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var viewController: ViewController?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.backgroundColor = UIColor.clearColor()
        let viewController = ViewController()
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(application: UIApplication) { }
    func applicationDidEnterBackground(application: UIApplication) { }
    func applicationWillEnterForeground(application: UIApplication) { }
    func applicationDidBecomeActive(application: UIApplication) { }
    func applicationWillTerminate(application: UIApplication) { }
}