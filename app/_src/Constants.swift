//
//  Constants.swift
//  color clock
//
//  Created by Gregory Hutchinson on 9/28/15.
//  Copyright © 2015 DasHutch Development. All rights reserved.
//

import Foundation

struct UserDefaultsKeys {
    static let UseHexColors = "use_hex_colors"
    static let PrimaryClock = "primary_clock_face"
    static let FadeClockFaces = "fade_clock_face"
}

enum ClockTypes: Int {
    case Digital = 0
    case Analog
    case None
}
