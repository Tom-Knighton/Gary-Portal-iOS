//
//  ChatConversationView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 09/05/2021.
//

import SwiftUI

struct ChatConversationView: View {
    
    @State var chat: Chat
    @State var text: String = ""
    @State var keyboardOffset: CGFloat = 0.0

    var body: some View {
        let uuid = GaryPortal.shared.currentUser?.userUUID ?? ""
        VStack {
            Text("hey")
            Spacer()
            ChatMessageBar()
        }
        .background(Color("Section").ignoresSafeArea())
        .navigationTitle(self.chat.getTitleToDisplay(for: uuid))
        .onAppear {
            UINavigationBar.appearance().backgroundColor = UIColor(named: "Section")
        }
    }
}

struct convpreview: PreviewProvider {
    
    static var previews: some View {
        ChatConversationView(chat: Chat(chatUUID: "0", chatName: "Test", chatIsProtected: false, chatIsPublic: false, chatIsDeleted: false, chatCreatedAt: Date(), chatMembers: [], chatMessages: [], lastChatMessage: nil))
    }
}

