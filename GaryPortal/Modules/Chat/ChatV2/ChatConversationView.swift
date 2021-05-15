//
//  ChatConversationView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 09/05/2021.
//

import SwiftUI

struct ChatConversationView: View {
    
    @State var chat: Chat
    @StateObject var datasource = ChatMessagesViewModel()
    @State var paginate = false
    @State var showPaginate = true

    var body: some View {
        let uuid = GaryPortal.shared.currentUser?.userUUID ?? ""
        ZStack {
            Color("Section").edgesIgnoringSafeArea(.all)
            VStack {
                ScrollViewReader { reader in
                    GPReverseList(self.datasource.messages, reverseItemOrder: false, hasReachedTop: $paginate, canShowPaginator: $showPaginate) { message in
                        ConversationMessageView(chatMessageDTO: ChatMessageDTO(from: message))
                            .id(message.chatMessageUUID ?? "")
                    }
                    .onChange(of: self.datasource.lastMessageUUID, perform: { value in
                        reader.scrollTo(value, anchor: .bottom)
                    })
                }
                ChatMessageBar { result in
                }
            }
        }
        .navigationTitle(self.chat.getTitleToDisplay(for: uuid))
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: paginate, perform: { value in
            if value {
                self.datasource.loadMoreContent()
            }
        })
        .onChange(of: self.datasource.canLoadMore, perform: { value in
            self.showPaginate = value
        })
        .onAppear {
            self.datasource.setup(for: self.chat.chatUUID ?? "")
        }
    }
}

struct convpreview: PreviewProvider {
    
    static var previews: some View {
        ChatConversationView(chat: Chat(chatUUID: "0", chatName: "Test", chatIsProtected: false, chatIsPublic: false, chatIsDeleted: false, chatCreatedAt: Date(), chatMembers: [], chatMessages: [], lastChatMessage: nil))
    }
}

