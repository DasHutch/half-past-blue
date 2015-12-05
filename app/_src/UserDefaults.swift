//
//  UserDefaults.swift
//  color clock
//
//  Created by Gregory Hutchinson on 12/5/15.
//  Copyright © 2015 DasHutch Development. All rights reserved.
//

import Foundation

/** UserDefaults Struct

*/
struct UserDefaults {
    
    struct Keys {
        static let UseHexColors = "use_hex_colors"
        static let PrimaryClock = "primary_clock_face"
        static let FadeClockFaces = "fade_clock_face"
    }
    
    struct InitialValues {
        static let UseHexColors = false
        static let PrimaryClock = ClockTypes.Digital
        static let FadeClockFaces = false
    }
}
