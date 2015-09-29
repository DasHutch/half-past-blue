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
    
    //MARK: - Public
    func contrastingFontColorForColor(color: UIColor) -> UIColor {
        return contrastingLightOrDarkColorForColor(color)
    }
    
    func contrastingLightOrDarkColorForColor(color: UIColor) -> UIColor {
        return color.isLight() ? UIColor.darkTextColor() : UIColor.lightTextColor()
    }
    
    func colorForHours(hours: Int, minutes: Int, seconds: Int) -> UIColor {
        
        let hueFromHours = adjustedHueValueFromHour(hours)
        let brightnessFromMinutes = adjustedBrightnessValueFromMinute(minutes)
        let saturationFromSeconds = adjustedSaturationValueFromSecond(seconds)
        
        let colorForTime = UIColor(hue: hueFromHours, saturation: saturationFromSeconds, brightness: brightnessFromMinutes, alpha: 1.0)
        
        return colorForTime
    }
    
    //MARK: - Private
    private func adjustedHueValueFromHour(currentHour: Int) -> CGFloat {
        
        let hoursDivisor: CGFloat = 24.0
        
        //NOTE: adjust upper/lower bounds to provide full 'hue' spectrum change across the day
        let upperClampBound: CGFloat = 1.0
        let lowerClampBound: CGFloat = 0.0
        
        //TODO: Will need to handle 24 or 12 for different locales
        var clampedHours = CGFloat(currentHour) / hoursDivisor
        if clampedHours > 1.0 || clampedHours < 0.0 {
            clampedHours = clamp(clampedHours, lower: lowerClampBound,  upper: upperClampBound)
        }
        
        return clampedHours
    }
    
    private func adjustedBrightnessValueFromMinute(currentMinute: Int) -> CGFloat {
        
        let minutesDivisor: CGFloat = 60.0
        
        let upperClampBound: CGFloat = 0.75
        let lowerClampBound: CGFloat = 0.25
        
        var clampedMinutes = CGFloat(currentMinute) / minutesDivisor
        if clampedMinutes > upperClampBound || clampedMinutes < lowerClampBound {
            clampedMinutes = clamp(clampedMinutes, lower: lowerClampBound,  upper: upperClampBound)
        }
        
        return clampedMinutes
    }
    
    private func adjustedSaturationValueFromSecond(currentSecond: Int) -> CGFloat {
        
        let secondsDivisor: CGFloat = 60.0
        
        //NOTE: Saturation - change upperBound
        //      (allow more saturation while still maintaining similar lowerBound clamp
        let upperClampBound: CGFloat = 0.9
        let lowerClampBound: CGFloat = 0.25
        
        var clampedSeconds = CGFloat(currentSecond) / secondsDivisor
        
        if clampedSeconds > upperClampBound || clampedSeconds < lowerClampBound {
            clampedSeconds = clamp(clampedSeconds, lower: lowerClampBound,  upper: upperClampBound)
        }
        
        return clampedSeconds
    }
}