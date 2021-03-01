//
//  ContentView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 13/01/2021.
//

import SwiftUI
import AVKit

struct ContentView: View {
    
    @ObservedObject var garyPortal = GaryPortal.shared
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                if self.garyPortal.currentUser?.getFirstBanOfType(banTypeId: 1) != nil {
                    ZStack {
                        Color.black.cornerRadius(10).edgesIgnoringSafeArea(.all)
                        Text("You have been temporarily banned from Gary Portal, please wait until your ban expires to access the app again")
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                            .edgesIgnoringSafeArea(.all)
                    }
                } else if self.garyPortal.currentUser?.isQueued == true {
                    ZStack {
                        GradientBackground().edgesIgnoringSafeArea(.all)
                        Text("You are still in the queue, your account will be created by an admin shortly, hang in there!")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                            .edgesIgnoringSafeArea(.all)
                    }
                } else {
                    GPNavigationController(view: AnyView(
                        HostControllerRepresentable()
                            .edgesIgnoringSafeArea(.all)
                    ))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .onAppear {
                        UIApplication.shared.addTapGestureRecognizer()
                    }
                    .sheet(item: $garyPortal.notificationSheetDisplayMode) { item in
                        if item == .chat, let chat = garyPortal.viewingNotificationChat {
                            ChatView(chat: chat)
                        } else if item == .feedComments, let post = garyPortal.viewingNotificationPost {
                            CommentsView(post: .constant(post))
                        } else if item == .whatsNew {
                            GPWhatsNew()
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            if self.garyPortal.showNotification,
               let data = self.garyPortal.currentNotificationData {
                let isChatAndOnChat = data.isChat && (self.garyPortal.currentPageIndex == 2 || self.garyPortal.notificationSheetDisplayMode == .chat)
                let isFeedAndInComments = data.isFeed && self.garyPortal.notificationSheetDisplayMode == .feedComments
                
                if !isChatAndOnChat && !isFeedAndInComments {
                    GPNotification(data: data)
                        .transition(.move(edge: .top))
                }
            }
        }
    }
}
