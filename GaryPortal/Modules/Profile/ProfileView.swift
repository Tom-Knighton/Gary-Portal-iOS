//
//  ProfileView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 14/01/2021.
//

import SwiftUI

class ProfileViewDataSource: ObservableObject {
    
    @Published var user: User?
    @Published var hasLoaded = false
    
    func setup(for uuid: String) {
        UserService.getUser(with: uuid) { (user) in
            DispatchQueue.main.async {
                if let user = user {
                    self.user = user
                    self.hasLoaded = true
                }
            }
        }
    }
}

struct ProfileView: View {
    
    @Binding var uuid: String
    @ObservedObject var datasource = ProfileViewDataSource()
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                ProfileHeaderView(datasource: self.datasource)
                    .redacted(reason: self.datasource.hasLoaded ? [] : .placeholder)
                Spacer().frame(height: 16)
                ProfilePointsView(datasource: self.datasource)
                    .redacted(reason: self.datasource.hasLoaded ? [] : .placeholder)
                Spacer().frame(height: 16)
                ProfileStatsView(datasource: self.datasource)
                    .redacted(reason: self.datasource.hasLoaded ? [] : .placeholder)
                Spacer().frame(height: 16)
                if GaryPortal.shared.currentUser?.userUUID == self.datasource.user?.userUUID {
                    ProfileMiscView(datasource: self.datasource)
                        .redacted(reason: self.datasource.hasLoaded ? [] : .placeholder)
                    Spacer().frame(height: 16)
                }
            }
            .frame(width: geometry.size.width)
        }
        .onAppear {
            self.datasource.setup(for: uuid)
        }
    }
    
}

struct ProfileHeaderView: View {
    
    @ObservedObject var datasource: ProfileViewDataSource
    let websiteGradient = [Color(UIColor(hexString: "#FF416C")), Color(UIColor(hexString: "#FF4B2B"))]
    let privilegedGradient = [Color(UIColor(hexString: "#42275a")), Color(UIColor(hexString: "#734b6d"))]
    
    @State var isShowingStaff = false
    
    var body: some View {
        HStack {
            Spacer().frame(width: 16)
            VStack {
                Spacer().frame(height: 16)
                AsyncImage(url: self.datasource.user?.userProfileImageUrl ?? "")
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.white, lineWidth: 1)
                            .shadow(radius: 15)
                    )
                    .frame(width: 180, height: 180)
                
                Group {
                    Spacer().frame(height: 16)
                    Text(self.datasource.user?.userFullName ?? "Full Name")
                        .font(Font.custom("Montserrat-SemiBold", size: 25))
                    Spacer().frame(height: 16)
                    Text(self.datasource.user?.userSpanishName ?? "Spanish Name")
                        .font(Font.custom("Montserrat-Light", size: 20))
                    Spacer().frame(height: 8)
                    Text("@\(self.datasource.user?.userName ?? "Username")")
                        .font(Font.custom("Montserrat-Light", size: 15))
                    Spacer().frame(height: 8)
                }
                
                if GaryPortal.shared.currentUser?.userUUID == datasource.user?.userUUID {
                    if GaryPortal.shared.currentUser?.userIsAdmin == true || GaryPortal.shared.currentUser?.userIsStaff == true {
                        GPGradientButton(action: { self.isShowingStaff = true }, buttonText: "Staff Panel", gradientColours: privilegedGradient)
                            .sheet(isPresented: $isShowingStaff, content: {
                                StaffRoomView()
                            })
                    } else {
                        GPGradientButton(action: {}, buttonText: "Visit Website", gradientColours: websiteGradient)
                    }
                }
                
                Spacer().frame(height: 16)
                
                
            }
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(20)
            .shadow(radius: 15)
            Spacer().frame(width: 16)
        }
    }
}

struct ProfilePointsView: View {
    
    @ObservedObject var datasource: ProfileViewDataSource

    var body: some View {
        HStack {
            Spacer().frame(width: 16)
            VStack {
                Group {
                    Spacer().frame(height: 16)
                    Text("Points:")
                        .font(Font.custom("Montserrat-ExtraLight", size: 30))
                }
                
                Group {
                    Spacer().frame(height: 16)
                    Text("AMIGO POINTS: \(self.datasource.user?.userPoints?.amigoPoints ?? 0)")
                        .font(Font.custom("Montserrat-SemiBold", size: 20))
                    Spacer().frame(height: 16)
                    Text("POSITIVE POINTS: \(self.datasource.user?.userPoints?.positivityPoints ?? 0)")
                        .font(Font.custom("Montserrat-SemiBold", size: 20))
                    
                    Divider().padding()

                    Text("PRAYERS: \(self.datasource.user?.userPoints?.prayers ?? 0)")
                        .font(Font.custom("Montserrat-SemiBold", size: 20))
                    Spacer().frame(height: 16)
                    Text("MEANINGFUL: \(self.datasource.user?.userPoints?.meaningfulPrayers ?? 0)")
                        .font(Font.custom("Montserrat-SemiBold", size: 20))
                    Spacer().frame(height: 16)
                }
               
            }
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(20)
            .shadow(radius: 15)
            Spacer().frame(width: 16)
        }
        
    }
}

