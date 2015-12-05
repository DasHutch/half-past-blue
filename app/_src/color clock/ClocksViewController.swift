//
//  ClocksViewController.swift
//  color clock
//
//  Created by Gregory Hutchinson on 12/5/15.
//  Copyright © 2015 DasHutch Development. All rights reserved.
//

import UIKit

protocol TellsTime {
    func updateTimeForClock(clock: Clock)
}

///Manage all various *ClockFaceViewController(s) and when to display them
class ClocksViewController: UIPageViewController {
    
    private var clockViewControllerIdentifiers = [ClockVCIdentifiers]()
    
    private enum ClockVCIdentifiers: String {
        case None = "none_color_clock_vc"
        case Digital = "digital_color_clock_vc"
        case Analog = "analog_color_clock_vc"
    }
    
    lazy var displayLink = CADisplayLink()
    let clock: Clock = Clock()

//MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configDataSource()
        configDelegate()
        
        configAndRunDisplayLink()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupClockViewControllers()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        clockViewControllerIdentifiers = [ClockVCIdentifiers]()
    }

    deinit {
        deconfigAndStopDisplayLink()
    }

//MARK: - IBAction(s)
    
//MARK: - Gesture(s)

//MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {}
    
//MARK: - Public

//MARK: - Private
    private func configDataSource() {
        //NOTE: Some reason IB doesn't allow this...
        //      so doing it here instead.
        dataSource = self
    }
    
    private func configDelegate() {
        //NOTE: Some reason IB doesn't allow this...
        //      so doing it here instead.
        delegate = self
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
        //updateColorsForHours(clock.hour, minutes: clock.minute, seconds: clock.second)
        if let currentClockVC = viewControllers?[0] as? TellsTime {
            currentClockVC.updateTimeForClock(clock)
        }
        
        let colorForTime = ColorManager().colorForHours(clock.hour, minutes: clock.minute, seconds: clock.second)
        view.backgroundColor = colorForTime
    }
    
    private func setupClockViewControllers() {
        
        //NOTE: Create our ClockVCs and populate our array
        clockViewControllerIdentifiers = [ClockVCIdentifiers.Digital, ClockVCIdentifiers.Analog, ClockVCIdentifiers.None]

        //NOTE: Set current clock type to our App Setting
        let clockType = NSUserDefaults.standardUserDefaults().integerForKey(UserDefaults.Keys.PrimaryClock)
        let currentClockType = ClockTypes(rawValue: clockType)
        
        switch currentClockType! {
        case ClockTypes.None:
            let noneClockVC = instantiateNoneClockVC()
            setInitialClockViewControllerForClockType(noneClockVC, clockType: currentClockType)
        case ClockTypes.Digital:
            let digitalClockVC = instantiateDigitalClockVC()
            setInitialClockViewControllerForClockType(digitalClockVC, clockType: currentClockType)
        case ClockTypes.Analog:
            let analogClockVC = instantiateAnalogClockVC()
            setInitialClockViewControllerForClockType(analogClockVC, clockType: currentClockType)
        }
    }
    
    private func setInitialClockViewControllerForClockType(vc: UIViewController, clockType: ClockTypes?) {
        setViewControllers([vc], direction: .Forward, animated: true, completion: nil)
    }

    private func viewControllerAtIndex(index: Int) -> UIViewController? {
        if (index >= clockViewControllerIdentifiers.count) {
            return nil
        }
        
        let clockViewControllerID = clockViewControllerIdentifiers[index]
        
        switch clockViewControllerID {
        case .None:
            let vc = instantiateNoneClockVC()
            let colorForTime = ColorManager().colorForHours(clock.hour, minutes: clock.minute, seconds: clock.second)
            vc.view.backgroundColor = colorForTime
            return vc
        case .Analog:
            let vc = instantiateAnalogClockVC()
            let colorForTime = ColorManager().colorForHours(clock.hour, minutes: clock.minute, seconds: clock.second)
            vc.view.backgroundColor = colorForTime
            return vc
        case .Digital:
            let vc = instantiateDigitalClockVC()
            let colorForTime = ColorManager().colorForHours(clock.hour, minutes: clock.minute, seconds: clock.second)
            vc.view.backgroundColor = colorForTime
            return vc
        }
    }
    
    private func instantiateNoneClockVC() -> NoneColorClockViewController {
        let noneClockStoryboard = UIStoryboard(name: Storyboards.NoneClock, bundle: nil)
        let noneClockVC = noneClockStoryboard.instantiateInitialViewController() as! NoneColorClockViewController
        return noneClockVC
    }
    
    private func instantiateAnalogClockVC() -> AnalogColorClockViewController {
        let analogClockStoryboard = UIStoryboard(name: Storyboards.AnalogClock, bundle: nil)
        let analogClockVC = analogClockStoryboard.instantiateInitialViewController() as! AnalogColorClockViewController
        return analogClockVC
    }
    
    private func instantiateDigitalClockVC() -> DigitalColorClockViewController {
        let digitalClockStoryboard = UIStoryboard(name: Storyboards.DigitalClock, bundle: nil)
        let digitalClockVC = digitalClockStoryboard.instantiateInitialViewController() as! DigitalColorClockViewController
        return digitalClockVC
    }
}

//MARK: - UIPageViewControllerDataSource
extension ClocksViewController: UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let vcRestorationID = viewController.restorationIdentifier {
            if let clockVcID = ClockVCIdentifiers(rawValue: vcRestorationID) {
                if let index = clockViewControllerIdentifiers.indexOf(clockVcID) {
                    if index == 0 {
                        return nil;
                    }
                    return viewControllerAtIndex(index - 1)
                }else {
                    return nil
                }
            }else{
               return nil
            }
        }else {
            return nil
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let vcRestorationID = viewController.restorationIdentifier {
            if let clockVcID = ClockVCIdentifiers(rawValue: vcRestorationID) {
                if let index = clockViewControllerIdentifiers.indexOf(clockVcID) {
                    if index == clockViewControllerIdentifiers.count - 1 {
                        return nil;
                    }
                    return viewControllerAtIndex(index + 1)
                }else {
                    return nil
                }
            }else{
                return nil
            }
        }else {
            return nil
        }
    }
}

//MARK: - UIPageViewControllerDelegate
extension ClocksViewController: UIPageViewControllerDelegate {
    //NOTE: Don't really care about anything for the delegate right now...
}
