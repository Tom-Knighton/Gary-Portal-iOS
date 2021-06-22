//
//  CreateChatView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 18/02/2021.
//

import SwiftUI

class CreateChatDataSource: ObservableObject {
    @Published var users: [UserDTO] = []
    
    func load() {
        let teamId = GaryPortal.shared.currentUser?.userIsAdmin == true ? 0 : GaryPortal.shared.currentUser?.userTeam?.teamId ?? 0
        UserService.getAllUsers(for: teamId) { (users, error) in
            DispatchQueue.main.async {
                self.users = (users?.compactMap { $0.ConvertToDTO() }) ?? []
            }
        }
    }
    
    func getFilteredUsers() -> [UserDTO] {
        return self.users.filter( { GaryPortal.shared.currentUser?.hasBlockedUUID(uuid: $0.userUUID ?? "") == false && $0.userUUID != GaryPortal.shared.currentUser?.userUUID })
    }
}

struct CreateChatView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var chatDataSource: ChatListViewModel
    @ObservedObject var datasource = CreateChatDataSource()
    @State var chatName = ""
    @State var toggledUUIDS: [String] = []
    @State var alertContent: [String] = []
    @State var isShowingAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer().frame(height: 8)
                if self.toggledUUIDS.count >= 2 {
                    GPTextField(text: $chatName, placeHolder: "Chat name...")
                        .padding()
                        .animation(.easeInOut)
                }
                List {
                    ForEach(self.datasource.getFilteredUsers(), id: \.userUUID) { user in
                        HStack {
                            UserListElement(user: user, displaysChevron: false)
                            Image(systemName: toggledUUIDS.contains(where: { $0 == user.userUUID ?? ""}) ? "checkmark.circle.fill" : "circle")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(toggledUUIDS.contains(where: { $0 == user.userUUID ?? ""}) ? .green : .gray)
                                .onTapGesture {
                                    if toggledUUIDS.contains(where: { $0 == user.userUUID ?? ""}) {
                                        self.toggledUUIDS.removeAll(where: { $0 == user.userUUID ?? ""})
                                    } else {
                                        self.toggledUUIDS.append(user.userUUID ?? "")
                                    }
                                }
                                .animation(.spring())
                        }
                    }
                }
            }
            .navigationTitle("Create a Chat")
            .navigationBarItems(trailing:
                Button(action: { self.makeChat() }) { Text("Create Chat")}
            )
            .alert(isPresented: $isShowingAlert) {
                Alert(title: Text(alertContent[0]), message: Text(alertContent[1]), dismissButton: .default(Text("Ok")))
            }
            .onAppear {
                self.datasource.load()
            }
        }
    }
    
    func makeChat() {
        guard self.toggledUUIDS.count > 0 else {
            self.alertContent = ["Error", "Please select some users to create a chat with"]
            self.isShowingAlert = true
            return
        }
        
        guard self.toggledUUIDS.count < 2 || (self.toggledUUIDS.count >= 2 && !self.chatName.isEmptyOrWhitespace()) else {
            self.alertContent = ["Error", "Please enter a name for your group chat"]
            self.isShowingAlert = true
            return
        }
        
        self.toggledUUIDS.append(GaryPortal.shared.currentUser?.userUUID ?? "")
        
        guard !self.chatDataSource.doesChatWithUsersExist(uuids: self.toggledUUIDS) else {
            self.alertContent = ["Error", "A chat with these users already exists"]
            self.isShowingAlert = true
            return
        }
        
        let name = self.toggledUUIDS.count >= 3 ? self.chatName : "GP$AG_\(self.toggledUUIDS[0])-\(self.toggledUUIDS[1])"
       
        let chat = Chat(chatUUID: "", chatName: name, chatIsProtected: false, chatIsPublic: false, chatIsDeleted: false, chatCreatedAt: Date(), chatMembers: nil, chatMessages: nil, lastChatMessage: nil)
        
        ChatService.createChat(chat: chat) { (createdChat, error) in
            if var chat = createdChat {
                for id in self.toggledUUIDS {
                    ChatService.addUserToChatByUUID(id, chatUUID: chat.chatUUID ?? "") { (member, _) in
                        if let member = member {
                            GaryPortal.shared.chatConnection?.notifyUserAdded(member.userUUID ?? "", to: chat.chatUUID ?? "")
                        }
                    }
                }
                let creationMessage = ChatMessage(chatMessageUUID: "", chatUUID: chat.chatUUID ?? "", userUUID: GaryPortal.shared.currentUser?.userUUID, messageContent: "Chat Created", messageCreatedAt: Date(), messageHasBeenEdited: false, messageTypeId: 6, messageIsDeleted: false, replyingToUUID: nil, user: nil, userDTO: nil, chatMessageType: nil, replyingToDTO: nil)
                
                ChatService.postNewMessage(creationMessage, to: chat.chatUUID ?? "") { (message, error) in
                    if let message = message {
                        chat.lastChatMessage = message
                        self.chatDataSource.addNewChat(chat)
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
