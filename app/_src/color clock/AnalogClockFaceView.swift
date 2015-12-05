//
//  AnalogClockFaceView.swift
//  color clock
//
//  Created by Gregory Hutchinson on 9/28/15.
//  Copyright © 2015 DasHutch Development. All rights reserved.
//

import UIKit

@IBDesignable
class AnalogClockFaceView: UIView {
    
    @IBOutlet private var twelveOClockMarker: UIView!
    @IBOutlet private var threeOClockMarker: UIView!
    @IBOutlet private var sixOClockMarker: UIView!
    @IBOutlet private var nineOClockMarker: UIView!
    
    private struct Time {
        let hours: Int
        let minutes: Int
        let seconds: Int
    }
    
    private struct TimeViewPoints {
        //NOTE: Default these to center of view (self)
        let hoursFromPoint: CGPoint
        let minutesFromPoint: CGPoint
        let secondsFromPoint: CGPoint
        
        let hoursToPoint: CGPoint
        let minutesToPoint: CGPoint
        let secondsToPoint: CGPoint
    }
    
    private var timeViewPoints: TimeViewPoints?
    
    var hourHandLayer: CAShapeLayer?
    var minuteHandLayer: CAShapeLayer?
    var secondHandLayer: CAShapeLayer?
    
//MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    override func prepareForInterfaceBuilder() {        
        //NOTE: Give a fake time & color for IB
        updateCurrentHours(10, minutes: 23, seconds: 42)
        
        //!!!!: Crashes, markerViews are nil (IBOutlets) Why?
        //updateAnalogClockFaceAndHandsColor(UIColor.blueColor())
    }
    
//MARK: - Public
    func updateCurrentHours(hours: Int, minutes: Int, seconds: Int) {
        
        let currentTime = Time(hours: hours, minutes: minutes, seconds: seconds)

        let radius = radiusBasedOnDevicesOrientation()
        let time = timeCoords(bounds.midX, y: bounds.midY, time: currentTime, radius: radius)
        
        timeViewPoints = TimeViewPoints(hoursFromPoint: CGPoint(x: self.frame.midX, y: self.frame.midY),
            minutesFromPoint: CGPoint(x: self.frame.midX, y: self.frame.midY),
            secondsFromPoint: CGPoint(x: self.frame.midX, y: self.frame.midY),
            hoursToPoint: time.h,
            minutesToPoint: time.m,
            secondsToPoint: time.s)
        
        updateHourHand()
        updateMinuteHand()
        updateSecondsHand()
    }
    
    func updateAnalogClockFaceAndHandsColor(color: UIColor) {
        updateClockFaceHandsColor(color)
        updateClockFaceMarkersColor(color)
    }
    
