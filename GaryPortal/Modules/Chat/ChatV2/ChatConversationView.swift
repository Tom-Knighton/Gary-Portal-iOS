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

struct GPChatListView: View {
    
    let messages: [ChatMessage]
    let isLoading: Bool
    let onScrolledToTop: () -> Void

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(self.messages.reversed(), id: \.chatMessageUUID) { message in
//                    let previousMessage = self.messages.after(message)
//                    let previousDTO: ChatMessageDTO? = ChatMessageDTO(from: previousMessage)
                    ConversationMessageView(chatMessageDTO: ChatMessageDTO(from: message))
                        .onAppear {
                            if self.messages.last == message {
                                print("scrolled to top")
                                self.onScrolledToTop()
                            }
                        }
                        .id(message.chatMessageUUID)
                }
            }
        }
    }
}

struct Spinner: UIViewRepresentable {
    let style: UIActivityIndicatorView.Style
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView(style: style)
            spinner.hidesWhenStopped = true
            spinner.startAnimating()
            return spinner
        }
        
        func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {}
}

struct convpreview: PreviewProvider {
    
    static var previews: some View {
        ChatConversationView(chat: Chat(chatUUID: "0", chatName: "Test", chatIsProtected: false, chatIsPublic: false, chatIsDeleted: false, chatCreatedAt: Date(), chatMembers: [], chatMessages: [], lastChatMessage: nil))
    }
}
