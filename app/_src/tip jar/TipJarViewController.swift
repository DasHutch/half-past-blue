//
//  TipJarViewController.swift
//  color clock
//
//  Created by Gregory Hutchinson on 10/6/15.
//  Copyright © 2015 DasHutch Development. All rights reserved.
//

import UIKit

//TODO: Implement Payment Notifications and display ui for purchasing, purchased, failed, etc
class TipJarViewController: UIViewController {

    @IBOutlet weak var tipJarHeaderLabel: UILabel!
    @IBOutlet weak var tipJarBodyLabel: UILabel!
    @IBOutlet weak var tipJarDetailsLabel: UILabel!
    @IBOutlet weak var tipJarCaptionLabel: UILabel!
    @IBOutlet weak var smallTipTitleLabel: UILabel!
    @IBOutlet weak var mediumTipTitleLabel: UILabel!
    @IBOutlet weak var largeTipTitleLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var restorePurchasesButton: UIButton!
    
    @IBOutlet weak var smallTipButton: UIButton!
    @IBOutlet weak var mediumTipButton: UIButton!
    @IBOutlet weak var largeTipButton: UIButton!
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    //NOTE: These are all the observers for
    //      all the notifications
    //      (so we can remove them properly later)
    var iaptfnObserver: NSObjectProtocol?
    var iaptsnObserver: NSObjectProtocol?
    var iappfnObserver: NSObjectProtocol?
    var iaprpcnObserver: NSObjectProtocol?
    var iappdnenObserver: NSObjectProtocol?
    var csdcObserver: NSObjectProtocol?
    
    //MARK: - Lifecycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        configNotifications()
        
