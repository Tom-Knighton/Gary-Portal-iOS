//
//  HostController.swift
//  AlMurray
//
//  Created by Tom Knighton on 12/09/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import UIKit

class HostController: GaryPortalSwipeController {
    
    func indexOfStartingPage() -> Int {
        return 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let bgImage = UIImageView()
        bgImage.image = UIImage(named: "BackgroundGradient")
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(bgImage)
        self.view.sendSubviewToBack(bgImage)
        let constraints = [
            bgImage.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            bgImage.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            bgImage.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            bgImage.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    override func setupView() {
        super.setupView()
        
        self.datasource = self
        self.navigationBarShouldNotExist = true
    }
    
    func changedToPageIndex(_ index: Int) {
        if index != 0 { //Has moved from feed and need to deactivate
            self.viewControllerData().first?.dismiss(animated: false, completion: nil)
        }
    }
    
}

extension HostController: GPSwipeControllerDataSource {
    
    func viewControllerData() -> [UIViewController] {
        return [newVC("FeedHost"), newVC("ProfileHost")]
    }
    
    func newVC(_ viewController: String) -> UIViewController {
        return UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateViewController(withIdentifier: viewController)
    }
}
