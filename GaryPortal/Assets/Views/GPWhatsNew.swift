//
//  GPWhatsNew.swift
//  GaryPortal
//
//  Created by Tom Knighton on 26/02/2021.
//

import SwiftUI

struct GPWhatsNew: View {
    
    @Environment(\.presentationMode) var presentationMode
    var updateInfo400: [GPWhatsNewEntry] = [
        GPWhatsNewEntry(imageName: "mustache", title: "All New!", description: "The entire app has been completely rebuilt, from the ground up. It's is now good!"),
        GPWhatsNewEntry(imageName: "moon.circle", title: "After Dark :)", description: "The app (after two years 👀) supports dark mode! Rest your eyes after a hard day on Gary Portal"),
        GPWhatsNewEntry(imageName: "newspaper", title: "Updated Feed!", description: "After a lot of manual labour, the feed has been smushed together, now all the posts, polls and aDit LoGs appear all in the same place!"),
        GPWhatsNewEntry(imageName: "camera", title: "Wow! Camera!", description: "Snap, marvel at the new camera that appears throughout the app, including when posting aDit LoGs and feed posts! Snap your pics and videos, then draw on them! Gary is your canvas"),
        GPWhatsNewEntry(imageName: "text.bubble", title: "Chit Chat", description: "If you do want to talk to your friends, message them right here! The chat has been updated to, get this, no longer crash when people start typing! You can also use some fancy style messages, maybe '?help' will send you on your journey 🥸"),
        GPWhatsNewEntry(imageName: "hand.thumbsdown", title: "You Go Queen", description: "You can now block users, and happily ignore their posts, aDit LoGs, and messages! Of course, if you are feeling benevolent, you can then unblock them at any time. You can also choose to report users, posts and messages"),
        GPWhatsNewEntry(imageName: "envelope.badge", title: "Red Alert!", description: "Notifications! Notifications for chat messages, notifications for feed comments, notifications! Also, (you can) disable notifications!"),
        GPWhatsNewEntry(imageName: "bolt", title: "Power", description: "Staff members and admins can now manage users right inside the app! Fear Them, Love Them."),
        GPWhatsNewEntry(imageName: "ant.circle", title: "Fixes!", description: "Multiple bugs have been fixed, including UI issues, videos in chats, issues in the points room, crashing when logging out, and many more! Some new bugs were also added for fun."),
        GPWhatsNewEntry(imageName: "ear", title: "Whats's that?", description: "Who's all new UI is that? I think I know.\nIt's owner is quite happy though.\nFull of joy like a vivid rainbow,\nI cry hello. (fin)\nThe app uses an all new design language to properly fit on every device, as well as that, many improvements have been made to battery life, memory management and data usage! And we are also banned for poetry"),
        GPWhatsNewEntry(imageName: "figure.wave", title: "More!", description: "There's a lot more included in this updated, too much to fit here. Have fun!"),
    ]
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Group {
                    Spacer()
                    Text("What's new in Gary Portal 4.0.0")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    Spacer().frame(height: 16)
                }
                
                Group {
                    ScrollView {
                        LazyVStack {
                            ForEach(self.updateInfo400, id: \.self) { item in
                                GPWhatsNewItem(data: item)
                            }
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                         self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Continue")
                        .foregroundColor(.white)
                        .bold()
                        .padding()
                        .frame(width: UIScreen.main.bounds.width - 64)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                Spacer().frame(height: 32)
            }
            .edgesIgnoringSafeArea(.all)
            .background(Color("Section"))
        }
        .edgesIgnoringSafeArea(.all)
        .onDisappear {
            DispatchQueue.main.async {
                UserDefaults.standard.set(true, forKey: GaryPortalConstants.hasSeenWhatsNew)
                UserDefaults.standard.synchronize()
                print(UserDefaults.standard.bool(forKey: GaryPortalConstants.hasSeenWhatsNew))
            }
        }
        
    }
    
}

struct GPWhatsNewEntry: Hashable {
    let imageName: String
    let title: String
    let description: String
    
    var id: String { return UUID().uuidString }
}

struct GPWhatsNewItem: View {
    
    var data: GPWhatsNewEntry
    
    var body: some View {
        HStack {
            Image(systemName: data.imageName)
                .font(.largeTitle)
                .foregroundColor(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(data.title)
                        .bold()
                    Spacer()
                }
                HStack {
                    Text(data.description)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
            }
            .frame(width: 250)
            .padding()
        }
    }
}

struct GPWhatsNew_Previews: PreviewProvider {
    static var previews: some View {
        GPWhatsNew()
            .preferredColorScheme(.dark)
    }
}
