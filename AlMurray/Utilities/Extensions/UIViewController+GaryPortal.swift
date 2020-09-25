//
//  UIViewController+GaryPortal.swift
//  AlMurray
//
//  Created by Tom Knighton on 19/08/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import UIKit

extension UIViewController {
    
    var activityView: UIView {
        return ActivityIndicatorController().view
    }
    
    func toggleActivityIndicator(enable: Bool = true) {
        if enable {
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            self.view.isUserInteractionEnabled = false
            activityView.tag = 999
            self.view.addSubview(activityView)
        } else {
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            self.view.isUserInteractionEnabled = true
            self.view.viewWithTag(999)?.removeFromSuperview()
        }
    }
    
    func displayBasicAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
