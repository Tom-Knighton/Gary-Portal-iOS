//
//  ProfileMiscView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 31/03/2021.
//

import SwiftUI

class ProfileMiscCardData: ObservableObject {
    @Published var headerText = ""
    @Published var subText = ""
    @Published var backgroundColours = [Color.orange]
    @Published var textColor = Color.black
    
    init(headerText: String = "", subText: String = "", backgroundColours: [Color] = [.orange], textColor: Color = .black) {
        self.headerText = headerText
        self.subText = subText
        self.backgroundColours = backgroundColours
        self.textColor = textColor
    }
}

struct ProfileMiscView: View {
    
    
    @ObservedObject var datasource: ProfileViewDataSource
    
    var prayerGradient: [Color] = [Color(UIColor(hexString: "#8E2DE2")), Color(UIColor(hexString: "#4A00E0"))]
    var rulesGradient: [Color] = [Color(UIColor(hexString: "#8A2387")), Color(UIColor(hexString: "#E94057"))]
    var bookGradient: [Color] = [Color(UIColor(hexString: "#4568DC")), Color(UIColor(hexString: "#B06AB3"))]
    var feedbackGradient: [Color] = [Color(UIColor(hexString: "#4568DC")), Color(UIColor(hexString: "#B06AB3"))]
    var settingsGradient: [Color] = [Color(UIColor(hexString: "#485563")), Color(UIColor(hexString: "#434343"))]
    
    var body: some View {
        HStack {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    Spacer().frame(width: 8)
                    Button(action: { self.openSheet(.prayer) }) {
                        ProfileMiscViewCard(datasource: ProfileMiscCardData(headerText: "Al Appreciation Centre", subText: "For all your appreciation needs", backgroundColours: [Color(UIColor(hexString: "#8E2DE2")), Color(UIColor(hexString: "#4A00E0"))], textColor: .white))
                    }
                    Button(action: { self.openSheet(.rules) }) {
                        ProfileMiscViewCard(datasource: ProfileMiscCardData(headerText: "Rules & Regulation", subText: "Read the official rules and regulations of the Gary Portal app here.", backgroundColours: [Color(UIColor(hexString: "#8A2387")), Color(UIColor(hexString: "#E94057"))], textColor: .white))
                    }
                    Button(action: { self.openSheet(.commandments) }) {
                        ProfileMiscViewCard(datasource: ProfileMiscCardData(headerText: "Commandments", subText: "Observe and follow the Gary Commandments, from Al Himself.", backgroundColours: [Color(UIColor(hexString: "#EB5757")), Color(UIColor(hexString: "#000000"))], textColor: .white))
                    }
                    .isHidden(datasource.user?.HasUserFlag(flagName: "RestrictSilliness") == true, remove: true)
                    
                    Button(action: { self.openSheet(.book) }) {
                        ProfileMiscViewCard(datasource: ProfileMiscCardData(headerText: "Computer Dating", subText: "Re-read the original prophecy", backgroundColours: [Color(UIColor(hexString: "#4568DC")), Color(UIColor(hexString: "#B06AB3"))], textColor: .white))
                    }
                    Button(action: {}) {
                        ProfileMiscViewCard(datasource: ProfileMiscCardData(headerText: "Calendar", subText: "What's happening? Who knows. The calendar probably does.", backgroundColours: [Color(UIColor(hexString: "#0B486B")), Color(UIColor(hexString: "#F56217"))], textColor: .white))
                    }
                    Button(action: { self.openSheet(.settings) }) {
                        ProfileMiscViewCard(datasource: ProfileMiscCardData(headerText: "Settings", subText: "Modify your user or app settings here", backgroundColours: [Color(UIColor(hexString: "#0F2027")), Color(UIColor(hexString: "#203A43"))], textColor: .white))
                    }
                    Spacer().frame(width: 8)
                }
                .padding()
            }
        }
        .frame(height: 212)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(radius: 15)
    }
    
    func openSheet(_ sheet: ProfileViewDataSource.ActiveSheet) {
        self.datasource.activeSheet = sheet
    }
}

struct ProfileMiscViewCard: View {
    
    @ObservedObject var datasource: ProfileMiscCardData
    
    var body: some View {
        VStack {
            Text(self.datasource.headerText)
                .font(.title3).bold()
                .shadow(radius: 3)
                .padding()
                .lineLimit(3)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            
                
            Spacer()
            Text(self.datasource.subText)
                .padding(.all, 0)
                .font(.subheadline)
                .shadow(radius: 1)
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.white)
                .background(Color.black.opacity(0.4).cornerRadius(10).shadow(radius: 3))
        }
        .frame(width: 200, height: 180)
        .background(LinearGradient(gradient: Gradient(colors: self.datasource.backgroundColours), startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}
