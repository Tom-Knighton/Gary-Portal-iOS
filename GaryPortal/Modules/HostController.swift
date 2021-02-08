//
//  TestMainPage.swift
//  GaryPortal
//
//  Created by Tom Knighton on 14/01/2021.
//
import UIKit
import SwiftUI

class HostNavigation: UINavigationController {
    
    override func viewDidAppear(_ animated: Bool) {
        self.pushViewController(HostController(), animated: false)
    }
}

struct HostControllerRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let hostController = HostController()
        return hostController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}


class HostController: GaryPortalSwipeController {
    
    func indexOfStartingPage() -> Int {
        return 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImage = UIImageView()
        backgroundImage.image = UIImage(named: "BackgroundGradient")
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(backgroundImage)
        self.view.sendSubviewToBack(backgroundImage)
        let constraints = [
            backgroundImage.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            backgroundImage.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            backgroundImage.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            backgroundImage.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
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
            NotificationCenter.default.post(name: .movedFromFeed, object: nil)
        } else {
            NotificationCenter.default.post(name: .goneToFeed, object: nil)
        }
    }
}


extension HostController: GPSwipeControllerDataSource {
    
    func viewControllerData() -> [UIViewController] {
        let view = UIViewController()
        view.view.backgroundColor = .clear
        
        let profileView = UIHostingController(rootView: ProfileView().environmentObject(GaryPortal.shared))
        let feedView = UIHostingController(rootView: FeedView().environmentObject(GaryPortal.shared))
        let newFeedView = UIHostingController(rootView: ChatRootView().environmentObject(GaryPortal.shared))
        feedView.view.backgroundColor = .clear
        profileView.view.backgroundColor = .clear
        newFeedView.view.backgroundColor = .clear
        return [feedView, profileView, newFeedView]
    }
    
}

