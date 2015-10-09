//
//  ColorClockViewController.swift
//  color clock
//
//  Created by Gregory Hutchinson on 9/24/15.
//  Copyright © 2015 DasHutch Development. All rights reserved.
//

import UIKit
import iAd
import QuartzCore

//TODO: App Setting based on In App Purchase to configAds or not

class ColorClockViewController: UIViewController {
    
    @IBOutlet weak var digitalClockFace: DigitalClockFaceView!
    @IBOutlet weak var analogClockFace: AnalogClockFaceView!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var colorViewBottomConstraint: NSLayoutConstraint!
    
    lazy var displayLink = CADisplayLink()
    let clock: Clock = Clock()
    
    //????: Is there a bettter way to approach this
    //      Want to 'store' enum value in UserDefaults
    //      and convert it back out when I grab it...
    var primaryClockType: ClockTypes {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            guard let primaryClockType = defaults.valueForKey(UserDefaultsKeys.PrimaryClock) as? String else {
                return ClockTypes.Digital
            }
            
            switch Int(primaryClockType)! {
            case ClockTypes.Digital.rawValue:
                return ClockTypes.Digital
            case ClockTypes.Analog.rawValue:
                return ClockTypes.Analog
            case ClockTypes.None.rawValue:
                return ClockTypes.None
            default:
               return ClockTypes.Digital
            }
        }
    }

    let notificationCenter = NSNotificationCenter.defaultCenter()
    var awefObserver: NSObjectProtocol?
    
    var bannerIsVisible: Bool = false
    var adBanner: ADBannerView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configAndRunDisplayLink()
        configAdBanner()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updatePrimaryClockFace()
        
        awefObserver = notificationCenter.addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: nil) { (notification) -> Void in
            self.updatePrimaryClockFace()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if awefObserver != nil {
            notificationCenter.removeObserver(awefObserver!)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    deinit {
        deconfigAndStopDisplayLink()
    }
    
    //MARK: - IBAction(s)
    @IBAction func handleInfoButtonTapped(sender: UIButton) {
        
        //TODO: Refactor / Clean up
        let storyboard = UIStoryboard(name: "TipJar", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()
        vc?.modalPresentationStyle = .Popover
        vc?.preferredContentSize = CGSize(width: view.bounds.size.width - 40, height: view.bounds.size.height / 2)
                
        let ppc = vc?.popoverPresentationController
        ppc?.sourceView = sender
        
        presentViewController(vc!, animated: true, completion: nil)
    }
    
    @IBAction func handleDoubleTap(sender: UITapGestureRecognizer) {
        switch primaryClockType {
        case ClockTypes.None:
            log.info("Primary Clock Type is `None` - We can't swap between `None` Clock Faces")
        case ClockTypes.Digital:
            fallthrough
        case ClockTypes.Analog:
            swapClockFaceTypes()
        }
    }
    
    @IBAction func handleSingleTap(sender: UITapGestureRecognizer) {
        switch primaryClockType {
        case ClockTypes.None:
            fadeInOutClockFace(digitalClockFace)
        case ClockTypes.Digital:
            fallthrough
        case ClockTypes.Analog:
            log.info("Single Tap for `Digital` & `Analog` is not Supported (yet). As Single Tap is explicitly to reveal a hidden clock")
            //TODO: If fade is on and the clock is 'faded' manually reveal
        }
    }
    
    //MARK: - Gesture(s)
        //NOTE: Handled with IBAction & doesn't need a delegate

    // MARK: - Private
    private func configAdBanner() {
        
        //NOTE: Check if already purchased - remove ads
        let isRemoveAdsPurchased = NSUserDefaults.standardUserDefaults().boolForKey("isRemoveAdsPurchased")
        if isRemoveAdsPurchased {
            log.info("User has already purchased - remove ads. Do NOT show them")
            return
        }
        
        //NOTE: Err on side of caution, if products cannot be retrieved
        //      do not show ads at all
        if InAppPurchaseManager.sharedManager.products?.count > 0 {
            log.info("Products have not been downloaded yet, erring on side of UX and do not show ads")
            return
        }
        
        adBanner = ADBannerView(adType: ADAdType.Banner)
        
        if adBanner != nil {
            adBanner!.delegate = self
            
            let origin = CGPoint(x: view.bounds.minX, y: view.bounds.maxY)
            adBanner!.frame = CGRect(origin: origin, size: adBanner!.bounds.size)
        }
    }
    
    private func updatePrimaryClockFace() {

        switch primaryClockType {
        case ClockTypes.Digital:
            hideAnalogClock()
            showDigitalClock()
        case ClockTypes.Analog:
            hideDigitalClock()
            showAnalogClock()
        case ClockTypes.None:
            hideClocks()
        }
    }
    
    private func hideClocks() {
        hideDigitalClock()
        hideAnalogClock()
    }
    
    private func hideDigitalClock() {
        digitalClockFace.hidden = true
    }
    
    private func hideAnalogClock() {
        analogClockFace.hidden = true
    }

    private func showDigitalClock() {
        digitalClockFace.hidden = false
    }
    
    private func showAnalogClock() {
        analogClockFace.hidden = false
    }
    
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
        
        //TODO: if fade is turned on, only reveal the clock five minutes every minute
        //      then fade out to nothing
        
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
        infoButton.tintColor = ColorManager().contrastingFontColorForColor(color)
    }

    //MARK: Animation(s)
    private func fadeInOutClockFace(clockFace: UIView) {
        
        let fadeInDuration: NSTimeInterval = 0.5
        let fadeInDelay: NSTimeInterval = 0.0
        let fadeOutDuration: NSTimeInterval = 0.5
        let fadeOutDelay: NSTimeInterval = 5.0
        let animationOption: UIViewAnimationOptions = UIViewAnimationOptions.CurveEaseIn
        
        let visibleAlpha: CGFloat = 1.0
        let hiddenAlpha: CGFloat = 0.0
        
        //NOTE: Make sure the clock is not hidden, so we can
        //      see the fade in
        clockFace.alpha = hiddenAlpha
        clockFace.hidden = false
        
        UIView.animateWithDuration(fadeInDuration, delay: fadeInDelay, options: animationOption, animations: { () -> Void in
            
            clockFace.alpha = visibleAlpha
            
        }, completion: { (finished) -> Void in
                
            UIView.animateWithDuration(fadeOutDuration, delay: fadeOutDelay, options: animationOption, animations: { () -> Void in
                
                clockFace.alpha = hiddenAlpha
                
            }, completion: { (finished) -> Void in
                
                clockFace.hidden = true
            })
        })
    }
    
    private func swapClockFaceTypes() {
        
        if primaryClockType == ClockTypes.None {
            log.warning("Primary Clock Type is `None` - We can't swap between `None` Clock Faces")
            return
        }

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

extension ColorClockViewController: ADBannerViewDelegate {
    func bannerViewWillLoadAd(banner: ADBannerView!) {}
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        if (!bannerIsVisible) {
            
            // If banner isn't part of view hierarchy, add it
            if (adBanner?.superview == nil) {
                view.addSubview(adBanner!)
            }
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                
                // Assumes the banner view is just off the bottom of the screen.
                banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height)
                self.colorViewBottomConstraint.constant = banner.frame.size.height
                self.view.layoutIfNeeded()
                
            }, completion: { (completed) -> Void in
                self.bannerIsVisible = true
            })
        }
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        return true
    }
    
    func bannerViewActionDidFinish(banner: ADBannerView!) {}
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        if (bannerIsVisible) {

            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                
                // Assumes the banner view is just off the bottom of the screen.
                banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height)
                self.colorViewBottomConstraint.constant = 0
                self.view.layoutIfNeeded()
                
                }, completion: { (completed) -> Void in
                    self.bannerIsVisible = false
            })
        }
    }
}
