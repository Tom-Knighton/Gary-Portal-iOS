//
//  ConversationMessageView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 12/05/2021.
//

import SwiftUI
import LinkPresentation
import AVKit

struct ConversationMessageView: View {
    
    @State var chatMessageDTO: ChatMessageDTO
    var body: some View {
        let isWithinPrevious = self.chatMessageDTO.isMessageWithinPrevious()
        VStack {
            HStack(alignment: .top) {
                if !isWithinPrevious {
                    profileImage
                } else {
                    Spacer().frame(width: 58)
                }
                VStack(spacing: 0) {
                    if !isWithinPrevious {
                        HStack {
                            nameToDisplay
                            Text(self.chatMessageDTO.messageSentAt.niceDateAndTime())
                                .font(.caption)
                                .frame(alignment: .center)
                            Spacer()
                        }
                    }
                    content
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .padding(.vertical, 0)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, isWithinPrevious ? 0 : 12)
        .padding(.horizontal, 8)
    }
    
    @ViewBuilder
    var profileImage: some View {
        let isBot = self.chatMessageDTO.messageTypeId == 5
        if isBot {
            Image("bot")
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
        } else {
            AsyncImage(url: self.chatMessageDTO.messageSender.userProfileImageUrl ?? "")
                .frame(width: 50, height: 50)
                .clipShape(Circle())
        }
    }
    
    @ViewBuilder
    var nameToDisplay: some View {
        let isBot = self.chatMessageDTO.messageTypeId == 5
        let isAdmin = self.chatMessageDTO.messageTypeId == 7
        let name = !isBot ? self.chatMessageDTO.messageSender.userFullName ?? "[Deleted User]" : "Gary Portal Bot"
        Text(name)
            .bold()
            .foregroundColor(isBot ? .orange : isAdmin ? .red : .primary)
    }
    
    
    @State var previewToggle = false
    
    @ViewBuilder
    var content: some View {
        switch self.chatMessageDTO.messageTypeId {
        case 1:
            // Text Message
            VStack {
                if self.chatMessageDTO.messageRawContent.containsOnlyEmojis() && self.chatMessageDTO.messageRawContent.count <= 5 {
                    Text(self.chatMessageDTO.messageRawContent)
                        .font(.system(size: 40))
                } else {
                    LinkedText(self.chatMessageDTO.messageRawContent)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ForEach(self.chatMessageDTO.messageRawContent.getUrls(), id: \.self) { url in
                        URLPreview(previewURL: url, togglePreview: $previewToggle)
                            .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50, alignment: .leading)
                    }
                }
            }
        case 2:
            // Image Message
            AsyncImage(url: chatMessageDTO.messageRawContent)
                .cornerRadius(10)
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 400)
                .cornerRadius(10)
                
        case 3:
            // Video Message
            if let url = URL(string: self.chatMessageDTO.messageRawContent) {
                VideoPlayerContainerView(viewModel: VideoViewModel(videoURL: url))
                    .cornerRadius(10)
                    .frame(height: 400)
                    .cornerRadius(10)
            } else {
                LinkedText(self.chatMessageDTO.messageRawContent)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        case 4:
            // File Message
            EmptyView()
        case 5:
            // Bot Message
            VStack {
                if self.chatMessageDTO.messageRawContent.trim().hasSuffix(".gif") {
                    GIFView(gifUrl: self.chatMessageDTO.messageRawContent)
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: 250, maxHeight: 400)
                } else {
                    LinkedText(self.chatMessageDTO.messageRawContent)
                        .frame(maxWidth: .infinity, alignment: .center)
                    ForEach(self.chatMessageDTO.messageRawContent.getUrls(), id: \.self) { url in
                        URLPreview(previewURL: url, togglePreview: $previewToggle)
                            .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50, alignment: .leading)
                    }
                }
                
            }
            .cornerRadius(10)
            .padding()
            .background(Color("Section").shadow(radius: 3).cornerRadius(10))
            .shadow(radius: 3)
        case 7:
            // Admin Message
            VStack {
                LinkedText(self.chatMessageDTO.messageRawContent)
                    .frame(maxWidth: .infinity, alignment: .center)
                ForEach(self.chatMessageDTO.messageRawContent.getUrls(), id: \.self) { url in
                    URLPreview(previewURL: url, togglePreview: $previewToggle)
                        .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50, alignment: .leading)
                }
            }
            .cornerRadius(10)
            .padding()
            .background(Color("Section").shadow(radius: 3).cornerRadius(10).padding(.top, 4))
            .shadow(color: .red, radius: 3)
        case 8:
            AsyncImage(url: chatMessageDTO.messageRawContent)
                .frame(width: 70, height: 70)
        default:
            VStack {
                LinkedText(self.chatMessageDTO.messageRawContent)
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
