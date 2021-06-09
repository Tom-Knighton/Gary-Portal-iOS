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
                    GPChatListView(messages: self.datasource.messages, isLoading: self.datasource.canLoadMore, onScrolledToTop: self.datasource.loadMoreContent)
                    .onChange(of: self.datasource.messages.count, perform: { _ in
                        if let lastMessage = self.datasource.messages.first {
                            reader.scrollTo(lastMessage.chatMessageUUID ?? "", anchor: .bottom)
                        }
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

struct GPChatListView: View {
    
    let messages: [ChatMessage]
    let isLoading: Bool
    let onScrolledToTop: () -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(self.messages.reversed(), id: \.chatMessageUUID) { message in
                    let previousMessage = self.messages.after(message)
                    let previousDTO: ChatMessageDTO? = ChatMessageDTO(from: previousMessage)
                    ConversationMessageView(chatMessageDTO: ChatMessageDTO(from: message, previousMessage: previousDTO))
                        .onAppear {
                            if self.messages.last == message {
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

