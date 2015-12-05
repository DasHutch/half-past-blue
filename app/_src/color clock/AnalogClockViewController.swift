//
//  AnalogColorClockViewController.swift
//  color clock
//
//  Created by Gregory Hutchinson on 9/24/15.
//  Copyright © 2015 DasHutch Development. All rights reserved.
//

//TODO: Test Logic...
// - If Clock Faces should be hidden
// -- dont swap (stay hidden)

// - If Primary Clock face is Digital
// -- always show that first (allow swapping)
// If Primary Clock face is Analog
// -- always show that first (allow swapping)

// If Reveal every Minute
// -- Clock face hidden (use primary face and reveal/hide)
// -- Clock Face Primary (use it and reveal / hide)

import UIKit
import QuartzCore

class AnalogColorClockViewController: UIViewController {
    
    @IBOutlet var analogClockFace: AnalogClockFaceView!
    @IBOutlet var colorView: UIView!
    
    var currentClockType: ClockTypes?
    var previousMinute: Int?
    
//MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //NOTE: Set current clock type to our app setting to start
        let clockType = NSUserDefaults.standardUserDefaults().integerForKey(UserDefaults.Keys.PrimaryClock)
        currentClockType = ClockTypes(rawValue: clockType)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
//MARK: - IBAction(s)

//MARK: - Gesture(s)
    
//MARK: - Private
    private func updateColorsForHours(hours: Int, minutes: Int, seconds: Int) {
        let colorForTime = ColorManager().colorForHours(hours, minutes: minutes, seconds: seconds)
        
        updateUIWithColor(colorForTime)
        updateAnalogClockFaceUI(forColor: colorForTime, hours: hours, minutes: minutes, seconds: seconds)
    }
    
    private func updateAnalogClockFaceUI(forColor color: UIColor, hours: Int, minutes: Int, seconds: Int) {
        analogClockFace.updateCurrentHours(hours, minutes: minutes, seconds: seconds)
        analogClockFace.updateAnalogClockFaceAndHandsColor(color)
    }
    
    private func updateUIWithColor(color: UIColor) {
        colorView.backgroundColor = color
    }
    
//MARK: Animation(s)
    
    //TODO: Fix all and cleanup now its just handling one clock type
    private func fadeInClockFace() {
        
        let animationDuration: NSTimeInterval = 0.5
        let animationDelay: NSTimeInterval = 0.0
        let animationOption: UIViewAnimationOptions = UIViewAnimationOptions.CurveEaseIn
        
        let visibleAlpha: CGFloat = 1.0
        let hiddenAlpha: CGFloat = 0.0
        
        var currentClockFace: UIView?
        if currentClockType != nil {
            switch currentClockType! {
            case ClockTypes.None:
                currentClockFace = analogClockFace
            case ClockTypes.Digital:
                currentClockFace = analogClockFace
            case ClockTypes.Analog:
                currentClockFace = analogClockFace
            }
        }
        
        UIView.animateWithDuration(animationDuration, delay: animationDelay, options: animationOption, animations: { () -> Void in
            log.verbose("Fading In Clock Face")
            
            log.verbose("\(currentClockFace)")
            currentClockFace?.alpha = visibleAlpha
            
            }, completion: { (finished) -> Void in
                log.verbose("Finished Fading In Clock Face")
                self.fadeOutClockFace()
        })
    }
    
    //TODO: Fix all and cleanup now its just handling one clock type
    private func fadeOutClockFace() {
        
        let animationDuration: NSTimeInterval = 0.5
        let animationDelay: NSTimeInterval = 10.0 //Delay, before fading clock out again
        let animationOption: UIViewAnimationOptions = UIViewAnimationOptions.CurveEaseIn
        
        let visibleAlpha: CGFloat = 1.0
        let hiddenAlpha: CGFloat = 0.0
        
        var currentClockFace: UIView?
        if currentClockType != nil {
            switch currentClockType! {
            case ClockTypes.None:
                currentClockFace = analogClockFace
            case ClockTypes.Digital:
                currentClockFace = analogClockFace
            case ClockTypes.Analog:
                currentClockFace = analogClockFace
            }
        }
        
        UIView.animateWithDuration(animationDuration, delay: animationDelay, options: animationOption, animations: { () -> Void in
            log.verbose("Fading Out Clock Face")
            
            log.verbose("\(currentClockFace)")
            currentClockFace?.alpha = hiddenAlpha
            
            }, completion: { (finished) -> Void in
                log.verbose("Finished Fading Out Clock Face")
        })
    }
}

extension AnalogColorClockViewController: TellsTime {
    func updateTimeForClock(clock: Clock) {
        updateColorsForHours(clock.hour, minutes: clock.minute, seconds: clock.second)
    }
}
