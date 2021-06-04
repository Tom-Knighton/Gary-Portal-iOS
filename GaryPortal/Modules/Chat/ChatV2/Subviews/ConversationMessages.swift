//
//  ConversationMessageView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 12/05/2021.
//

import SwiftUI
import AttributedText
import LinkPresentation
import AVKit

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
                            HStack {
                                Text(chatMessageDTO.messageSender.userFullName ?? "")
                                    .bold()
                                Text(chatMessageDTO.messageSentAt.niceDateAndTime())
                                    .font(.caption)
                                    .frame(alignment: .center)
                                Spacer()
                            }
                            
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
    
    @State var previewToggle = false
    @State var playingVideo = false
    @ViewBuilder
    var content: some View {
        switch self.chatMessageDTO.messageTypeId {
        case 1:
            VStack {
                if self.chatMessageDTO.messageRawContent.containsOnlyEmojis() && self.chatMessageDTO.messageRawContent.count <= 5 {
                    Text(self.chatMessageDTO.messageRawContent)
                        .font(.system(size: 40))
                } else {
                    AttributedText(self.chatMessageDTO.messageRawContent.convertToAttributedHyperlinks())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ForEach(self.chatMessageDTO.messageRawContent.getUrls(), id: \.self) { url in
                        URLPreview(previewURL: url, togglePreview: $previewToggle)
                            .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50, alignment: .leading)
                    }
                }
            }
        case 2:
            AsyncImage(url: chatMessageDTO.messageRawContent)
                .cornerRadius(10)
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 400)
                .cornerRadius(10)
        case 3:
            if let url = URL(string: self.chatMessageDTO.messageRawContent) {
                VideoPlayer(player: AVPlayer(url: url))
                    .cornerRadius(10)
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 400)
                    .cornerRadius(10)
            } else {
                AttributedText(self.chatMessageDTO.messageRawContent.convertToAttributedHyperlinks())
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        case 8:
            AsyncImage(url: chatMessageDTO.messageRawContent)
                .frame(width: 70, height: 70)
        default:
            VStack {
                AttributedText(self.chatMessageDTO.messageRawContent.convertToAttributedHyperlinks())
                    .frame(maxWidth: .infinity, alignment: .leading)
                ForEach(self.chatMessageDTO.messageRawContent.getUrls(), id: \.self) { url in
                    URLPreview(previewURL: url, togglePreview: $previewToggle)
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 50)
                }
            }
        }
    }
}

struct URLPreview : UIViewRepresentable {
    var previewURL:URL
    //Add binding
    @Binding var togglePreview: Bool

    func makeUIView(context: Context) -> LPLinkView {
        let view = LPLinkView(url: previewURL)
        return view
    }
    
    func updateUIView(_ uiView: LPLinkView, context: UIViewRepresentableContext<URLPreview>) {
    }
}


struct ConversationMessageView_Previews: PreviewProvider {
    static let messageDTO = ChatMessageDTO(from: ChatMessage(chatMessageUUID: "0", chatUUID: "0", userUUID: "1", messageContent: "Seems CIV department for the Framework is missing on DEV", messageCreatedAt: Date(), messageHasBeenEdited: false, messageTypeId: 1, messageIsDeleted: false, user: nil, userDTO: nil, chatMessageType: nil, replyingToDTO: nil))
    static var previews: some View {
        VStack {
            ConversationMessageView(chatMessageDTO: messageDTO)
            ConversationMessageView(chatMessageDTO: messageDTO)
            ConversationMessageView(chatMessageDTO: messageDTO)

        }
    }
}
