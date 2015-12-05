//
//  Degree2Radians.swift
//  color clock
//
//  Created by Gregory Hutchinson on 9/28/15.
//  Copyright © 2015 DasHutch Development. All rights reserved.
//

import Foundation
import UIKit

///Returns the input value (as degrees) to radians.
func degree2radian(a: CGFloat) -> CGFloat {
    let b = CGFloat(M_PI) * a / 180
    return b
}
