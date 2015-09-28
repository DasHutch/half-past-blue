//
//  ColorClockViewController.swift
//  color clock
//
//  Created by Gregory Hutchinson on 9/24/15.
//  Copyright © 2015 DasHutch Development. All rights reserved.
//

//TODO:
// - Analog Clock Face
// - Double Tap (Alert to educate on swapping digital / analog)
// - ColorManager Class for handling color choices from a NSDate
// - Use MonoSpace font -- DONE
// - Hide Status Bar -- DONE
// - Create Clock Model (refactor) -- DONE
// - Write UI Tests
// - Write Unit Tests

import UIKit
import QuartzCore

class ColorClockViewController: UIViewController {
    
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    
    lazy var displayLink = CADisplayLink()
    let clock: Clock = Clock()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configAndRunDisplayLink()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    deinit {
        displayLink.invalidate()
        displayLink.removeFromRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }

    // MARK: - Private
    private func configAndRunDisplayLink() {
        
        //NOTE: Run our Clock from our display refresh rate vs NSTimer (more accurate)
        displayLink = CADisplayLink(target: self, selector: Selector("updateClock"))
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    func updateClock() {
        
        updateCurrentDateLabel(clock.currentTimeString)
        updateColorsForHours(clock.hour, minutes: clock.minute, seconds: clock.second)
    }
    
    private func updateCurrentDateLabel(dateString: String) {
        currentDateLabel.text = dateString
    }
    
    private func updateColorsForHours(hours: Int, minutes: Int, seconds: Int) {
        
        //TODO: Refactor to ColorManager?
        let hueFromHours = adjustedHueValueFromHour(hours)
        let brightnessFromMinutes = adjustedBrightnessValueFromMinute(minutes)
        let saturationFromSeconds = adjustedSaturationValueFromSecond(seconds)
        
        let colorForTime = UIColor(hue: hueFromHours, saturation: saturationFromSeconds, brightness: brightnessFromMinutes, alpha: 1.0)
        updateUIWithColor(colorForTime)
    }
    
    //TODO: Refactor to ColorManager?
    private func adjustedHueValueFromHour(currentHour: Int) -> CGFloat {
        
        let hoursDivisor: CGFloat = 24.0
        
        //NOTE: adjust upper/lower bounds to provide full 'hue' spectrum change across the day
        let upperClampBound: CGFloat = 1.0
        let lowerClampBound: CGFloat = 0.0
        
        //Hours (12) //NOTE: Will need to handle 24 or 12 for different locales
        var clampedHours = CGFloat(currentHour) / hoursDivisor
        if clampedHours > 1.0 || clampedHours < 0.0 {
            clampedHours = clamp(clampedHours, lower: lowerClampBound,  upper: upperClampBound)
        }
        
        return clampedHours
    }
    
    //TODO: Refactor to ColorManager?
    private func adjustedBrightnessValueFromMinute(currentMinute: Int) -> CGFloat {
        
        let minutesDivisor: CGFloat = 60.0
        
        let upperClampBound: CGFloat = 0.75
        let lowerClampBound: CGFloat = 0.25

        //Minutes (60)
        var clampedMinutes = CGFloat(currentMinute) / minutesDivisor
        if clampedMinutes > upperClampBound || clampedMinutes < lowerClampBound {
            clampedMinutes = clamp(clampedMinutes, lower: lowerClampBound,  upper: upperClampBound)
        }
        
        return clampedMinutes
    }
    
    //TODO: Refactor to ColorManager?
    private func adjustedSaturationValueFromSecond(currentSecond: Int) -> CGFloat {
        
        let secondsDivisor: CGFloat = 60.0
        
        //NOTE: Saturation - change upperBound (allow more saturation while still maintaining similar lowerBound clamp
        let upperClampBound: CGFloat = 0.9
        let lowerClampBound: CGFloat = 0.25

        //Seconds (60)
        var clampedSeconds = CGFloat(currentSecond) / secondsDivisor
        
        if clampedSeconds > upperClampBound || clampedSeconds < lowerClampBound {
            clampedSeconds = clamp(clampedSeconds, lower: lowerClampBound,  upper: upperClampBound)
        }
        
        return clampedSeconds
    }
    
    private func updateUIWithColor(color: UIColor) {
        
        updateDateLabelTextColorBasedOnColor(color)
        updateColorViewColor(color)
    }

    private func updateDateLabelTextColorBasedOnColor(color: UIColor) {

        //NOTE: Update our Label Color based on BG color brightness
        currentDateLabel.textColor = ColorManager().contrastingFontColorForColor(color)
    }
    
    private func updateColorViewColor(color: UIColor) {
        colorView.backgroundColor = color
    }
}
