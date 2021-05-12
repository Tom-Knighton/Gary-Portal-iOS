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
    @State var messages: [ChatMessage] = []
    @State var paginate = false
    @State var showPaginate = true

    var body: some View {
        let uuid = GaryPortal.shared.currentUser?.userUUID ?? ""
        ZStack {
            Color("Section").edgesIgnoringSafeArea(.all)
            VStack {
                ScrollViewReader { reader in
                    GPReverseList(self.messages, reverseItemOrder: false, hasReachedTop: $paginate, canShowPaginator: $showPaginate) { message in
                        ConversationMessageView(chatMessageDTO: ChatMessageDTO(from: message))
                    }
                }
                ChatMessageBar { result in
                    self.text = result.rawText
                }
            }

        }
        .navigationTitle(self.chat.getTitleToDisplay(for: uuid))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            ChatService.getChatMessages(for: chat.chatUUID ?? "") { messages, _ in
                if let messages = messages {
                    self.messages = messages
                }
            }
        }
    }
}

struct convpreview: PreviewProvider {
    
    static var previews: some View {
        ChatConversationView(chat: Chat(chatUUID: "0", chatName: "Test", chatIsProtected: false, chatIsPublic: false, chatIsDeleted: false, chatCreatedAt: Date(), chatMembers: [], chatMessages: [], lastChatMessage: nil))
    }
}

