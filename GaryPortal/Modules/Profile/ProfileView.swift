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
    
    @State var alertContent: [String] = []
    @State var isShowingAlert = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                ProfileHeaderView(datasource: self.datasource)
                    .redacted(reason: self.datasource.hasLoaded ? [] : .placeholder)
                Spacer().frame(height: 16)
                
                if self.datasource.hasLoaded && GaryPortal.shared.currentUser?.userUUID != self.datasource.user?.userUUID {
                    
                    Menu(content: {
                        Text("Select Report Reason:")
                        Divider()
                        Button(action: { self.reportUser(reason: "Harassment") }) { Text("Harassment") }
                        Button(action: { self.reportUser(reason: "Breaks Policy") }) { Text("Breaks Policy") }
                        Button(action: { self.reportUser(reason: "Spam") }) { Text("Spam") }
                        Button(action: { self.reportUser(reason: "Threatening Behaviour") }) { Text("Threatening Behaviour") }
                        Divider()
                        Button(action: {}) { Text("Cancel")}
                    }, label: {
                        GPGradientButton(action: {}, buttonText: "Report User", gradientColours: [Color.red])
                            .padding()
                    })
                    
                    GPGradientButton(action: { self.blockUser() }, buttonText: "Block User", gradientColours: [Color.red])
                        .padding()
                }
                
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
        .alert(isPresented: $isShowingAlert, content: {
            Alert(title: Text(alertContent[0]), message: Text(alertContent[1]), dismissButton: .default(Text("Ok")))
        })
    }
    
    func blockUser() {
        UserService.blockUser(blockerUUID: GaryPortal.shared.currentUser?.userUUID ?? "", blockedUUID: self.datasource.user?.userUUID ?? "") { (userblock, error) in
            if let _ = userblock {
                GaryPortal.shared.updateBlocks()
            }
            self.alertContent = ["Success", "User has been blocked, you may have to refresh the chat and feed in order to properly block their content"]
            self.isShowingAlert = true
        }
        
    }
    
    func reportUser(reason: String) {
        UserService.reportUser(uuid: self.datasource.user?.userUUID ?? "", reportedBy: GaryPortal.shared.currentUser?.userUUID ?? "", reason: reason)
        self.alertContent = ["Success", "User reported succesfully, an admin will review the report and may contact you if necessary. You can also block this user if needed."]
        self.isShowingAlert = true
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
                        .multilineTextAlignment(.center)
                    Spacer().frame(height: 16)
                    Text("POSITIVE POINTS: \(self.datasource.user?.userPoints?.positivityPoints ?? 0)")
                        .font(Font.custom("Montserrat-SemiBold", size: 20))
                        .multilineTextAlignment(.center)
                    
                    Divider().padding()

                    Text("PRAYERS: \(self.datasource.user?.userPoints?.prayers ?? 0)")
                        .font(Font.custom("Montserrat-SemiBold", size: 20))
                        .multilineTextAlignment(.center)
                    Spacer().frame(height: 16)
                    Text("MEANINGFUL PRAYERS: \(self.datasource.user?.userPoints?.meaningfulPrayers ?? 0)")
                        .font(Font.custom("Montserrat-SemiBold", size: 20))
                        .multilineTextAlignment(.center)
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
                        .multilineTextAlignment(.center)
                }
                Group {
                    Spacer().frame(height: 16)
                    Text("Positivity Rank:")
                        .font(Font.custom("Montserrat-Regular", size: 20))
                    Spacer().frame(height: 16)
                    Text("\(self.datasource.user?.userRanks?.positivityRank?.rankName ?? "POSITIVITY RANK")")
                        .font(Font.custom("Montserrat-SemiBold", size: 25))
                        .multilineTextAlignment(.center)
                }
                Group {
                    Spacer().frame(height: 16)
                    Text("Team:")
                        .font(Font.custom("Montserrat-Regular", size: 20))
                    Spacer().frame(height: 16)
                    Text("\(self.datasource.user?.userTeam?.team?.teamName ?? "TEAM")")
                        .font(Font.custom("Montserrat-SemiBold", size: 25))
                        .multilineTextAlignment(.center)
                }
                Group {
                    Spacer().frame(height: 16)
                    Text("Team Standing:")
                        .font(Font.custom("Montserrat-Regular", size: 20))
                    Spacer().frame(height: 16)
                    Text("\(self.datasource.user?.userStanding ?? "STANDING")")
                        .font(Font.custom("Montserrat-SemiBold", size: 25))
                        .multilineTextAlignment(.center)
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
    
    enum ActiveSheet: Identifiable {
        case none, rules, book, feedback
        var id: ActiveSheet { self }
    }
    
    @ObservedObject var datasource: ProfileViewDataSource
    @State var image: UIImageView?
    @State var isShowingPrayerRoom = false
    @State var isShowingSettings = false
    
    @State var activeSheet: ActiveSheet?
    
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
                    Spacer().frame(height: 16)
                    GPGradientButton(action: { openURL(url: .rules )}, buttonText: "RULES AND REGULATIONS", gradientColours: rulesGradient)
                    Spacer().frame(height: 16)
                    GPGradientButton(action: { openURL(url: .book )}, buttonText: "COMPUTER DATING", gradientColours: bookGradient)
                    Spacer().frame(height: 16)
                    GPGradientButton(action: { openURL(url: .feedback )}, buttonText: "APP FEEDBACK", gradientColours: feedbackGradient)
                    Spacer().frame(height: 16)
                    GPGradientButton(action: self.showSettings, buttonText: "SETTINGS", gradientColours: settingsGradient)
                        .sheet(isPresented: $isShowingSettings, content: {
                            ProfileSettingsView(datasource: self.datasource)
                        })
                }
                
                Spacer().frame(height: 16)
            }
            .sheet(item: self.$activeSheet) { item in
                if item == ActiveSheet.rules {
                    SafariView(url: GaryPortalConstants.URLs.RulesURL)
                } else if item == ActiveSheet.book {
                    SafariView(url: GaryPortalConstants.URLs.ComputerDatingURL)
                } else {
                    SafariView(url: GaryPortalConstants.URLs.FeedbackURL)
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(20)
            .shadow(radius: 15)
            Spacer().frame(width: 16)
        }
    }
    
    func openURL(url: ActiveSheet) {
        self.activeSheet = url
    }
    
    func showPrayerRoom() {
        self.isShowingPrayerRoom = true
    }
    
    func showSettings() {
        self.isShowingSettings = true
    }
}