//MARK: - Private
    private func config() {}
    
    private func updateClockFaceMarkersColor(color: UIColor) {
        
        twelveOClockMarker.backgroundColor = ColorManager().contrastingLightOrDarkColorForColor(color)
        threeOClockMarker.backgroundColor = ColorManager().contrastingLightOrDarkColorForColor(color)
        sixOClockMarker.backgroundColor = ColorManager().contrastingLightOrDarkColorForColor(color)
        nineOClockMarker.backgroundColor = ColorManager().contrastingLightOrDarkColorForColor(color)
    }
    
    private func updateClockFaceHandsColor(color: UIColor) {
        
        hourHandLayer?.strokeColor = ColorManager().contrastingLightOrDarkColorForColor(color).CGColor
        minuteHandLayer?.strokeColor = ColorManager().contrastingLightOrDarkColorForColor(color).CGColor
        secondHandLayer?.strokeColor = ColorManager().contrastingLightOrDarkColorForColor(color).CGColor
    }
    
    //NOTE: Need calculate the coordinates at which the hands are to be drawn from and to. The from is simple,
    //      it is the centre of the clock, which is also the centre of the UIView subclass. To calculate the
    //      "to position", I convert hours and minutes to a seconds representation and find the position along
    //      the circumference of a circle divided into 60 positions evenly spaced
    //
    //SEE:  http://sketchytech.blogspot.com/2014/11/swift-how-to-draw-clock-face-using_12.html?q=clock
    private func timeCoords(x:CGFloat, y:CGFloat, time: Time, radius:CGFloat, adjustment:CGFloat = 90) -> (h:CGPoint, m:CGPoint, s:CGPoint) {
        
        //NOTE: X Origin
        let cx = x
        //NOTE: Y Origin
        let cy = y
        
        //NOTE: Radius of Circle
        var r  = radius
        
        var points = [CGPoint]()
        var angle = degree2radian(6)
        func newPoint (t: Int) {
            
            let xpo = cx - r * cos(angle * CGFloat(t) + degree2radian(adjustment))
            let ypo = cy - r * sin(angle * CGFloat(t) + degree2radian(adjustment))
            points.append(CGPoint(x: xpo, y: ypo))
        }
        
        //NOTE: Determine if 24h time or not
        //      if yes, loop around (i.e minus 12)
        var hours = time.hours
        if hours > 12 {
            hours = hours - 12
        }
        
        r = radius * 0.50
        let hoursInSeconds = time.hours * 3600 + time.minutes * 60 + time.seconds
        newPoint(hoursInSeconds * 5 / 3600)
        
        //NOTE: Determine minutes second
        r = radius * 0.80
        let minutesInSeconds = time.minutes * 60 + time.seconds
        newPoint(minutesInSeconds / 60)
        
        //NOTE: Determine seconds last
        r = radius * 0.90
        newPoint(time.seconds)
        return (h:points[0], m:points[1], s:points[2])
    }
    
    private func updateHourHand() {
        
        hourHandLayer?.removeFromSuperlayer()
        hourHandLayer = nil
        
        //Hours
        let hourLayer = CAShapeLayer()
        hourLayer.frame = self.frame
        let path = CGPathCreateMutable()
        
        if timeViewPoints != nil {
            CGPathMoveToPoint(path, nil, CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
            CGPathAddLineToPoint(path, nil, timeViewPoints!.hoursToPoint.x, timeViewPoints!.hoursToPoint.y)
        }
        
        hourLayer.path = path
        hourLayer.lineWidth = 4
        hourLayer.lineCap = kCALineCapRound
        hourLayer.strokeColor = UIColor.blackColor().CGColor
        
        //see for rasterization advice http://stackoverflow.com/questions/24316705/how-to-draw-a-smooth-circle-with-cashapelayer-and-uibezierpath
        
        hourLayer.rasterizationScale = UIScreen.mainScreen().scale;
        hourLayer.shouldRasterize = true
        
        hourHandLayer = hourLayer
        self.layer.addSublayer(hourLayer)
    }
    
    private func updateMinuteHand() {
        
        minuteHandLayer?.removeFromSuperlayer()
        minuteHandLayer = nil
        
        //Minutes
        let minutesLayer = CAShapeLayer()
        minutesLayer.frame = self.frame
        let path = CGPathCreateMutable()
        
        if timeViewPoints != nil {
            CGPathMoveToPoint(path, nil, CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
            CGPathAddLineToPoint(path, nil, timeViewPoints!.minutesToPoint.x, timeViewPoints!.minutesToPoint.y)
        }
        
        minutesLayer.path = path
        minutesLayer.lineWidth = 4
        minutesLayer.lineCap = kCALineCapRound
        minutesLayer.strokeColor = UIColor.blackColor().CGColor
        
        //see for rasterization advice http://stackoverflow.com/questions/24316705/how-to-draw-a-smooth-circle-with-cashapelayer-and-uibezierpath
        
        minutesLayer.rasterizationScale = UIScreen.mainScreen().scale;
        minutesLayer.shouldRasterize = true
        
        minuteHandLayer = minutesLayer
        self.layer.addSublayer(minutesLayer)
    }
    
    private func updateSecondsHand() {
        
        secondHandLayer?.removeFromSuperlayer()
        secondHandLayer = nil
        
        //Seconds
        let secondsLayer = CAShapeLayer()
        secondsLayer.frame = self.frame
        let path = CGPathCreateMutable()
        
        if timeViewPoints != nil {
            CGPathMoveToPoint(path, nil, CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
            CGPathAddLineToPoint(path, nil, timeViewPoints!.secondsToPoint.x, timeViewPoints!.secondsToPoint.y)
        }
        
        secondsLayer.path = path
        secondsLayer.lineWidth = 4
        secondsLayer.lineCap = kCALineCapRound
        secondsLayer.strokeColor = UIColor.blackColor().CGColor
        
        //see for rasterization advice http://stackoverflow.com/questions/24316705/how-to-draw-a-smooth-circle-with-cashapelayer-and-uibezierpath
        
        secondsLayer.rasterizationScale = UIScreen.mainScreen().scale;
        secondsLayer.shouldRasterize = true
        
        secondHandLayer = secondsLayer
        self.layer.addSublayer(secondsLayer)
    }
    
    private func radiusBasedOnDevicesOrientation() -> CGFloat {
        
        let interfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        
        var widthOrHeighAsRadius = frame.width
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            widthOrHeighAsRadius = frame.height
        }
        
        return widthOrHeighAsRadius / 2
    }
}
