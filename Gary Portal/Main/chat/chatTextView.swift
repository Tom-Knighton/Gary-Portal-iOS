//
//  chatTextView.swift
//  Gary Portal
//
//  Created by Tom Knighton on 26/04/2018.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit

class chatTextView: UITextView {

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) && UIPasteboard.general.image != nil {
            return true
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
        
       
    }
    override func paste(_ sender: Any?) {
        if UIPasteboard.general.hasURLs {
            let image = UIPasteboard.general.url!
            print("\(image)" + "hi")
        }
        else {
            // Call the normal paste action
            super.paste(sender)
        }
    }

}