struct ProfileStatsView: View {
    
    @ObservedObject var datasource: ProfileViewDataSource
    
    var body: some View {
        HStack {
            Spacer().frame(width: 16)
            VStack {
                Group {
                    Spacer().frame(height: 16)
                    Text("User Statistics:")
                        .font(Font.custom("Montserrat-ExtraLight", size: 30))
                }
                
                Group {
                    Spacer().frame(height: 16)
                    Text("Amigo Rank:")
                        .font(Font.custom("Montserrat-Regular", size: 20))
                    Spacer().frame(height: 16)
                    Text("\(self.datasource.user?.userRanks?.amigoRank?.rankName ?? "AMIGO RANK")")
                        .font(Font.custom("Montserrat-SemiBold", size: 25))
                }
                Group {
                    Spacer().frame(height: 16)
                    Text("Positivity Rank:")
                        .font(Font.custom("Montserrat-Regular", size: 20))
                    Spacer().frame(height: 16)
                    Text("\(self.datasource.user?.userRanks?.positivityRank?.rankName ?? "POSITIVITY RANK")")
                        .font(Font.custom("Montserrat-SemiBold", size: 25))
                }
                Group {
                    Spacer().frame(height: 16)
                    Text("Team:")
                        .font(Font.custom("Montserrat-Regular", size: 20))
                    Spacer().frame(height: 16)
                    Text("\(self.datasource.user?.userTeam?.team?.teamName ?? "TEAM")")
                        .font(Font.custom("Montserrat-SemiBold", size: 25))
                }
                Group {
                    Spacer().frame(height: 16)
                    Text("Team Standing:")
                        .font(Font.custom("Montserrat-Regular", size: 20))
                    Spacer().frame(height: 16)
                    Text("\(self.datasource.user?.userStanding ?? "STANDING")")
                        .font(Font.custom("Montserrat-SemiBold", size: 25))
                    Spacer().frame(height: 16)
                }
               
            }
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(20)
            .shadow(radius: 15)
            Spacer().frame(width: 16)
        }
    
    }
}

struct ProfileMiscView: View {
    
    @ObservedObject var datasource: ProfileViewDataSource
    @State var image: UIImageView?
    @State var isShowingPrayerRoom = false
    @State var isShowingSettings = false
    
    @State var showSafari = false
    @State var safariURL: String? = ""

    
    var prayerGradient: [Color] = [Color(UIColor(hexString: "#8E2DE2")), Color(UIColor(hexString: "#4A00E0"))]
    var rulesGradient: [Color] = [Color(UIColor(hexString: "#8A2387")), Color(UIColor(hexString: "#E94057"))]
    var bookGradient: [Color] = [Color(UIColor(hexString: "#4568DC")), Color(UIColor(hexString: "#B06AB3"))]
    var feedbackGradient: [Color] = [Color(UIColor(hexString: "#4568DC")), Color(UIColor(hexString: "#B06AB3"))]
    var settingsGradient: [Color] = [Color(UIColor(hexString: "#485563")), Color(UIColor(hexString: "#434343"))]

    var body: some View {
        HStack {
            Spacer().frame(width: 16)
            VStack {
                Group {
                    Spacer().frame(height: 16)
                    Text("Misc.")
                        .font(Font.custom("Montserrat-ExtraLight", size: 30))
                }
               
                Group {
                    GPGradientButton(action: self.showPrayerRoom, buttonText: "PRAYER ROOM", gradientColours: prayerGradient)
                        .sheet(isPresented: $isShowingPrayerRoom, content: {
                            PrayerRoomView(datasource: self.datasource)
                        })
                    Spacer().frame(height: 16)
                    GPGradientButton(action: { openURL(url: GaryPortalConstants.URLs.RulesURL )}, buttonText: "RULES AND REGULATIONS", gradientColours: rulesGradient)
                        .sheet(isPresented: $showSafari, content: {
                            SafariView(url: self.safariURL)
                        })
                    Spacer().frame(height: 16)
                    GPGradientButton(action: { openURL(url: GaryPortalConstants.URLs.ComputerDatingURL )}, buttonText: "COMPUTER DATING", gradientColours: bookGradient)
                    Spacer().frame(height: 16)
                    GPGradientButton(action: { openURL(url: GaryPortalConstants.URLs.FeedbackURL )}, buttonText: "APP FEEDBACK", gradientColours: feedbackGradient)
                    Spacer().frame(height: 16)
                    GPGradientButton(action: self.showSettings, buttonText: "SETTINGS", gradientColours: settingsGradient)
                        .sheet(isPresented: $isShowingSettings, content: {
                            ProfileSettingsView(datasource: self.datasource)
                        })
                }
                
                Spacer().frame(height: 16)
            }
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(20)
            .shadow(radius: 15)
            Spacer().frame(width: 16)
        }
    }
    
    func openURL(url: String) {
        self.safariURL = url
        self.showSafari = true
    }
    
    func showPrayerRoom() {
        self.isShowingPrayerRoom = true
    }
    
    func showSettings() {
        self.isShowingSettings = true
    }
}

