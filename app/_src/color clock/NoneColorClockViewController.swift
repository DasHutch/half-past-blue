//
//  NoneColorClockViewController.swift
//  color clock
//
//  Created by Gregory Hutchinson on 9/24/15.
//  Copyright © 2015 DasHutch Development. All rights reserved.
//

import UIKit
import QuartzCore

class NoneColorClockViewController: UIViewController {
    
    @IBOutlet weak var colorView: UIView!
        
//MARK: - Lifecycle
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

//MARK: - IBAction(s)
    
//MARK: - Gesture(s)

//MARK: - Private
    private func updateColorsForHours(hours: Int, minutes: Int, seconds: Int) {
        let colorForTime = ColorManager().colorForHours(hours, minutes: minutes, seconds: seconds)
        updateUIWithColor(colorForTime)
    }
    
    private func updateUIWithColor(color: UIColor) {
        colorView.backgroundColor = color
    }
}

extension NoneColorClockViewController: TellsTime {
    func updateTimeForClock(clock: Clock) {
        updateColorsForHours(clock.hour, minutes: clock.minute, seconds: clock.second)
    }
}
