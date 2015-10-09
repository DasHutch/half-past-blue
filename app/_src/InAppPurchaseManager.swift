//
//  InAppPurchaseManager.swift
//  color clock
//
//  Created by Gregory Hutchinson on 10/7/15.
//  Copyright © 2015 DasHutch Development. All rights reserved.
//

import StoreKit

struct InAppPurchaseManagerNotifications {
    static let ProductsFetched = "InAppPurchaseManagerProductsFetchedNotification"
    
    static let TransactionFailed = "InAppPurchaseManagerTransactionFailedNotification"
    static let TransactionSucceeded = "InAppPurchaseManagerTransactionSucceededNotification"
    static let TransactionCancelled = "InAppPurchaseManagerTransactionCancelledNotification"
    
    static let RestorePurchasesCompleted = "InAppPurchaseManagerRestorePurchasesCompletedNotificiation"
    
    static let ProductDoesNotExist = "InAppPurchaseManagerProductDoesNotExistNotification"
}

class InAppPurchaseManager: NSObject {
    
    //TODO: ENHANCEMENT - reach out to server and pull product ids from there
    //      provides a much more felxible product listing approach
    private struct ProductIdentifiers {
        static let SmallTip = "com.dashutchdevelopment.colorclock.smalltip"
        static let MediumTip = "com.dashutchdevelopment.colorclock.mediumtip"
        static let LargeTip = "com.dashutchdevelopment.colorclock.largetip"
    }

    var smallTipProduct: SKProduct?
    var mediumTipProduct: SKProduct?
    var largeTipProduct: SKProduct?
    
    var productsRequest: SKProductsRequest?
    
    var products: [SKProduct]?
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    
    //MARK: - Lifecycle
    static let sharedManager = InAppPurchaseManager()
    private override init() {}
    
    //MARK: - Public
    func loadStore() {
        
        //NOTE: Restarts any purchases if they were interrupted last time the app was open
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        
        //NOTE: Get the product description (defined in early sections)
        requestProductsData()
    }
    
