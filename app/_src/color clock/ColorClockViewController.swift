//
//  ColorClockViewController.swift
//  color clock
//
//  Created by Gregory Hutchinson on 9/24/15.
//  Copyright © 2015 DasHutch Development. All rights reserved.
//

import UIKit
import QuartzCore

class ColorClockViewController: UIViewController {
    
    @IBOutlet weak var digitalClockFace: DigitalClockFaceView!
    @IBOutlet weak var analogClockFace: AnalogClockFaceView!
    
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
        deconfigAndStopDisplayLink()
    }
    
    //MARK: - IBAction(s)
    @IBAction func handleDoubleTap(sender: UITapGestureRecognizer) {
        swapClockFaceTypes()
    }
    
    //MARK: - Gesture(s)
        //NOTE: Handled with IBAction & doesn't need a delegate

    // MARK: - Private
    private func configAndRunDisplayLink() {
        //NOTE: Run our Clock from our display refresh rate vs NSTimer (more accurate)
        displayLink = CADisplayLink(target: self, selector: Selector("updateClock"))
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    private func deconfigAndStopDisplayLink() {
        displayLink.invalidate()
        displayLink.removeFromRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    //NOTE: As this is being called by displayLink,
    //      we can't mark as private, even though is should be
    internal func updateClock() {
        updateColorsForHours(clock.hour, minutes: clock.minute, seconds: clock.second)
    }
    
    private func updateColorsForHours(hours: Int, minutes: Int, seconds: Int) {
        let colorForTime = ColorManager().colorForHours(hours, minutes: minutes, seconds: seconds)
        
        updateUIWithColor(colorForTime)
        updateDigitalClockFaceUI(forColor: colorForTime)
        updateAnalogClockFaceUI(forColor: colorForTime)
    }
    
    private func updateDigitalClockFaceUI(forColor color: UIColor) {
        digitalClockFace.updateCurrentHours(clock.hour, minutes: clock.minute, seconds: clock.second)
        digitalClockFace.updateCurrentTimeString(clock.currentTimeString)
        digitalClockFace.updateDigitalClockFontColor(color)
    }
    
    private func updateAnalogClockFaceUI(forColor color: UIColor) {
        analogClockFace.updateCurrentHours(clock.hour, minutes: clock.minute, seconds: clock.second)
        analogClockFace.updateAnalogClockFaceAndHandsColor(color)
    }
    
    private func updateUIWithColor(color: UIColor) {
        colorView.backgroundColor = color
    }

    //MARK: Animation(s)
    private func swapClockFaceTypes() {
        
        let animationDuration: NSTimeInterval = 0.5
        let animationDelay: NSTimeInterval = 0.0
        let animationOption: UIViewAnimationOptions = UIViewAnimationOptions.CurveEaseIn
        
        let visibleAlpha: CGFloat = 1.0
        let hiddenAlpha: CGFloat = 0.0
        
        if digitalClockFace.hidden {
            
            UIView.animateWithDuration(animationDuration, delay: animationDelay, options: animationOption, animations: { () -> Void in
                
                self.digitalClockFace.alpha = visibleAlpha
                self.analogClockFace.alpha = hiddenAlpha
                
            }, completion: { (finished) -> Void in
                
                self.digitalClockFace.hidden = !self.digitalClockFace.hidden
                self.analogClockFace.hidden = !self.analogClockFace.hidden
            })

        }else {
            
            UIView.animateWithDuration(animationDuration, delay: animationDelay, options: animationOption, animations: { () -> Void in
                
                self.digitalClockFace.alpha = hiddenAlpha
                self.analogClockFace.alpha = visibleAlpha
                
            }, completion: { (finished) -> Void in
                
                self.digitalClockFace.hidden = !self.digitalClockFace.hidden
                self.analogClockFace.hidden = !self.analogClockFace.hidden
            })
        }
    }
}
