//
//  PrayerRoomView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 14/01/2021.
//

import SwiftUI

struct PrayerRoomView: View {
    
    @ObservedObject var datasource: ProfileViewDataSource
    @State var counter = 0
    @State var meaningfulCounter = 0
    
    var prayerGradient = [Color(UIColor(hexString: "#FF5F6D")), Color(UIColor(hexString: "#FFC371"))]
    var meaningfulPrayerGradient = [Color(UIColor(hexString: "#8A2387")), Color(UIColor(hexString: "#E94057")), Color(UIColor(hexString: "#F27121"))]
    var adminGradient = [Color(UIColor(hexString: "#ED213A")), Color(UIColor(hexString: "#93291E"))]
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Group {
                    GPGradientButton(action: { pray() }, buttonText: "Simple Prayer", gradientColours: prayerGradient)
                    Spacer().frame(height: 16)
                    GPGradientButton(action: { prayMeaningful() }, buttonText: "Meaningful Prayer", gradientColours: meaningfulPrayerGradient)
                    Text("Your Simple Prayers: \(counter)")
                        .font(Font.custom("Montserrat-SemiBold", size: 18))
                    Text("Your Meaningful Prayers: \(meaningfulCounter)")
                        .font(Font.custom("Montserrat-SemiBold", size: 18))
                }
                
                
                
                Spacer()
                
                if self.datasource.user?.userIsAdmin == true {
                    GPGradientButton(action: { adminClearPrayers() }, buttonText: "ADMIN: Clear All Prayers", gradientColours: adminGradient)
                }
            }
            .navigationTitle("Prayer Room")
        }
        .onAppear {
            self.counter = self.datasource.user?.userPoints?.prayers ?? 0
            self.meaningfulCounter = self.datasource.user?.userPoints?.meaningfulPrayers ?? 0
        }
        .onDisappear {
            guard let points = self.datasource.user?.userPoints else { return }
            UserService.updatePointsForUser(userUUID: self.datasource.user?.userUUID ?? "", userPoints: points) { (newPoints, error) in
                if newPoints != nil {
                    DispatchQueue.main.async {
                        GaryPortal.shared.currentUser?.userPoints = newPoints
                        let tempUser = self.datasource.user
                        tempUser?.userPoints = newPoints
                        self.datasource.user = tempUser
                    }
                }
            }
        }
    }
    
    func pray() {
        self.datasource.user?.userPoints?.prayers = (self.datasource.user?.userPoints?.prayers ?? 0) + 1
        counter = self.datasource.user?.userPoints?.prayers ?? 0
    }
    
    func prayMeaningful() {
        self.datasource.user?.userPoints?.meaningfulPrayers = (self.datasource.user?.userPoints?.meaningfulPrayers ?? 0) + 1
        meaningfulCounter = self.datasource.user?.userPoints?.meaningfulPrayers ?? 0
    }
    
    func adminClearPrayers() {
        AdminService.clearAllPrayers()
        DispatchQueue.main.async {
            self.datasource.user?.userPoints?.prayers = 0
            self.datasource.user?.userPoints?.meaningfulPrayers = 0
            counter = self.datasource.user?.userPoints?.prayers ?? 0
            meaningfulCounter = self.datasource.user?.userPoints?.meaningfulPrayers ?? 0
        }
    }
}
