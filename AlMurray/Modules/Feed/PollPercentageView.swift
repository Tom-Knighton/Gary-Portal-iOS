//
//  PollPercentageView.swift
//  Gary Portal
//
//  Created by Tom Knighton on 24/11/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import UIKit

class PollPercentageView: UIButton {
    
    var percentageFill: CGFloat = 0
    var filledView: UIView!
    
    override init(frame: CGRect) {
        filledView = UIView(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: 0, height: frame.height))
        filledView.backgroundColor = UIColor.red
        super.init(frame: frame)
        
        addSubview(filledView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
            
        self.filledView = UIView(frame: CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: self.bounds.width, height: self.bounds.height))
        self.filledView.backgroundColor = UIColor(red: 0.67, green: 0.67, blue: 0.67, alpha: 0.3)
        self.addSubview(filledView)
        self.filledView.bindFrameToSuperviewBounds(percentageMultiplier: 0)
        self.sendSubviewToBack(self.filledView)
    }

    func setProgess(progress: CGFloat) {
        let progress = min(max(progress, 0), 1) // Between 0 and 1
        self.percentageFill = progress
        self.sendSubviewToBack(self.filledView)
        self.filledView.bindFrameToSuperviewBounds(percentageMultiplier: self.percentageFill)
    }

}
