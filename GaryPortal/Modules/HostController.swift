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

protocol HostControllerDelegate: class {
    func didChangeIndex(_ index: Int)
}

struct HostControllerRepresentable: UIViewControllerRepresentable {
    
    @Binding var selectedIndex: Int
    
    func makeUIViewController(context: Context) -> HostController {
        let hostController = HostController()
        hostController.delegate = context.coordinator
        return hostController
    }
    
    func updateUIViewController(_ uiViewController: HostController, context: Context) {
        uiViewController.moveToPage(selectedIndex, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    final class Coordinator: NSObject, HostControllerDelegate {
        var parent: HostControllerRepresentable
        
        init(_ parent: HostControllerRepresentable) {
            self.parent = parent
        }
        
        func didChangeIndex(_ index: Int) {
            self.parent.selectedIndex = index
        }
    }
    
}


class HostController: GaryPortalSwipeController {
    
    func indexOfStartingPage() -> Int {
        return 1
    }
    
    weak var delegate: HostControllerDelegate?
    
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
        GaryPortal.shared.currentPageIndex = index
        if index != 0 { //Has moved from feed and need to deactivate
            self.viewControllerData().first?.dismiss(animated: false, completion: nil)
            NotificationCenter.default.post(name: .movedFromFeed, object: nil)
        } else {
            NotificationCenter.default.post(name: .goneToFeed, object: nil)
        }
        
        if index == 2 { // Has Moved to chat
            if let userDefaults = UserDefaults(suiteName: GaryPortalConstants.UserDefaults.suiteName) {
                let oldChat = userDefaults.integer(forKey: "chatBadgeCount")
                userDefaults.set(UIApplication.shared.applicationIconBadgeNumber - oldChat, forKey: "appBadgeCount")
                userDefaults.set(0, forKey: "chatBadgeCount")
                UIApplication.shared.applicationIconBadgeNumber -= oldChat
            }
        } else if index == 0 { // Has moved to feed
            if let userDefaults = UserDefaults(suiteName: GaryPortalConstants.UserDefaults.suiteName) {
                let oldFeed = userDefaults.integer(forKey: "feedBadgeCount")
                userDefaults.set(UIApplication.shared.applicationIconBadgeNumber - oldFeed, forKey: "appBadgeCount")
                userDefaults.set(0, forKey: "feedBadgeCount")
                UIApplication.shared.applicationIconBadgeNumber -= oldFeed
            }
        } else {
            if let userDefaults = UserDefaults(suiteName: GaryPortalConstants.UserDefaults.suiteName) {
                let oldOther = userDefaults.integer(forKey: "otherBadgeCount")
                userDefaults.set(UIApplication.shared.applicationIconBadgeNumber - oldOther, forKey: "appBadgeCount")
                userDefaults.set(0, forKey: "otherBadgeCount")
                UIApplication.shared.applicationIconBadgeNumber -= oldOther
            }
        }
        
        self.delegate?.didChangeIndex(index)
    }
}


extension HostController: GPSwipeControllerDataSource {
    
    func viewControllerData() -> [UIViewController] {
        let view = UIViewController()
        view.view.backgroundColor = .clear
        
        let profileView = UIHostingController(rootView: ProfileView(uuid: .constant(GaryPortal.shared.currentUser?.userUUID ?? "")))
        let feedView = UIHostingController(rootView: FeedView())
        let newFeedView = UIHostingController(rootView: ChatsRootView())
        feedView.view.backgroundColor = .clear
        profileView.view.backgroundColor = .clear
        newFeedView.view.backgroundColor = .clear
        return [feedView, profileView, newFeedView]
    }
    
}
