//
//  AppDelegate+Logging.swift
//  color clock
//
//  Created by Gregory Hutchinson on 12/5/15.
//  Copyright © 2015 DasHutch Development. All rights reserved.
//

import Foundation

/** Logging Extends AppDelegate
    sets up logging, log level
*/
extension AppDelegate {
    
    func setupLogging() {
        
        //NOTE: Logger() manages its own setup
        //      just init it and you're good to go
        
        //USE:  the global `log` anywhere in app to
        //      log various messages, info, warning, errors, etc
        let _ = Logger()
    }
}
