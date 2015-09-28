//
//  DigitalClockFaceView.swift
//  color clock
//
//  Created by Gregory Hutchinson on 9/28/15.
//  Copyright © 2015 DasHutch Development. All rights reserved.
//

import UIKit

class DigitalClockFaceView: UIView {
    
    @IBOutlet private weak var currentDateLabel: UILabel!
    
    //MARK: Public
    func updateCurrentHours(hours: Int, minutes: Int, seconds: Int) {
        let timeString = "\(hours):\(minutes):\(seconds)"
        updateCurrentDateLabel(timeString)
    }
    
    func updateCurrentTimeString(timeString: String) {
        updateCurrentDateLabel(timeString)
    }
    
    func updateDigitalClockFontColor(color: UIColor) {
        updateDateLabelTextColorBasedOnColor(color)
    }
    
    //MARK: - Private
    private func updateCurrentDateLabel(dateString: String) {
        currentDateLabel.text = dateString
    }
    
    private func updateDateLabelTextColorBasedOnColor(color: UIColor) {
        currentDateLabel.textColor = ColorManager().contrastingFontColorForColor(color)
    }
}
