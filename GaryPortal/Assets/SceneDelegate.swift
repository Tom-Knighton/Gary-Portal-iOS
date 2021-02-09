//
//  SceneDelegate.swift
//  GaryPortal
//
//  Created by Tom Knighton on 13/01/2021.
//

import UIKit
import SwiftUI
import SwiftKeychainWrapper

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Create the SwiftUI view that provides the window contents.
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: ZeroPage())
        self.window = window
        self.window?.makeKeyAndVisible()
        
        if KeychainWrapper.standard.string(forKey: "JWT")?.isEmpty == false && UserDefaults.standard.bool(forKey: "hasLoggedIn") {
            //If user has logged in and a JWT is present
            UserService.getCurrentUser { (user, error) in
                DispatchQueue.main.async {
                    if user != nil {
                        // User logged in successfully
                        GaryPortal.shared.currentUser = user
                        GaryPortal.shared.loginUser(uuid: user?.userUUID ?? "")
                    } else {
                        // User's login has expired
                        self.window?.rootViewController = UIHostingController(rootView: SignInNavigationHost())
                        self.window?.makeKeyAndVisible()
                    }
                }
            }
        } else {
            // User not logged in
            self.window?.rootViewController = UIHostingController(rootView: SignInNavigationHost())
            self.window?.makeKeyAndVisible()
        }
        
        UserDefaults.standard.register(defaults: [
            GaryPortalConstants.UserDefaults.autoPlayVideos: true,
            GaryPortalConstants.UserDefaults.notifications: true,
        ])
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

extension SceneDelegate: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

