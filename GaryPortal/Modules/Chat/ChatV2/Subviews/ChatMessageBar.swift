//
//  ChatMessageBar.swift
//  GaryPortal
//
//  Created by Tom Knighton on 09/05/2021.
//

import SwiftUI

struct ChatMessageBar: View {
    
    @EnvironmentObject var partialSheetManager: PartialSheetManager

    @State var text: String = ""
    @State var showStickerView = false
    @State var showCameraView = false
    @State var previousValueWasEmpty = true
    
    var onSend: (_ result: ChatMessageBarResult) -> ()
    
    init(_ result: @escaping (_ result: ChatMessageBarResult) -> ()) {
        self.onSend = result
    }

    var body: some View {
        VStack {
            HStack {
                Spacer().frame(width: 16)
                HStack {
                    TextEditor(text: $text)
                        .frame(minHeight: 40, maxHeight: 100)
                        .fixedSize(horizontal: false, vertical: true)
                        .background(
                            ZStack {
                                if text.isEmpty {
                                    Text("Type something...")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 4)
                                        .foregroundColor(.gray)
                                        .allowsHitTesting(false)
                                }
                            }
                        )
                        .cornerRadius(5)
                        .onTapGesture {
                            self.showStickerView = false
                        }
                        .onChange(of: self.text) { value in
                            if previousValueWasEmpty && !self.text.isEmptyOrWhitespace(){
                                self.previousValueWasEmpty = false
                                NotificationCenter.default.post(name: .textFieldStartedEditing, object: nil)
                            }
                            
                            else if self.text.isEmptyOrWhitespace() {
                                self.previousValueWasEmpty = true
                            }
                        }
                    
                    if self.text.isEmptyOrWhitespace() {
                        Button(action: { self.toggleStickerView() }) {
                            Image(systemName: "mustache.fill")
                                .padding(14)
                                .background(Circle().fill(Color("Section")).shadow(radius: 2))
                        }
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut)
                    }
                    
                    Button(action: { self.showCameraView.toggle() }) {
                        Image(systemName: "camera.on.rectangle.fill")
                            .padding(10)
                            .background(Circle().fill(Color("Section")).shadow(radius: 2))
                    }
                    .transition(.move(edge: .trailing))
                    .animation(.easeInOut)
                }
                .padding(6)
                .background(Color.clear)
                .cornerRadius(15)
                Spacer()
                
                if !self.text.isEmptyOrWhitespace() {
                    Button(action: { self.sendMessage() }) {
                        Image(systemName: "paperplane.fill")
                            .padding(10)
                            .background(Circle().fill(Color("Section")).shadow(radius: 2))
                    }
                    .transition(.move(edge: .trailing))
                    .animation(.easeInOut)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, minHeight: 55)
            .padding(.vertical, 8)
            .background(Color("Section"))
            .cornerRadius(radius: 10, corners: [.topLeft, .topRight])
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -6)
            .onAppear {
                UITextView.appearance().backgroundColor = .clear
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .shouldEndEditing)) { _ in
            self.toggleStickerView(override: false)
        }
        .fullScreenCover(isPresented: $showCameraView) {
            CameraView { success, isVideo, urlToAsset in
                self.showCameraView = false
                self.sendMessage(overrideText: urlToAsset?.absoluteString, isImageURL: !isVideo, isVideoURL: isVideo)
            }
        }
        .partialSheet(isPresented: $showStickerView) {
            StickersView { url in
                self.sendMessage(overrideText: url, isImageURL: false, isVideoURL: false, isStickerURL: true)
                withAnimation {
                    self.partialSheetManager.closePartialSheet()
                }
            }
            .frame(maxHeight: 500)
        }
    }
    
    func sendMessage(overrideText: String? = nil, isImageURL: Bool = false, isVideoURL: Bool = false, isStickerURL: Bool = false) {
        self.onSend(ChatMessageBarResult(isVideoURL: isVideoURL, isImageURL: isImageURL, isStickerURL: isStickerURL, rawText: overrideText ?? self.text))
        if (overrideText == nil) {
            self.text = ""
        }
    }
    
    func toggleStickerView(override: Bool? = nil) {
        if let override = override {
            self.showStickerView = override
        } else {
            self.showStickerView.toggle()
        }
        
        if self.showStickerView {
            UIApplication.shared.endEditing()
        }
    }
}
