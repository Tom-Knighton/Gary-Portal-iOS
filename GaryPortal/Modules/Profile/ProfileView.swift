//
//  ProfileView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 14/01/2021.
//

import SwiftUI

class ProfileViewDataSource: ObservableObject {
    
    @Published var user: User?
    @Published var posts: [FeedPostDTO]?
    @Published var hasLoaded = false
    
    enum ActiveSheet: Identifiable {
        case none, rules, book, feedback, settings, prayer, otherProfile, staff, website, commandments
        var id: ActiveSheet { self }
    }
    
    @Published var activeSheet: ActiveSheet?
    
    func setup(for uuid: String) {
        UserService.getUser(with: uuid) { (user, error) in
            DispatchQueue.main.async {
                if let user = user {
                    self.user = user
                    self.hasLoaded = true
                    self.loadPostDTOs(for: uuid)
                }
            }
        }
    }
    
    func loadPostDTOs(for uuid: String) {
        FeedService.getFeedDTOs(for: uuid) { (dtos) in
            DispatchQueue.main.async {
                self.posts = dtos ?? []
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
        
        ScrollView {
            VStack(alignment: .leading) {
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color("Section"))
                        .offset(y: geometry.frame(in: .global).minY > 0 ? -geometry.frame(in: .global).minY : 0)
                        .frame(height: (geometry.frame(in: .global).minY > 0 ? geometry.size.height + geometry.frame(in: .global).minY : geometry.size.height) + (edges?.top ?? 0))
                        .edgesIgnoringSafeArea(.all)

                }
                .frame(height: 16)
                ProfileHeaderView(datasource: datasource)
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
                Group {
                    ProfileStatisticsView(datasource: self.datasource)
                        .redacted(reason: self.datasource.hasLoaded ? [] : .placeholder)
                        .padding(.horizontal)
                    Spacer().frame(height: 16)
                    ProfilePostsView(datasource: self.datasource)
                        .redacted(reason: self.datasource.hasLoaded ? [] : .placeholder)
                        .padding(.horizontal)
                    Spacer().frame(height: 16)
                    if GaryPortal.shared.currentUser?.userUUID == self.datasource.user?.userUUID {
                        ProfileMiscView(datasource: self.datasource)
                            .redacted(reason: self.datasource.hasLoaded ? [] : .placeholder)
                            .padding(.horizontal)
                        Spacer().frame(height: 16)
                    }
                    Spacer().frame(height: (edges?.bottom ?? 0) + (edges?.bottom == 0 ? 70 : 30))
                }
            }
        }
        .onAppear {
            self.datasource.setup(for: uuid)
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
            } else if item == ProfileViewDataSource.ActiveSheet.staff {
                StaffRoomView()
            } else {
                CommandmentsView()
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
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
