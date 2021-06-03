//
//  ConversationMessageView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 12/05/2021.
//

import SwiftUI
import AttributedText

struct ConversationMessageView: View {
    
    @State var chatMessageDTO: ChatMessageDTO
    
    var body: some View {
        ZStack {
            let isWithinPrevious = self.chatMessageDTO.isMessageWithinPrevious()
            VStack {
                if !isWithinPrevious {
                    Spacer().frame(height: 8)
                }
                HStack(alignment: .top) {
                    Spacer().frame(width: 8)
                    if !isWithinPrevious {
                        AsyncImage(url: chatMessageDTO.messageSender.userProfileImageUrl ?? "")
                            .frame(width: 50, height: 50, alignment: .bottom)
                            .clipShape(Circle())
                    } else {
                        Spacer().frame(width: 58)
                    }
                   
                    VStack(spacing: 0) {
                        if !isWithinPrevious {
                            Text(chatMessageDTO.messageSender.userFullName ?? "")
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                        }
                        content
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 0)
                            .padding(.top, isWithinPrevious ? 0 : 8)
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                    Spacer().frame(width: 8)
                }
            }
        }
        
    }
    
    @ViewBuilder
    var content: some View {
        switch self.chatMessageDTO.messageTypeId {
        case 1:
            AttributedText(self.chatMessageDTO.messageRawContent.convertToAttributedHyperlinks())
                .frame(maxWidth: .infinity, alignment: .leading)
        case 2:
            AsyncImage(url: chatMessageDTO.messageRawContent)
                .cornerRadius(10)
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 400)
                .cornerRadius(10)   
        case 8:
            AsyncImage(url: chatMessageDTO.messageRawContent)
                .frame(width: 70, height: 70)
        default:
            Text(chatMessageDTO.messageRawContent)
                .frame(maxWidth: .infinity, alignment: .leading)
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
