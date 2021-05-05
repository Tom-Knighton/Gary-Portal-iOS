//
//  GameHub.swift
//  GaryPortal
//
//  Created by Tom Knighton on 20/04/2021.
//

import Foundation
import SignalRClient

class GameHub: HubConnectionDelegate {
    
    private var connection: HubConnection
    private var timer: Timer?
    
    public init() {
        connection = HubConnectionBuilder(url: URL(string: GaryPortalConstants.APIGameHub)!)
            .withAutoReconnect()
            .withJSONHubProtocol()
            .withLogging(minLogLevel: .info)
            .build()
        
        connection.delegate = self
        
        connection.on(method: "KeepAlive") { _ in }
    
        //MARK: TTG Events
        connection.on(method: "TTG_StartGame") { (_) in
            self.ttgStartGame()
        }
        
        connection.on(method: "TTG_MovePlayed") { (uuid: String, row: Int, col: Int) in
            self.ttgMovePlayed(uuid, row, col)
        }
        
        connection.on(method: "TTG_GameWon") { (uuid: String) in
            self.ttgGameWon(uuid)
        }
        
        //MARK: Global Events
        
        connection.on(method: "UpdateGameLobby") { (json: String) in
            self.updateGameLobby(json)
        }
        
        connection.on(method: "HostLeftLobby") { _ in
            self.hostLeftLobby()
        }

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
    
    func ttgCreateGame(hostUUID uuid: String, gameSize: Int) {
        self.connection.invoke(method: "TTGCreateGame", uuid, gameSize) { (error) in
            if let error = error { print(error.localizedDescription) }
        }
    }
    
    func ttgJoinGame(userUUID uuid: String, gameCode: String) {
        self.connection.invoke(method: "TTGJoinGame", uuid, gameCode) { (error) in
            if let error = error { print(error.localizedDescription) }
        }
    }
    
    func ttgStartGame(gameCode: String) {
        self.connection.invoke(method: "TTGStartGame", gameCode) { (error) in
            if let error = error { print(error.localizedDescription) }
        }
    }
    
    func ttgLeaveGame(uuid: String, gameCode: String) {
        self.connection.invoke(method: "TTGLeaveGame", uuid, gameCode) { (error) in
            if let error = error { print(error.localizedDescription) }
        }
    }
    
    func ttgPlayMove(code: String, uuid: String, row: Int, col: Int) {
        self.connection.invoke(method: "TTGMakeMove", code, uuid, row, col) { (error) in
            if let error = error { print(error.localizedDescription) }
        }
    }
    
    //MARK: - Handlers
    
    private func updateGameLobby(_ json: String) {
        NotificationCenter.default.post(Notification(name: .updateGameLobby, object: self, userInfo: ["json": json]))
    }
    
    private func hostLeftLobby() {
        NotificationCenter.default.post(Notification(name: .hostLeftLobby))
    }
    
    private func ttgStartGame() {
        NotificationCenter.default.post(Notification(name: .ttgGameStarted))
    }
    
    private func ttgMovePlayed(_ uuid: String, _ row: Int, _ col: Int) {
        NotificationCenter.default.post(name: .ttgMovePlayed, object: self, userInfo: ["uuid": uuid, "row": row, "col": col])
    }
    
    private func ttgGameWon(_ uuid: String) {
        NotificationCenter.default.post(name: .ttgGameWon, object: self, userInfo: ["uuid": uuid])
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

