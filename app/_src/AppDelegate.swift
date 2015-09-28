//
//  AppDelegate.swift
//  color clock
//
//  Created by Gregory Hutchinson on 9/24/15.
//  Copyright © 2015 DasHutch Development. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    //MARK: - Lifecycle
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
        setupLogging()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {}

    func applicationDidEnterBackground(application: UIApplication) {}

    func applicationWillEnterForeground(application: UIApplication) {}

    func applicationDidBecomeActive(application: UIApplication) {}

    func applicationWillTerminate(application: UIApplication) {}
    
    // MARK: - Private
    
    // MARK: Setup
    private func setupLogging() {
        
        //NOTE: Logger() manages its own setup
        //      just init it and you're good to go
        //USE:  the global `log` anywhere in app to
        //      log various messages, info, warning, errors, etc
        let _ = Logger()
    }
}
