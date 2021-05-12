//
//  ChatMessageBar.swift
//  GaryPortal
//
//  Created by Tom Knighton on 05/05/2021.
//

import Foundation
import SwiftUI

struct ChatMessageBarView: View {
    
    @Binding var text: String
    
    var onSendAction: (_ text: String, _ hasMedia: Bool, _ imageURL: String?, _ videoURL: String?, _ stickerURL: String?) -> ()
    
    @State var isShowingCamera = false
    @State var isShowingStickers = false
    
    @State var play = true
    
    @State var hasMedia = false
    @State var imageURL: String? = nil
    @State var videoURL: String? = nil
    
    var isCameraAllowed = true
    var placeHolderText = "Your message..."
    
    init(content: Binding<String>, _ onSend: @escaping (_ text: String, _ hasMedia: Bool, _ imageURL: String?, _ videoURL: String?, _ stickerURL: String?) -> ()) {
        self.onSendAction = onSend
        _text = content
    }
    
    init(content: Binding<String>, isCameraAllowed: Bool, placeHolderText: String, _ onSend: @escaping (_ text: String, _ hasMedia: Bool, _ imageURL: String?, _ videoURL: String?, _ stickerURL: String?) -> ()) {
        self.onSendAction = onSend
        self.isCameraAllowed = isCameraAllowed
        self.placeHolderText = placeHolderText
        _text = content
    }
    
    var body: some View {
        VStack {
            if self.hasMedia {
                HStack {
                    Spacer().frame(width: 16)
                    if self.imageURL != nil {
                        AsyncImage(url: self.imageURL ?? "")
                            .cornerRadius(10)
                            .frame(width: 80, height: 80)
                            .aspectRatio(contentMode: .fill)
                            .onTapGesture {
                                self.hasMedia = false
                                self.imageURL = nil
                            }
                    }
                    if self.videoURL != nil {
                        PlayerView(url: self.videoURL ?? "", play: $play)
                            .cornerRadius(10)
                            .frame(width: 80, height: 80)
                            .aspectRatio(contentMode: .fill)
                            .onTapGesture {
                                self.hasMedia = false
                                self.videoURL = nil
                            }
                    }
                   
                    Spacer()
                }
            }
            Spacer().frame(height: 8)
                .sheet(isPresented: $isShowingStickers) {
                    StickerPickerView() { url in
                        self.isShowingStickers = false
                        self.onSendAction("", true, "", "", url)
                    }
                }
            HStack {
                
                HStack(spacing: 8) {
                    
                    TextEditor(text: $text)
                        .frame(maxHeight: 100)
                        .fixedSize(horizontal: false, vertical: true)
                        .background(
                            ZStack {
                                if self.text.isEmpty {
                                    HStack {
                                        Spacer().frame(width: 1)
                                        Text(self.placeHolderText)
                                            .foregroundColor(.gray)
                                            .disabled(true)
                                        Spacer()
                                    }
                                }
                            }
                        )
                    if self.isCameraAllowed {
                        Button(action: { self.isShowingCamera = true }) {
                            Image(systemName: "camera.fill")
                                .font(.body)
                        }
                        .foregroundColor(.gray)
                        
                        Button(action: { self.isShowingStickers = true }) {
                            Image(systemName: "mustache")
                                .font(.body)
                        }
                    }
                    
                }
                .padding(.horizontal, 8)
                .background(Color("Section"))
                .cornerRadius(10)
                .shadow(radius: 3)
                
                if !text.trim().isEmptyOrWhitespace() || self.hasMedia {
                    withAnimation(.easeIn) {
                        Button(action: { self.onSendAction(self.text, self.hasMedia, self.imageURL, self.videoURL, ""); self.hasMedia = false; self.imageURL = ""; self.videoURL = "";}) {
                            Image(systemName: "paperplane.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 15, height: 23)
                                .padding(13)
                                .shadow(radius: 3)
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .clipShape(Circle())

                        }
                        .foregroundColor(.gray)
                    }
                   
                }
            }
            .transition(.slide)
            .animation(.easeInOut)
            .padding(.horizontal, 15)
            .padding(.bottom, 8)
            .background(Color.clear)
            .fullScreenCover(isPresented: $isShowingCamera, onDismiss: {}) {
                CameraView { (success, isVideo, urlToAsset) in
                    self.isShowingCamera = false
                    if success {
                        if isVideo {
                            self.videoURL = urlToAsset?.absoluteString ?? ""
                            self.hasMedia = true
                        } else {
                            self.imageURL = urlToAsset?.absoluteString ?? ""
                            self.hasMedia = true
                        }
                    }
                }
            }
            .onAppear {
                UITextView.appearance().backgroundColor = .clear
            }
        }
       
        
    }
}

