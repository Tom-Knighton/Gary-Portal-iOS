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
        GPWhatsNewEntry(imageName: "ant.circle", title: "Wow! Much bug fixed yay", description: "Thank you for all taking the time out of your day to report some bugs respectfully and peacefully 🥲. Some of your favourite bugs have been fixed in this version! Including:\n- Multiple Adit Log fixes\n- Announcements chat being poopy :(\n- Crashes when exiting chats\n- The back button being **too small* for your sausage fingers\nAnd more!"),
        GPWhatsNewEntry(imageName: "arrow.up.left.and.arrow.down.right", title: "Images!", description: "For this version of Gary Portal, Al Murray has invented images! That's right, and they're super fun too. Pinch to zoom on someone's (or your own) profile picture, or a feed image post or even an image in a chat! Or, be even more adventurous and hold down on an image in chat to view it in full screen"),
        GPWhatsNewEntry(imageName: "mustache", title: "Share with your friends", description: "You now have the  ability to hold down on images or videos in chat and select 'Download' to download or share the image or video, right from inside Gary Portal! - Your One Stop Gary")
    ]
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Group {
                    Spacer()
                    Text("What's new in Gary Portal 4.0.1")
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
