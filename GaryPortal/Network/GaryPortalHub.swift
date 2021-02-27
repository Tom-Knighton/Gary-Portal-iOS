//
//  GaryPortalHub.swift
//  GaryPortal
//
//  Created by Tom Knighton on 20/02/2021.
//

import Foundation
import SignalRClient

class GaryPortalHub: HubConnectionDelegate {
    
    private var connection: HubConnection
    private var timer: Timer?
    
    public init() {
        connection = HubConnectionBuilder(url: URL(string: GaryPortalConstants.APIMiscHub)!)
            .withAutoReconnect()
            .withJSONHubProtocol()
            .withLogging(minLogLevel: .info)
            .build()
        
        connection.delegate = self
        
        connection.on(method: "KeepAlive") { _ in }
        
        connection.on(method: "BanStatusUpdated", callback: { (userUUID: String) in
            print("update")
            self.banStatusUpdated(userUUID: userUUID)
        })
        
        connection.start()
    }
    
    func connectionDidOpen(hubConnection: HubConnection) {
        self.stopKeepAlive()
        self.keepAliveInternal()
    }
    
    func connectionDidFailToOpen(error: Error) {
    }
    
    func connectionDidClose(error: Error?) {
    }
    
    func connectionDidReconnect() {
        self.stopKeepAlive()
        self.keepAliveInternal()
    }
    
    //MARK: - Methods
    
    func propogateBan(userUUID: String) {
        self.connection.invoke(method: "BanStatusChanged", userUUID) { error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            }
        }
    }
    
    //MARK: - Handlers
    
    func banStatusUpdated(userUUID: String) {
        do {
            if let myUUID = GaryPortal.shared.currentUser?.userUUID, myUUID == userUUID {
                print("reached call to update")
                UserService.getUser(with: userUUID) { (newUser, error) in
                    DispatchQueue.main.async {
                        GaryPortal.shared.currentUser = newUser
                        GaryPortal.shared.loginUser(uuid: userUUID, salt: newUser?.userAuthentication?.userPassSalt ?? "")
                    }
                }
            }
        }
    }
    
    //MARK: - Keep Alive
    func keepAliveInternal() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true, block: { _ in
            self.connection.send(method: "KeepAlive")
        })
    }
    
    func stopKeepAlive() {
        self.timer?.invalidate()
    }
    
}
