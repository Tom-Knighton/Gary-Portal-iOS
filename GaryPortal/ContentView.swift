//
//  ContentView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 13/01/2021.
//

import SwiftUI
import AVKit
import Photos

struct ContentView: View {
    
    @ObservedObject var garyPortal = GaryPortal.shared
    
    var body: some View {
       
        ZStack {
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
                NavigationView {
                    GPTabBar()
                        .navigationTitle("")
                        .navigationBarTitleDisplayMode(.automatic)
                        .navigationBarHidden(true)
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .edgesIgnoringSafeArea(.all)
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
}

struct GPTabBar: View {
    
    @ObservedObject var garyPortal = GaryPortal.shared
    @State var selectedTab = 1
    @State var tabIcons = ["note", "person", "bubble.left"]
    @State var tabNames = [0, 1, 2]
    @State var edge = UIApplication.shared.windows.first?.safeAreaInsets
    
    @AppStorage("feedBadgeCount", store: UserDefaults(suiteName: GaryPortalConstants.UserDefaults.suiteName)) var feedBadge: Int?
    @AppStorage("chatBadgeCount", store: UserDefaults(suiteName: GaryPortalConstants.UserDefaults.suiteName)) var chatBadge: Int?
    @AppStorage("profileBadgeCount", store: UserDefaults(suiteName: GaryPortalConstants.UserDefaults.suiteName)) var profileBadge: Int?
    
    var body: some View {
        
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            
            HostControllerRepresentable(selectedIndex: $selectedTab)
                .edgesIgnoringSafeArea(.all)
            
            Spacer()

            HStack {
                ForEach(0..<3) { index in
                    Button(action: { self.selectedTab = self.tabNames[index] }, label: {
                        Spacer()
                        Image(systemName: self.tabIcons[index])
                            .font(.system(size: 24, weight: self.selectedTab == index ? .bold : .regular))
                            .foregroundColor(Color(.label))
                            .if(index == 0) {
                                $0.badge(count: feedBadge ?? 0)
                            }
                            .if(index == 1) {
                                $0.badge(count: profileBadge ?? 0)
                            }
                            .if(index == 2) {
                                $0.badge(count: chatBadge ?? 0)
                            }
                        Spacer()
                    })
                }
            }
            .frame(height: 25)
            .padding(.horizontal, 25)
            .padding(.vertical, 15)
            .background(Color("Section"))
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.15), radius: 5, x: 5, y: 5)
            .shadow(color: Color.black.opacity(0.15), radius: 5, x: -5, y: -5)
            .padding(.horizontal)
            .padding(.bottom, edge?.bottom == 0 ? 20 : 10)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

struct ContentPreview: PreviewProvider {
    
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 12 Pro Max")
            .preferredColorScheme(.dark)
    }
}
