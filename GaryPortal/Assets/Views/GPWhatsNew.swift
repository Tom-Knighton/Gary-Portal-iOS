//
//  GPWhatsNew.swift
//  GaryPortal
//
//  Created by Tom Knighton on 26/02/2021.
//

import SwiftUI

struct GPWhatsNew: View {
    
    @Environment(\.presentationMode) var presentationMode
    var updateInfo4_1: [GPWhatsNewEntry] = [
        GPWhatsNewEntry(imageName: "hands.sparkles", title: "4.1 - The Update's update", description: "Many things! 4.1 includes multiple new things and some fixes, there's sure to be something here for you, if not, feel free to file a complaint"),
        GPWhatsNewEntry(imageName: "globe", title: "Circumnavigation", description: "A new way to navigate! Sail the seas of Gary Portal with the new tab bar, it floats right there at the bottom of the screen and you can tap the cute little buttons to go to the cute little pages. Of course, you can also swipe between pages just like before."),
        GPWhatsNewEntry(imageName: "bell.badge", title: "Premium Notifications", description: "In the before times, there were notifications. Now, you can actually see them! The app icon will now display the number of notifications, and you can see all chat notifications on the chat tab bar, and feed notifications on the feed tab bar icon. Notifications will clear when you head to the relevant page, or clear them manually from settings."),
        GPWhatsNewEntry(imageName: "scribble.variable", title: "An update's best friend", description: "Gary Portal 4.1 has added MUCH to the Gary Media Editor. In addition to being able to draw on images and videos, you can now add text labels and stickers!"),
        GPWhatsNewEntry(imageName: "mustache", title: "Text labels and stickers!", description: "Wow, text labels and stickers. You can add as many of these as you want, and resize them, move them around, rotate them, delete them. It's your world. You can also send stickers to chats, look for the moustache button to begin your journey."),
        GPWhatsNewEntry(imageName: "mustache", title: "Cache Money", description: "Some of you have bad WiFi, and blame Gary Portal for that, so now Gary Portal caches images so they display instantly if you've already loaded them before :). You can clear your cache in settings"),
        GPWhatsNewEntry(imageName: "exclamationmark.bubble", title: "Does anyone read these", description: "Gary portal now included Crashylitics, any crashes are reported to Gary with no user data, so issues are more easily spotted and fixed"),
        GPWhatsNewEntry(imageName: "ant.circle", title: "Fixes and more!", description: "A number of issues have been fixed in this update, including a memory leak, a crash and a sound that refused to play. See if you can spot them all. In addition, the app no longer crashed when you go to change your profile picture. On a completely unrelated note, the process to change your profile picture has changed! You can now use the Gary Camera to select a new photo, including ones from your library, and add text, stickers, and drawings to them"),
        
    ]
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Group {
                    Spacer()
                    Text("What's new in Gary Portal 4.1")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    Spacer().frame(height: 16)
                }
                
                Group {
                    ScrollView {
                        LazyVStack {
                            ForEach(self.updateInfo4_1, id: \.self) { item in
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
