//
//  GPCamTextField.swift
//  GaryPortal
//
//  Created by Tom Knighton on 22/03/2021.
//

import Foundation
import UIKit

enum GPTextViewStyles {
    case normal
}

class GPCamTextView: UITextView, GPColourPickerDelegate {
    
    public private(set) var textAttributes: [NSAttributedString.Key: AnyObject] = [:]
    var style: GPTextViewStyles = .normal
    var colour: UIColor = .white
 
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        self.textAlignment = .center
        self.font = UIFont(name: "Helvetica", size: 30)
        self.textColor = .white
       
        
        self.autocorrectionType = .no
        self.isScrollEnabled = false
        
        self.backgroundColor = UIColor(hexString: "#99000000")
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 1.0
        
        self.inputAccessoryView = GPColourPicker(frame: CGRect(x: 0, y: 0, width: 320, height: 40), delegate: self)
        self.inputAccessoryView?.backgroundColor = .clear
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let rotation = atan2(self.transform.b, self.transform.a)
        if rotation == 0 {
            let width = min(self.intrinsicContentSize.width, UIScreen.main.bounds.width)
            let sizeToFit = self.sizeThatFits(CGSize(width: width, height:CGFloat.greatestFiniteMagnitude))
            self.frame.size = CGSize(width: sizeToFit.width, height: sizeToFit.height)
        }
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func changedColour(to colour: UIColor) {
        self.colour = colour
        self.textColor = colour
    }
    
    
}
