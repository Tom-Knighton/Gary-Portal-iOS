//
//  ChatConversationView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 09/05/2021.
//

import SwiftUI
import Introspect

struct ChatConversationView: View {
    
    @EnvironmentObject var partialSheetManager: PartialSheetManager
    
    @State var chat: Chat
    @StateObject var datasource = ChatMessagesViewModel()
    @State var paginate = false
    @State var showPaginate = true
    
    @State var selectedMessage: ChatMessage? = nil
    @State var reportMessageUUID: String? = nil
        
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
                        .onTapGesture{ }
                        .onLongPressGesture {
                            self.showMessageOptions(for: message)
                        }

                    }
                    .onChange(of: self.datasource.lastMessageUUID) { newValue in
                        reader.scrollTo(newValue, anchor: .bottom)
                    }
                    .onChange(of: self.datasource.newMessageUUID) { newValue in
                        withAnimation {
                            reader.scrollTo(newValue, anchor: .bottom)
                        }
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
                    self.datasource.sendMessage(messageText: result.rawText, messageTypeId: result.messageTypeId)
                }
            }
        }
        .fullScreenCover(item: $reportMessageUUID, content: { messageUUID in
            GPReportView(reportType: .ChatMessage, toReportId: messageUUID)
        })
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
        .partialSheet(item: $selectedMessage) { message in
            GPSheetOptionsView {
                VStack {
                    if message?.userUUID == GaryPortal.shared.currentUser?.userUUID {
                        GPSheetOption(imageName: "pencil.circle", title: "Edit Message", isDestructive: false, action: { self.editMessage(messageUUID: message?.chatMessageUUID ?? "") } )
                    }
                    GPSheetOption(imageName: "arrowshape.turn.up.left.2.circle", title: "Reply", isDestructive: false, action: { self.replyToMessage(messageUUID: message?.chatMessageUUID ?? "") } )
                    GPSheetOption(imageName: "doc.on.doc", title: "Copy Message Text", isDestructive: false, action: { self.copyMessageText(messageText: message?.messageContent ?? "") } )
                    if message?.userUUID == GaryPortal.shared.currentUser?.userUUID {
                        GPSheetOption(imageName: "trash.circle", title: "Delete Message", isDestructive: true, action: { self.deleteMessage(messageUUID: message?.chatMessageUUID ?? "") } )
                    }
                    GPSheetOption(imageName: "flag.circle", title: "Report Message", isDestructive: true, action: { self.reportMessage(messageUUID: message?.chatMessageUUID ?? "") } )
                    GPSheetOption(title: "Dinosaur Game", isDestructive: false, action: { self.openDinoGame() } )
                }
            }
            .frame(minHeight: self.selectedMessage?.userUUID == GaryPortal.shared.currentUser?.userUUID ? 300 : 200)
        }
    }
    
    func showMessageOptions(for message: ChatMessage) {
        self.selectedMessage = message
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    //MARK: - Message Options
    
    func editMessage(messageUUID: String) {
        //TODO: Scroll to message, send notification to message bar to start editing, save message (new endpoint)
    }
    
    func replyToMessage(messageUUID: String) {
        //TODO: Send notification that message bar should show replying status, add replyMessage to result bar
    }
    
    func copyMessageText(messageText: String) {
        UIPasteboard.general.string = messageText
        GaryPortal.shared.showNotification(data: GPNotificationData(title: "Success", subtitle: "Copied message text", image: "doc.on.doc.fill", imageColor: .primary, onTap: {}))
        withAnimation {
            self.partialSheetManager.closePartialSheet()
        }
    }
    
    func deleteMessage(messageUUID: String) {
        //TODO: Delete message and propogate
    }
    
    func reportMessage(messageUUID: String) {
        self.reportMessageUUID = messageUUID
        withAnimation {
            self.partialSheetManager.closePartialSheet()
        }
    }
    
    func openDinoGame() {
        withAnimation {
            self.partialSheetManager.closePartialSheet()
        }
        let safariView = UIHostingController(rootView: SafariView(url: GaryPortalConstants.URLs.DinoGameURL))
        UIApplication.topViewController()?.present(safariView, animated: true, completion: nil)
        
    }
}