    func canMakePurchases() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    //MARK: Purchasable Products
    func restorePurchases() {
       SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    func purchaseSmallTip() {
        
        if smallTipProduct != nil {
            let payment = SKPayment(product: smallTipProduct!)
            SKPaymentQueue.defaultQueue().addPayment(payment)
        }else {
            log.warning("SmallTipProduct does not exist")
            productDoesNotExist()
        }
    }
    
    func purchaseMediumTip() {
        
        if mediumTipProduct != nil {
            let payment = SKPayment(product: mediumTipProduct!)
            SKPaymentQueue.defaultQueue().addPayment(payment)
        }else {
            log.warning("MediumTipProduct does not exist")
            productDoesNotExist()
        }
    }
    
    func purchaseLargeTip() {
        
        if largeTipProduct != nil {
            let payment = SKPayment(product: largeTipProduct!)
            SKPaymentQueue.defaultQueue().addPayment(payment)
        }else {
            log.warning("LargeTipProduct does not exist")
            productDoesNotExist()
        }
    }
    
    func localizedPrice(product: SKProduct) -> String? {
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .CurrencyStyle
        numberFormatter.locale = product.priceLocale
        
        let priceString = numberFormatter.stringFromNumber(product.price)
        
        return priceString
    }
    
    //MARK: - Private
    private func requestProductsData() {
        
        let productIdentifiers: Set<String> = Set(arrayLiteral: ProductIdentifiers.SmallTip, ProductIdentifiers.MediumTip, ProductIdentifiers.LargeTip)
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        
        if productsRequest != nil {
            
            productsRequest!.delegate = self
            productsRequest!.start()
        }
    }
    
    /// called when a transaction has been restored and and successfully completed
    private func restoreTransaction(transaction: SKPaymentTransaction) {
        
        guard let originalTransaction = transaction.originalTransaction else {
            log.warning("Missing originalTransaction information, unable to restore transaction")
            
            //????: Best Approach?
            failedTransaction(transaction)
            return
        }
        
        recordTransaction(originalTransaction)
        provideContent(originalTransaction.payment.productIdentifier)
        finishTransaction(transaction, wasSuccessful:true)
    }
    
    /// called when the transaction was successful
    private func completeTransaction(transaction: SKPaymentTransaction) {
        recordTransaction(transaction)
        provideContent(transaction.payment.productIdentifier)
        finishTransaction(transaction, wasSuccessful:true)
    }
    
    /// called when a transaction has failed
    private func failedTransaction(transaction: SKPaymentTransaction) {
        
        //TODO: Switch on Error Codes to provide error & better UI
        
        if transaction.error?.code != SKErrorPaymentCancelled {
            //NOTE: Error
            finishTransaction(transaction, wasSuccessful: false)
        }else {
            //NOTE: this is fine, the user just cancelled, so don’t notify with a failed
            //      use a cancelled instead
            cancelledTransaction(transaction)
        }
    }
    
    private func cancelledTransaction(transaction: SKPaymentTransaction) {
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
        
        //NOTE: Send out a notification for the cancelled transaction
        notificationCenter.postNotificationName(InAppPurchaseManagerNotifications.TransactionCancelled, object: self, userInfo: nil)
    }
    
    /// saves a record of the transaction by storing the receipt to disk
    private func recordTransaction(transaction: SKPaymentTransaction) {
        log.verbose("recording transaction...")
        if transaction.payment.productIdentifier == "" {
            //????: All Transactions are recorded on Device in AppStoreReceiptURL
            //      should save / record to my own server?
        }
    }
    
    /// removes the transaction from the queue and posts a notification with the transaction result
    private func finishTransaction(transaction: SKPaymentTransaction, wasSuccessful: Bool) {
        
        //NOTE: Remove the transaction from the payment queue.
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
        
        var userInfo: [NSObject : AnyObject] = ["transaction" : transaction]
        if let error = transaction.error {
            userInfo  = ["transaction" : transaction, "error" : error]
        }
        
        if (wasSuccessful) {
            
            //NOTE: Send out a notification that we’ve finished the transaction (successful)
            notificationCenter.postNotificationName(InAppPurchaseManagerNotifications.TransactionSucceeded, object: self, userInfo: userInfo)
        }else {
            
            //NOTE: Send out a notification for the failed transaction
            notificationCenter.postNotificationName(InAppPurchaseManagerNotifications.TransactionFailed, object: self, userInfo: userInfo)
        }
    }
    
    private func productDoesNotExist() {
        notificationCenter.postNotificationName(InAppPurchaseManagerNotifications.ProductDoesNotExist, object: self, userInfo: nil)
    }
}

//MARK: - Enable Features
extension InAppPurchaseManager {
    private func provideContent(productId: String) {
        
        if productId == ProductIdentifiers.SmallTip {
            //NOTE: enable the pro features
            //            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isProUpgradePurchased" ];
            //            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

//MARK: - SKPaymentTransactionObserver
extension InAppPurchaseManager: SKPaymentTransactionObserver {
   
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .Purchased:
                log.verbose("Purchased...")
                completeTransaction(transaction)
            case .Failed:
                log.verbose("Failed...")
                failedTransaction(transaction)
            case .Restored:
                log.verbose("Restored...")
                restoreTransaction(transaction)
            case .Purchasing:
                log.verbose("Purchasing... \(transactions)")
            case .Deferred:
                log.verbose("Deferred... \(transactions)")
            }
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        log.info("Payment Queue Remove Transactions: \(transactions)")
    }
    
    func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError) {
        log.info("Payment Queue Restore Completed Transactions Failed With Error: \(error)")
        
        let userInfo = ["error" : error]
        notificationCenter.postNotificationName(InAppPurchaseManagerNotifications.RestorePurchasesCompleted, object: self, userInfo: userInfo)
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        log.info("Payment Queue Restore Completed Transactions Finished - \(queue)")
        
        notificationCenter.postNotificationName(InAppPurchaseManagerNotifications.RestorePurchasesCompleted, object: self, userInfo: nil)
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
        log.info("Payment Queue Updated Downloads: \(downloads)")
    }
}

//MARK: - SKProductsRequestDelegate
extension InAppPurchaseManager: SKProductsRequestDelegate {
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        
        products = response.products
        
        for product in response.products {
            log.verbose("Product title: \(product.localizedTitle)")
            log.verbose("Product description: \(product.localizedDescription)")
            log.verbose("Product price: \(product.price)")
            log.verbose("Product id: \(product.productIdentifier)")
            
            switch product.productIdentifier {
            case ProductIdentifiers.SmallTip:
                smallTipProduct = product
            case ProductIdentifiers.MediumTip:
                mediumTipProduct = product
            case ProductIdentifiers.LargeTip:
                largeTipProduct = product
            default:
                log.warning("Unknown Product Identifier: \(product.productIdentifier) found")
            }
        }
        
        for invalidProductId in response.invalidProductIdentifiers {
            log.verbose("Invalid product id: \(invalidProductId)")
        }
        
        notificationCenter.postNotificationName(InAppPurchaseManagerNotifications.ProductsFetched, object:self, userInfo:nil)
    }
}
