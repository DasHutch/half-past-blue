//
//  Network.swift
//  whatareyouintoo
//
//  Created by Gregory Hutchinson on 8/15/15.
//  Copyright © 2015 Maker Things. All rights reserved.
//

import UIKit

/// A Singleton to manage Networking
class Network {
    
    //MARK: - Lifecycle
    static let defaultManager = Network()
    private var activityIndicatorSetVisibleCount = 0
    
    private init(){}
    
    //MARK: Public
    
    /** 
    Show or Hide Status Bar Network Activity Indiciator. Tacks number of times show / hide is 
    called and will continue to display the status bar network activity indicator while
    show count is above 0
    
    - parameter visible:
    */
    func setNetworkActivityIndicatorVisible(visible: Bool) {
        if visible {
            ++activityIndicatorSetVisibleCount
        }else {
            --activityIndicatorSetVisibleCount
        }
        
        // If you have more closes than opens, make sure not to enter into minus numbers
        if activityIndicatorSetVisibleCount < 0 {
            activityIndicatorSetVisibleCount = 0
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = activityIndicatorSetVisibleCount > 0
    }
}