//
//  ViewControllerExtension.swift
//  FirebaseAdsPublisher
//
//  Created by Prasad Pai on 4/18/16.
//  Copyright © 2016 YMedia Labs. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func simpleAlertViewWithTitle(title: String, message: String, btnTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: btnTitle, style: UIAlertActionStyle.Default) {  (alertAction) -> Void in
        }
        alert.addAction(okAction)
        
        self.presentViewController(alert, animated: true) { () -> Void in
            
        }
    }
    
}