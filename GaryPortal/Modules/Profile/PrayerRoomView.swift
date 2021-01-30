//
//  PrayerRoomView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 14/01/2021.
//

import SwiftUI

struct PrayerRoomView: View {
    
    @EnvironmentObject var garyportal: GaryPortal
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
                
                if garyportal.currentUser?.userIsAdmin == true {
                    GPGradientButton(action: { adminClearPrayers() }, buttonText: "ADMIN: Clear All Prayers", gradientColours: adminGradient)
                }
            }
            .navigationTitle("Prayer Room")
        }
        .onAppear {
            self.counter = garyportal.currentUser?.userPoints?.prayers ?? 0
            self.meaningfulCounter = garyportal.currentUser?.userPoints?.meaningfulPrayers ?? 0
        }
        .onDisappear {
            guard let points = garyportal.currentUser?.userPoints else { return }
            UserService.updatePointsForUser(userUUID: garyportal.currentUser?.userUUID ?? "", userPoints: points) { (newPoints, error) in
                if newPoints != nil {
                    DispatchQueue.main.async {
                        garyportal.currentUser?.userPoints = newPoints
                    }
                }
            }
        }
    }
    
    func pray() {
        garyportal.currentUser?.userPoints?.prayers = (garyportal.currentUser?.userPoints?.prayers ?? 0) + 1
        counter = garyportal.currentUser?.userPoints?.prayers ?? 0
    }
    
    func prayMeaningful() {
        garyportal.currentUser?.userPoints?.meaningfulPrayers = (garyportal.currentUser?.userPoints?.meaningfulPrayers ?? 0) + 1
        meaningfulCounter = garyportal.currentUser?.userPoints?.meaningfulPrayers ?? 0
    }
    
    func adminClearPrayers() {
        AdminService.clearAllPrayers()
        DispatchQueue.main.async {
            garyportal.currentUser?.userPoints?.prayers = 0
            garyportal.currentUser?.userPoints?.meaningfulPrayers = 0
            counter = garyportal.currentUser?.userPoints?.prayers ?? 0
            meaningfulCounter = garyportal.currentUser?.userPoints?.meaningfulPrayers ?? 0
        }
    }
}

struct PrayerRoomView_Previews: PreviewProvider {
    static var previews: some View {
        PrayerRoomView()
            .environmentObject(GaryPortal.shared)
    }
}
