//
//  GPNavigation.swift
//  GaryPortal
//
//  Created by Tom Knighton on 31/01/2021.
//

import SwiftUI

class GPUINavController: UINavigationController, UIGestureRecognizerDelegate {
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.backgroundColor = .clear
        self.topViewController?.view.backgroundColor = .clear
        self.navigationBar.prefersLargeTitles = true
        self.navigationBar.isHidden = true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

struct GPNavigationController: UIViewControllerRepresentable {
    
    @State var view: AnyView
    
    typealias UIViewControllerType = GPUINavController
    
    func makeUIViewController(context: Context) -> GPUINavController {
        let navController = GPUINavController(rootViewController: UIHostingController(rootView: view))
        return navController
    }
    
    func updateUIViewController(_ uiViewController: GPUINavController, context: Context) {
        
    }
}

struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }

    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        UIViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }

}

