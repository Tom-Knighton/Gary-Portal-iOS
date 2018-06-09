//
//  feedSwiper.swift
//  Gary Portal
//
//  Created by Tom Knighton on 10/05/2018.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import BetterSegmentedControl
import ChameleonFramework
import AVFoundation
import AVKit

class feedSwiper: UIViewController {

    @IBOutlet weak var pollView: UIView!
    @IBOutlet weak var feedView: UIView!
    
    @IBOutlet weak var aditView: UIView!
    
    @IBOutlet weak var slider: BetterSegmentedControl!
    
    @IBOutlet weak var uploadB: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        self.uploadB.layer.cornerRadius = 20
        self.uploadB.layer.masksToBounds = true
        self.feedView.isHidden = false
        self.pollView.isHidden = true
        self.aditView.isHidden = true
        
        slider.titles = ["GaryGram", "Polls", "ADIT LOGS"]
        slider.options = [.backgroundColor(GradientColor(.leftToRight, frame: self.slider.frame, colors: [UIColor(red:0.02, green:0.81, blue:1.00, alpha:1.0), UIColor(red:0.82, green:0.02, blue:1.00, alpha:1.0)])),
        .titleColor(.white),
        .indicatorViewBackgroundColor(UIColor(red:0.55, green:0.26, blue:0.86, alpha:1.00)),
        .selectedTitleColor(.black),
        .titleFont(UIFont(name: "HelveticaNeue", size: 14.0)!),
        .selectedTitleFont(UIFont(name: "HelveticaNeue-Medium", size: 14.0)!)]
        
        slider.addTarget(self, action: #selector(sliderChanged(sender:)), for: .valueChanged)
        
    }
    
    var current = "gg"
    @objc func sliderChanged(sender: BetterSegmentedControl) {
        if sender.index == 0 {
            current = "gg"
            self.feedView.isHidden = false
            self.pollView.isHidden = true
            self.aditView.isHidden = true
        } else if sender.index == 1 {
            current = "poll"
            self.feedView.isHidden = true
            self.pollView.isHidden = false
            self.aditView.isHidden = true
        } else if sender.index == 2 {
            current = "aditlog"
            self.feedView.isHidden = true
            self.pollView.isHidden = true
            self.aditView.isHidden = false
        }
    }

    @IBAction func uploadPressed(_ sender: Any) {
        if current == "gg" {
            self.performSegue(withIdentifier: "feedToUploadGG", sender: self)
        }
        if current == "poll" {
            self.performSegue(withIdentifier: "feedToUploadPoll", sender: self)
        }
        if current == "aditlog" {
            self.performSegue(withIdentifier: "feedToUploadADIT", sender: self)
        }
    }
    

}




