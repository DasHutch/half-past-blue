//
//  Storyboards.swift
//  color clock
//
//  Created by Gregory Hutchinson on 12/5/15.
//  Copyright © 2015 DasHutch Development. All rights reserved.
//

import Foundation

/** Storyboards Struct

*/
struct Storyboards {
    static let Launch = "LaunchScreen"
    static let Main = "Main"
    static let NoneClock = "NoneClock"
    static let AnalogClock = "AnalogClock"
    static let DigitalClock = "DigitalClock"
    
    struct Identifiers {
        static let LaunchInitialVC = "launch_screen_vc"
        static let MainInitialVC = "clocks_vc"
        static let NoneClockInitialVC = "none_color_clock_vc"
        static let AnalogClockInitialVC = "digital_color_clock_vc"
        static let DigitalClockIntialVC = "analog_color_clock_vc"
    }
}
