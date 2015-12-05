//
//  Clock.swift
//  color clock
//
//  Created by Gregory Hutchinson on 9/25/15.
//  Copyright © 2015 DasHutch Development. All rights reserved.
//

import Foundation

///Clock Object, represents time
class Clock: NSObject {
    
    var currentDate: NSDate {
        get {
            return NSDate()
        }
    }
    
    var hour: Int {
        get {
            let components = currentDateComponents()
            return components.hour
        }
    }
    
    var minute: Int {
        get {
            let components = currentDateComponents()
            return components.minute
        }
    }
    
    var second: Int {
        get {
            let components = currentDateComponents()
            return components.second
        }
    }
    
    var currentTimeString: String {
        get {
            let dateString = dateFormatter.stringFromDate(currentDate)
            return dateString
        }
    }
    
    private var dateFormatter: NSDateFormatter {
        //????: This is not getting called on didSet in the init func... why?!
        didSet {
            //dateFormatter.timeStyle = .MediumStyle
            
            //FIXME: Forcibly using 24h time
            //when I really just want to remove AM/PM if 12h time
            dateFormatter.dateFormat = "HH:mm:ss"
            dateFormatter.dateStyle = .NoStyle
            dateFormatter.timeZone = NSTimeZone.localTimeZone()
            dateFormatter.locale = NSLocale.currentLocale()
        }
    }
    
//MARK: - Lifecycle
    override init() {
        dateFormatter = NSDateFormatter()
        
        //dateFormatter.timeStyle = .MediumStyle
        dateFormatter.dateStyle = .NoStyle
        
        //FIXME: Forcibly using 24h time
        //when I really just want to remove AM/PM if 12h time
        dateFormatter.dateFormat = "HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.locale = NSLocale.currentLocale()
    }
    
//MARK: - Private
    private func currentDateComponents() -> NSDateComponents {
        
        let unitFlags: NSCalendarUnit = [.Hour, .Minute, .Second]
        let components = NSCalendar.currentCalendar().components(unitFlags, fromDate: currentDate)
        return components
    }
}