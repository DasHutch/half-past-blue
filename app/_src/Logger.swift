
//
//  Logger.swift
//  color clock
//
//  Created by Gregory Hutchinson on 9/27/15.
//  Copyright © 2015 DasHutch Development. All rights reserved.
//

import Foundation

//NOTE: Create global 'log' instance
//      this allows, more refined logging
//      based on build - set log level (verbose, warn, error, etc)
let log = XCGLogger.defaultInstance()

struct Logger {
    
    init() {
        setup()
    }
    
    private func setup() {

        let env = NSProcessInfo.processInfo().environment
        if env["environment"] == "development" {
            
            //NOTE: Development environment, use 'verbose` log level
            log.setup(.Verbose, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLogLevel: nil)
        }else {
            
            //NOTE: Production environment, use 'warning` log level
            log.setup(.Warning, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLogLevel: nil)
        }
    }
}
