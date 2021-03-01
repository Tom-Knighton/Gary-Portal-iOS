//
//  ChatMemberList.swift
//  GaryPortal
//
//  Created by Tom Knighton on 10/02/2021.
//

import SwiftUI

struct ChatMemberList: View {
    var chatUUID: String
    @State var users: [ChatMember] = []
    @State var showUsernameAlert = false
    @State var usernameText = ""
    @State var showingAlert = false
    @State var alertContent: [String] = []
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)
            ScrollView {
                LazyVStack {
                    ForEach(users, id: \.userUUID) { user in
                        let lastReadMessage = user.userUUID == GaryPortal.shared.currentUser?.userUUID ? "Last Read: Now" : "Last Read: \(user.lastReadAt?.niceDateAndTime() ?? "Never")"
                        UserListElement(user: user.userDTO, secondaryText: lastReadMessage, displaysChevron: false)
                    }
                }
            }
            
            AZAlert(title: "Add User", message: "Enter the username of the user to add to this chat:", isShown: $showUsernameAlert, text: $usernameText, onDone: { username in
                self.addUser(username)
            })
        }
        .alert(isPresented: $showingAlert, content: {
            Alert(title: Text(alertContent[0]), message: Text(alertContent[1]), dismissButton: .default(Text("Ok"), action: {
                self.presentationMode.wrappedValue.dismiss()
            }))
        })
        .navigationBarTitle("Members")
        .navigationBarItems(trailing:
            Button(action: { self.showUsernameAlert = true }, label: {
                Image(systemName: "person.badge.plus")
            })
        )
    }
    
    func addUser(_ username: String) {
        ChatService.addUserToChat(username.trim(), chatUUID: self.chatUUID) { (newMember, error) in
            if let newMember = newMember {
                GaryPortal.shared.chatConnection?.addedUserToChat(newMember, to: self.chatUUID)
                GaryPortal.shared.chatConnection?.notifyUserAdded(newMember.userUUID ?? "", to: self.chatUUID)
                self.alertContent = ["Success", "User added successfully"]
                self.showingAlert = true
            }
        }
    }
}

