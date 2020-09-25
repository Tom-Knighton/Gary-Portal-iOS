//
//  ActivityIndicatorController.swift
//  AlMurray
//
//  Created by Tom Knighton on 19/08/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import UIKit

class ActivityIndicatorController: UIViewController {
    
    var spinner = UIActivityIndicatorView(style: .large)

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.35)
        self.view.tag = 999
   
        spinner.color = UIColor.white
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

}
