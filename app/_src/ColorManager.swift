//
//  ColorManager.swift
//  color clock
//
//  Created by Gregory Hutchinson on 9/26/15.
//  Copyright © 2015 DasHutch Development. All rights reserved.
//

import Foundation
import UIKit

class ColorManager: NSObject {
    
    func contrastingFontColorForColor(color: UIColor) -> UIColor {
        return color.isLight() ? UIColor.darkTextColor() : UIColor.lightTextColor()
    }
}