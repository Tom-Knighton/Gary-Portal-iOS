//
//  onboardingView.swift
//  Gary Portal
//
//  Created by Tom Knighton on 02/06/2018.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import paper_onboarding
class onboardingView: UIViewController, PaperOnboardingDelegate, PaperOnboardingDataSource {
    @IBOutlet weak var contContainer: UIView!
    @IBOutlet weak var cont: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    override func viewDidLoad() {
       
        setupPaperOnboardingView()
        contContainer.layer.cornerRadius = 20
        contContainer.layer.masksToBounds = true
        cont.layer.cornerRadius = 20
        cont.layer.masksToBounds = true
        self.contContainer.alpha = 0
        self.contContainer.isHidden = true
        self.view.bringSubview(toFront: contContainer)
    }
    
    func onboardingItemsCount() -> Int {
        return 3
    }
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        return items[index]
    }
    
    @IBAction func contPressed(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "hasOnboarded")
        self.dismiss(animated: true, completion: nil)
    }
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        print("transitioning")
        if index == 0 || index == 1 {
            UIView.animate(withDuration: 0.2, delay: 0, options: [], animations:
                {
                    self.contContainer.alpha = 0
            }, completion: { _ in
                self.contContainer.isHidden = true
            })
        }
        if index == 2 {
            self.contContainer.isHidden = false
            UIView.animate(withDuration: 0.2, delay: 0, options: [], animations:
                {
                    self.contContainer.alpha = 100
            }, completion: nil)
        }
    }
    private static let titleFont = UIFont(name: "Montserrat-SemiBold", size: 36.0) ?? UIFont.boldSystemFont(ofSize: 36.0)
    private static let descriptionFont = UIFont(name: "Montserrat-Light", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)
    
    private func setupPaperOnboardingView() {
        let onboarding = PaperOnboarding()
        onboarding.delegate = self
        onboarding.dataSource = self
        onboarding.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(onboarding)
        
        // Add constraints
        for attribute: NSLayoutAttribute in [.left, .right, .top, .bottom] {
            let constraint = NSLayoutConstraint(item: onboarding,
                                                attribute: attribute,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: attribute,
                                                multiplier: 1,
                                                constant: 0)
            view.addConstraint(constraint)
        }
    }
    fileprivate let items = [
        OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "icon"),
                           title: "Welcome",
                           description: "Welcome to the Gary Portal, swipe left to go through a quick tutorial experience!",
                           pageIcon: UIImage(),
                           color: UIColor(red: 0.40, green: 0.56, blue: 0.71, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
        
        OnboardingItemInfo(informationImage: UIImage(),
                           title: "Swipe",
                           description: "See what you just did there? Swiping? That's how you get around. Swipe left or right from the profile page to go to your chats or your feed instantly!",
                           pageIcon: UIImage(),
                           color: UIColor(red: 0.40, green: 0.69, blue: 0.71, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
        
        OnboardingItemInfo(informationImage: UIImage(),
                           title: "What can i do?",
                           description: "Swipe right to go to the feed, then share your life with your friends through GaryGram or ADIT Logs, or make a poll! Or swipe left to chat with your friends. Alternatively, stay on the profile page and visit the prayer room, go to our website, access the settings or submit some feedback. Happy Garying!",
                           pageIcon: UIImage(),
                           color: UIColor(red: 0.61, green: 0.56, blue: 0.74, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
        
        ]

 

}