        //NOTE: Setup Button Text with proper pricing
        configButtonsWithProductPrices()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //NOTE: Just to be safe lets tell our ui to stop indicating
        //      if its accessing the network, since our ui is going away
        updateUIForAccessingNetwork(false)
        deconfigNotifications()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
    //MARK: - IBActions
    @IBAction func cancelTapped(sender: UIButton) {
        updateUIForAccessingNetwork(false)
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func restorePurchaseTapped(sender: UIButton) {
        updateUIForAccessingNetwork(true)
        InAppPurchaseManager.sharedManager.restorePurchases()
        disableButtons(smallTipButton, mediumTipButton, largeTipButton)
    }
    
    @IBAction func smallTipTapped(sender: UIButton) {
        updateUIForAccessingNetwork(true)
        InAppPurchaseManager.sharedManager.purchaseSmallTip()
        disableButtons(mediumTipButton, largeTipButton, restorePurchasesButton)
    }
    
    @IBAction func mediumTipTapped(sender: UIButton) {
        updateUIForAccessingNetwork(true)
        InAppPurchaseManager.sharedManager.purchaseMediumTip()
        disableButtons(smallTipButton, largeTipButton, restorePurchasesButton)
    }
    
    @IBAction func largeTipTapped(sender: UIButton) {
        updateUIForAccessingNetwork(true)
        InAppPurchaseManager.sharedManager.purchaseLargeTip()
        disableButtons(smallTipButton, mediumTipButton, restorePurchasesButton)
    }
    
    //MARK: - Private 
    private func configNotifications() {
        csdcObserver = notificationCenter.addObserverForName(UIContentSizeCategoryDidChangeNotification, object: nil, queue: nil) { (notification) -> Void in
            self.prepareLabelsWithUIFontTextStyle()
        }
        
        iaprpcnObserver = notificationCenter.addObserverForName(InAppPurchaseManagerNotifications.RestorePurchasesCompleted, object: nil, queue: nil) { (notification) -> Void in
            
            log.verbose("Received \(InAppPurchaseManagerNotifications.RestorePurchasesCompleted)")
            
            if let userInfo = notification.userInfo {
                //NOTE: RestorePurchasesCompleted userInfo will be populated with
                //      `error` key if it failed, else it will be `nil`
                if let error = userInfo["error"] {
                    log.error("Restore Purchases Completed with error: \(error)")
                }
            }
            
            self.updateUIForFinishedStoreKitTransations()
        }
        
        iappfnObserver = notificationCenter.addObserverForName(InAppPurchaseManagerNotifications.ProductsFetched, object: nil, queue: nil) { (notification) -> Void in
            
            log.verbose("Received \(InAppPurchaseManagerNotifications.ProductsFetched)")
            
            self.updateUIForFinishedStoreKitTransations()
        }
        
        iaptsnObserver = notificationCenter.addObserverForName(InAppPurchaseManagerNotifications.TransactionSucceeded, object: nil, queue: nil) { (notification) -> Void in
            
            log.verbose("Received \(InAppPurchaseManagerNotifications.TransactionSucceeded)")
            
            if let userInfo = notification.userInfo {
                //NOTE: TransactionSucceeded userInfo will be populated with
                //      `error` key if it failed, else it will be `nil`
                if let error = userInfo["error"] {
                    log.error("Restore Purchases Completed with error: \(error)")
                }
                
                //NOTE: TransactionSucceeded userInfo will be populated with
                //      `transaction` key
                if let transaction = userInfo["transaction"] {
                    log.info("Transaction Succeeded: \(transaction)")
                }
            }
            
            self.updateUIForFinishedStoreKitTransations()
        }
        
        iaptfnObserver = notificationCenter.addObserverForName(InAppPurchaseManagerNotifications.TransactionFailed, object: nil, queue: nil) { (notification) -> Void in
            
            log.verbose("Received \(InAppPurchaseManagerNotifications.TransactionFailed)")
            
            if let userInfo = notification.userInfo {
                //NOTE: TransactionFailed userInfo will be populated with
                //      `error` key if it failed, else it will be `nil`
                if let error = userInfo["error"] {
                    log.error("Restore Purchases Completed with error: \(error)")
                }
                
                //NOTE: TransactionFailed userInfo will be populated with
                //      `transaction` key
                if let transaction = userInfo["transaction"] {
                    log.info("Transaction Failed: \(transaction)")
                }
            }
            
            self.updateUIForFinishedStoreKitTransations()
        }
        
        iappdnenObserver = notificationCenter.addObserverForName(InAppPurchaseManagerNotifications.ProductDoesNotExist, object: nil, queue: nil) { (notification) -> Void in
            
            log.verbose("Received \(InAppPurchaseManagerNotifications.ProductDoesNotExist)")
            self.updateUIForFinishedStoreKitTransations()
        }
    }
    
    private func deconfigNotifications() {
        if csdcObserver != nil {
            notificationCenter.removeObserver(csdcObserver!)
        }
        
        if iaprpcnObserver != nil {
            notificationCenter.removeObserver(iaprpcnObserver!)
        }
        
        if iappfnObserver != nil {
            notificationCenter.removeObserver(iappfnObserver!)
        }
        
        if iaptsnObserver != nil {
            notificationCenter.removeObserver(iaptsnObserver!)
        }
        
        if iaptfnObserver != nil {
            notificationCenter.removeObserver(iaptfnObserver!)
        }
        
        if iappdnenObserver != nil {
            notificationCenter.removeObserver(iappdnenObserver!)
        }
    }
    
    //MARK: Update UI
    private func prepareLabelsWithUIFontTextStyle() {
        prepareLabel(tipJarHeaderLabel, withFontTextStyle: UIFontTextStyleHeadline)
        prepareLabel(tipJarBodyLabel, withFontTextStyle: UIFontTextStyleBody)
        prepareLabel(tipJarDetailsLabel, withFontTextStyle: UIFontTextStyleCaption1)
        prepareLabel(tipJarCaptionLabel, withFontTextStyle: UIFontTextStyleCaption1)
        prepareLabel(smallTipTitleLabel, withFontTextStyle: UIFontTextStyleFootnote)
        prepareLabel(mediumTipTitleLabel, withFontTextStyle: UIFontTextStyleFootnote)
        prepareLabel(largeTipTitleLabel, withFontTextStyle: UIFontTextStyleFootnote)
    }
    
    private func prepareLabel(label: UILabel, withFontTextStyle textStyle: String) {
        label.font = UIFont.preferredFontForTextStyle(textStyle)
    }
    
    private func updateUIForFinishedStoreKitTransations() {
        
        //NOTE: Turn of Netowrk Indicator(s)
        updateUIForAccessingNetwork(false)
        
        //NOTE: Enable all Purchase Buttons again
        enableButtons(smallTipButton, mediumTipButton, largeTipButton, restorePurchasesButton)
    }
    
    private func updateUIForAccessingNetwork(isAccessingNetwork: Bool) {
        Network.defaultManager.setNetworkActivityIndicatorVisible(isAccessingNetwork)
    }
    
    private func disableButtons(buttons: UIButton...) {
        for button in buttons {
            button.enabled = false
        }
    }
    
    private func enableButtons(buttons: UIButton...) {
        for button in buttons {
            button.enabled = true
        }
    }
    
    private func configButtonsWithProductPrices() {
        
        //NOTE: Small Tip Product
        if let smallTipProduct = InAppPurchaseManager.sharedManager.smallTipProduct {
            if let smallTipPrice = InAppPurchaseManager.sharedManager.localizedPrice(smallTipProduct) {
                smallTipButton.setTitle(smallTipPrice, forState: .Normal)
            }else {
                log.warning("Small Tip Product Price not found")
            }
        }else {
            log.warning("Small Tip Product not found")
        }
        
        //NOTE: Medium Tip Product
        if let mediumTipProduct = InAppPurchaseManager.sharedManager.mediumTipProduct {
            if let mediumTipPrice = InAppPurchaseManager.sharedManager.localizedPrice(mediumTipProduct) {
                smallTipButton.setTitle(mediumTipPrice, forState: .Normal)
            }else {
                log.warning("Medium Tip Product Price not found")
            }
        }else {
            log.warning("Medium Tip Product not found")
        }
        
        //NOTE: Large Tip Product
        if let largeTipProduct = InAppPurchaseManager.sharedManager.largeTipProduct {
            if let largeTipPrice = InAppPurchaseManager.sharedManager.localizedPrice(largeTipProduct) {
                smallTipButton.setTitle(largeTipPrice, forState: .Normal)
            }else {
                log.warning("Large Tip Product Price not found")
            }
        }else {
            log.warning("Large Tip Product not found")
        }
    }
    
}
