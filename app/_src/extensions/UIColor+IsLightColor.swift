//
//  UIColor+IsLightColor.swift
//  color clock
//
//  Created by Gregory Hutchinson on 9/24/15.
//  Copyright © 2015 DasHutch Development. All rights reserved.
//

import UIKit

/** IsLightColor Extends UIColor

*/
extension UIColor {
    func isLight() -> Bool {
        let components = CGColorGetComponents(self.CGColor)
        
        let red = components[0]
        let green = components[1]
        let blue = components[2]
        
        let brightness = ((red * 299) + (green * 587) + (blue * 114)) / 1000
        
        if brightness < 0.5 {
            return false
        }else {
            return true
        }
    }
}