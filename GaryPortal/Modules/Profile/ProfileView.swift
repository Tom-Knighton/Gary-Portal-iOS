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
    
    enum ActiveSheet: Identifiable {
        case none, rules, book, feedback, settings, prayer, otherProfile, staff, website
        var id: ActiveSheet { self }
    }
    
    @Published var activeSheet: ActiveSheet?

    
    func setup(for uuid: String) {
        UserService.getUser(with: uuid) { (user, error) in
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
    @State var edges = UIApplication.shared.windows.first?.safeAreaInsets

    @State var alertContent: [String] = []
    @State var isShowingAlert = false
    @State var viewingChat: Chat?
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                ProfileHeaderView(datasource: self.datasource)
                    .redacted(reason: self.datasource.hasLoaded ? [] : .placeholder)
                Spacer().frame(height: 16)
                
                if self.datasource.hasLoaded && GaryPortal.shared.currentUser?.userUUID != self.datasource.user?.userUUID {
                    HStack {
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
                        })
                        
                        GPGradientButton(action: { self.blockUser() }, buttonText: "Block User", gradientColours: [Color.red])
                    }
                    GPGradientButton(action: { self.dmUser() }, buttonText: Text(Image(systemName: "envelope")) + Text("  Message User"), gradientColours: [Color(UIColor(hexString: "#00467F")), Color(UIColor(hexString: "#A5CC82"))])
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
                Spacer().frame(height: (edges?.bottom ?? 0) + 30)
            }
            .frame(width: geometry.size.width)
        }
        .onAppear {
            self.datasource.setup(for: uuid)
            print("on appear profile")
        }
        .alert(isPresented: $isShowingAlert, content: {
            Alert(title: Text(alertContent[0]), message: Text(alertContent[1]), dismissButton: .default(Text("Ok")))
        })
        .sheet(item: $datasource.activeSheet) { item in
            if item == ProfileViewDataSource.ActiveSheet.rules {
                SafariView(url: GaryPortalConstants.URLs.RulesURL)
            } else if item == ProfileViewDataSource.ActiveSheet.book {
                SafariView(url: GaryPortalConstants.URLs.ComputerDatingURL)
            } else if item == ProfileViewDataSource.ActiveSheet.feedback {
                SafariView(url: GaryPortalConstants.URLs.FeedbackURL)
            } else if item == ProfileViewDataSource.ActiveSheet.prayer {
                PrayerRoomView(datasource: self.datasource)
            } else if item == ProfileViewDataSource.ActiveSheet.settings {
                ProfileSettingsView(datasource: self.datasource)
            } else if item == ProfileViewDataSource.ActiveSheet.otherProfile {
                if let chat = self.viewingChat {
                    ChatView(chat: chat)
                }
            } else if item == ProfileViewDataSource.ActiveSheet.website {
                SafariView(url: GaryPortalConstants.URLs.WebsiteURL)
            } else {
                StaffRoomView()
            }
        }
        .navigationBarHidden(true)
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
    
    func dmUser() {
        ChatService.getChats(for: GaryPortal.shared.currentUser?.userUUID ?? "") { (chats, error) in
            if let chats = chats {
                let uuids = [GaryPortal.shared.currentUser?.userUUID ?? "", uuid].sorted()
                let exists = chats.contains { (chat) -> Bool in
                    let existing = chat.chatMembers?.compactMap { $0.userUUID }.sorted() ?? []
                    return existing.count == uuids.count && existing == uuids
                }
                if exists {
                    let chat = chats.first { (chat) -> Bool in
                        let existing = chat.chatMembers?.compactMap { $0.userUUID }.sorted() ?? []
                        return existing.count == uuids.count && existing == uuids
                    }
                    if let chat = chat {
                        DispatchQueue.main.async {
                            self.viewingChat = chat
                            self.datasource.activeSheet = .otherProfile
                        }
                    }
                } else {
                    createDM()
                }
            }
        }
    }
    
    func createDM() {
        let uuids = [GaryPortal.shared.currentUser?.userUUID ?? "", uuid].sorted()
        let chat = Chat(chatUUID: "", chatName: "GP$AG_\(uuids[0])-\(uuids[1])", chatIsProtected: false, chatIsPublic: false, chatIsDeleted: false, chatCreatedAt: Date(), chatMembers: nil, chatMessages: nil, lastChatMessage: nil)
        
        ChatService.createChat(chat: chat) { (createdChat, error) in
            if var chat = createdChat {
                for id in uuids {
                    ChatService.addUserToChatByUUID(id, chatUUID: chat.chatUUID ?? "") { (member, _) in
                        if let member = member {
                            chat.chatMembers?.append(member)
                        }
                    }
                }
                
                let creationMessage = ChatMessage(chatMessageUUID: "", chatUUID: chat.chatUUID ?? "", userUUID: GaryPortal.shared.currentUser?.userUUID, messageContent: "Chat Created", messageCreatedAt: Date(), messageHasBeenEdited: false, messageTypeId: 6, messageIsDeleted: false, user: nil, userDTO: nil, chatMessageType: nil)
                
                ChatService.postNewMessage(creationMessage, to: chat.chatUUID ?? "") { (message, error) in
                    if let message = message {
                        chat.lastChatMessage = message
                        self.viewingChat = chat
                        self.datasource.activeSheet = .otherProfile
                    }
                }
            }
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
                    .pinchToZoom()
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
                        GPGradientButton(action: { self.datasource.activeSheet = .staff }, buttonText: "Staff Panel", gradientColours: privilegedGradient)
                    } else {
                        GPGradientButton(action: { self.datasource.activeSheet = .website }, buttonText: "Visit Website", gradientColours: websiteGradient)
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
    
    
    @ObservedObject var datasource: ProfileViewDataSource
        
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
                    GPGradientButton(action: { openURL(url: .prayer )}, buttonText: "PRAYER ROOM", gradientColours: prayerGradient)
                    Spacer().frame(height: 16)
                    GPGradientButton(action: { openURL(url: .rules )}, buttonText: "RULES AND REGULATIONS", gradientColours: rulesGradient)
                    Spacer().frame(height: 16)
                    GPGradientButton(action: { openURL(url: .book )}, buttonText: "COMPUTER DATING", gradientColours: bookGradient)
                    Spacer().frame(height: 16)
                    GPGradientButton(action: { openURL(url: .feedback )}, buttonText: "APP FEEDBACK", gradientColours: feedbackGradient)
                    Spacer().frame(height: 16)
                    GPGradientButton(action: { openURL(url: .settings )}, buttonText: "SETTINGS", gradientColours: settingsGradient)
  
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
    
    func openURL(url: ProfileViewDataSource.ActiveSheet) {
        self.datasource.activeSheet = url
    }
}

