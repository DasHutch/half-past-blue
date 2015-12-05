//
//  AppDelegate+UserDefaults.swift
//  color clock
//
//  Created by Gregory Hutchinson on 12/5/15.
//  Copyright © 2015 DasHutch Development. All rights reserved.
//

import Foundation

/** UserDefaults Extends AppDelegate
    sets up UserDefaults
*/
extension AppDelegate {
    
    func registerUserDefaults() {
        
        let appDefaults = [
            UserDefaults.Keys.UseHexColors : NSNumber(bool: false),
            UserDefaults.Keys.FadeClockFaces : NSNumber(bool: false),
            UserDefaults.Keys.PrimaryClock : NSNumber(integer: ClockTypes.Digital.rawValue),
        ]
        
        NSUserDefaults.standardUserDefaults().registerDefaults(appDefaults)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}
