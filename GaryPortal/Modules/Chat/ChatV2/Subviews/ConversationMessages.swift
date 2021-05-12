//
//  ConversationMessageView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 12/05/2021.
//

import SwiftUI

struct ConversationMessageView: View {
    @State var chatMessageDTO: ChatMessageDTO
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Spacer().frame(width: 8)
                AsyncImage(url: chatMessageDTO.messageSender.userProfileImageUrl ?? "")
                    .frame(width: 50, height: 50, alignment: .bottom)
                    .clipShape(Circle())
                VStack(spacing: 0) {
                    Text(chatMessageDTO.messageSender.userFullName ?? "")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    content
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .top)
                Spacer().frame(width: 8)
            }
        }
    }
    
    @ViewBuilder
    var content: some View {
        switch self.chatMessageDTO.messageTypeId {
        case 1:
            Text(chatMessageDTO.messageRawContent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
        case 2:
            AsyncImage(url: chatMessageDTO.messageRawContent)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
        case 8:
            AsyncImage(url: chatMessageDTO.messageRawContent)
                .frame(width: 70, height: 70)
        default:
            Text(chatMessageDTO.messageRawContent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
        }
    }
}

struct ConversationMessageView_Previews: PreviewProvider {
    static let messageDTO = ChatMessageDTO(from: ChatMessage(chatMessageUUID: "0", chatUUID: "0", userUUID: "1", messageContent: "Seems CIV department for the Framework is missing on DEV", messageCreatedAt: Date(), messageHasBeenEdited: false, messageTypeId: 1, messageIsDeleted: false, user: nil, userDTO: nil, chatMessageType: nil))
    static var previews: some View {
        VStack {
            ConversationMessageView(chatMessageDTO: messageDTO)
            ConversationMessageView(chatMessageDTO: messageDTO)
            ConversationMessageView(chatMessageDTO: messageDTO)

        }
    }
}
