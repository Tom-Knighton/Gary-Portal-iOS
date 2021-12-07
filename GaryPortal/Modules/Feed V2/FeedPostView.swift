//
//  FeedPostView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 06/09/2021.
//

import SwiftUI
import AVKit

fileprivate struct FeedPostHeaderView: View {
    
    var headerData: FeedPostDataSource.PostHeaderData?
    @Binding var isVideoPlaying: Bool
    @Binding var isVideoAudioMuted: Bool

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                AsyncImage(url: headerData?.userPhotoUrl ?? "")
                    .frame(width: 35, height: 35)
                    .clipShape(Circle())
                    .shadow(radius: 5)
                Text(headerData?.userName ?? "")
                    .bold()
                
                if headerData?.isVideoPost == true {
                    HStack {
                        Spacer()
                        Button(action: { self.isVideoPlaying.toggle() }) {
                            Image(systemName: self.isVideoPlaying ? "play.circle" : "pause.circle")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: { self.isVideoAudioMuted.toggle() }) {
                            Image(systemName: self.isVideoAudioMuted ? "speaker.slash.circle" : "speaker.wave.2.circle")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        .buttonStyle(PlainButtonStyle())

                        Spacer().frame(width: 8)
                    }
                } else {
                    Spacer().frame(width: 64)
                }
                
                Button(action: { }) {
                    Image(systemName: "ellipsis.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(8)
            .background(Blur(style: .systemUltraThinMaterial).opacity(0.8))
            .cornerRadius(20)
            .padding(12)
            Spacer()
            
        }
    }
}

fileprivate struct FeedPostBottomView: View {
    
    var bottomData: FeedPostDataSource.PostBottomData?
    
    @State var isBigDescriptionToggled = false

    var body: some View {
        VStack {
            if let description = bottomData?.postDescription {
                    ScrollView(isBigDescriptionToggled ? .vertical : []) {
                        Text(description)
                            .font(.system(size: 14))
                            .frame(alignment: .center)
                            .if(!isBigDescriptionToggled, transform: { view in
                                view.frame(idealHeight: 30, maxHeight: 75)
                            })
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(minHeight: 30, idealHeight: 45, maxHeight: self.isBigDescriptionToggled ? 150 : 80)
                    .if(!isBigDescriptionToggled) {
                        $0.fixedSize(horizontal: false, vertical: true)
                    }
            }
            
            HStack(spacing: 0) {
                Spacer().frame(width: 64)
                HStack(spacing: 4) {
                    Text(Image(systemName: "heart.fill"))
                        .foregroundColor(.red) +
                    Text("\(bottomData?.comments ?? 0)")
                    
                }
                Spacer().frame(width: 32)
                HStack(spacing: 4) {
                    Text(Image(systemName: "bubble.middle.bottom")) +
                    Text("\(bottomData?.comments ?? 0)")
                }
                Spacer().frame(width: 64)
            }
            .font(.system(size: 19))
        }
        .animation(.easeInOut(duration: 0.35))
        .padding(8)
        .background(Blur(style: .systemUltraThinMaterial).opacity(0.8))
        .cornerRadius(20)
        .padding(12)
        .onTapGesture {
            guard let description = bottomData?.postDescription,
                  description.count >= 100 else { return }
            self.isBigDescriptionToggled.toggle()
        }
    }
}

fileprivate struct FeedPostContentView: View {
    
    var contentData: FeedPostDataSource.PostContentData?
    @Binding var isVideoPlaying: Bool
    @Binding var isVideoAudioMuted: Bool
    @State private var hasAppeared = false
    
    @State private var hasLoaded = false
    
    init(contentData: FeedPostDataSource.PostContentData?, isVideoPlaying: Binding<Bool>, isVideoAudioMuted: Binding<Bool>) {
        self.contentData = contentData
        self._isVideoPlaying = isVideoPlaying
        self._isVideoAudioMuted = isVideoAudioMuted
        
        if (contentData?.isVideo == true) {
            print("INIT CALLED! \(hasLoaded)")
        }
        self.hasLoaded = true
    }
    
    var body: some View {
        if contentData?.postType == "media" {
            if contentData?.isVideo == true, let url = URL(string: contentData?.postUrl ?? "") {
                let player = AVQueuePlayer(url: url)
                PlayerView(player: player, url: url.absoluteString, play: $isVideoPlaying, isMuted: $isVideoAudioMuted)
                    .aspectRatio(contentMode: .fill)
                    .cornerRadius(15)
                    .frame(maxWidth: .infinity)
                    .shadow(radius: 3)
                    .background(Color("Section"))
                    .onAppear {
                        print("appear :(")
                        self.isVideoAudioMuted = false
                        self.isVideoPlaying = true
                        // For some reason the init for this struct isb eing called multiple times (WHEN THE LIST IS CHANGED)
                        // Need to test if this was fixed in SUI3
                        // Log out dev 7
                    }
                    .onDisappear {
                        self.isVideoAudioMuted = true
                        self.isVideoPlaying = false
                        print("dissapear :(")
                    }
                    .onTapGesture {
                        self.isVideoAudioMuted.toggle()
                    }
                    .id(UUID())
            } else {
                AsyncImage(url: contentData?.postUrl ?? "")
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(15)
                    .pinchToZoom()
                    .frame(maxWidth: .infinity)
                    .shadow(radius: 3)
            }
        }
    }
}

struct FeedPostView: View {
    
    @ObservedObject public var postData: FeedPostDataSource
    @State private var showOverlay = true
    @State private var isVideoPlaying = false
    @State private var isVideoAudioMuted = true
    
    var body: some View {
        let topData = postData.getHeaderData()
        let contentData = postData.getContentData()
        let bottomData = postData.getBottomData()
        // Is this better than having the data sent everywhree?
        if contentData?.isVideo == true {
            VStack {
                FeedPostHeaderView(headerData: topData, isVideoPlaying: $isVideoPlaying, isVideoAudioMuted: $isVideoAudioMuted)
                FeedPostContentView(contentData: contentData, isVideoPlaying: $isVideoPlaying, isVideoAudioMuted: $isVideoAudioMuted)
                    .id(UUID())
                FeedPostBottomView(bottomData: bottomData)
            }
            .background(Color("Section"))
            .cornerRadius(15)
            .shadow(radius: 3)
            .padding()
            .listRowBackground(Color.clear)
            .id(UUID())
        } else {
            FeedPostContentView(contentData: postData.getContentData(), isVideoPlaying: .constant(false), isVideoAudioMuted: .constant(false))
                .overlay(
                    VStack {
                        FeedPostHeaderView(headerData: postData.getHeaderData(), isVideoPlaying: .constant(false), isVideoAudioMuted: .constant(false))
                        Spacer()
                        FeedPostBottomView(bottomData: postData.getBottomData())
                    }
                    .padding(.vertical, 6)
                    .opacity(showOverlay ? 1 : 0.2)
                    .animation(.easeInOut(duration: 0.45))
                )
                .cornerRadius(15)
                .shadow(radius: 3)
                .padding()
                .listRowBackground(Color.clear)
                .onTapGesture {
                    self.showOverlay.toggle()
                }
        }
        
        
    }
}

