//
//  ChatConversationView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 09/05/2021.
//

import SwiftUI
import Introspect

struct ChatConversationView: View {
    
    @State var chat: Chat
    @StateObject var datasource = ChatMessagesViewModel()
    @State var paginate = false
    @State var showPaginate = true

    var body: some View {
        let uuid = GaryPortal.shared.currentUser?.userUUID ?? ""
        ZStack {
            Color("Section").edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                ScrollViewReader { reader in
                    GPReverseList(self.datasource.messages, hasReachedTop: $paginate, canShowPaginator: $showPaginate) { message in
                        VStack {
                            let index = datasource.messages.firstIndex(where: { $0.chatMessageUUID == message.chatMessageUUID })
                            let lastMessage = index == 0 ? nil : self.datasource.messages[(index ?? 0) - 1]
                            ConversationMessageView(chatMessageDTO: ChatMessageDTO(from: message, previousMessage: ChatMessageDTO(from: lastMessage)))
                                .id(message.chatMessageUUID)
                                .padding(.bottom, message.chatMessageUUID == self.datasource.messages.last?.chatMessageUUID ? 8 : 0)
                        }
                    }
                    .onChange(of: self.datasource.lastMessageUUID) { newValue in
                        reader.scrollTo(newValue, anchor: .bottom)
                    }
                    .onChange(of: self.datasource.canLoadMore) { newValue in
                        self.showPaginate = newValue
                    }
                    .onReceive(NotificationCenter.default.publisher(for: .textFieldStartedEditing)) { notification in
                        withAnimation(.easeInOut) {
                            reader.scrollTo(self.datasource.messages.last?.chatMessageUUID ?? "")
                        }
                    }
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

