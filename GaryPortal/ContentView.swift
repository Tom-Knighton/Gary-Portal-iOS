//
//  ContentView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 13/01/2021.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @EnvironmentObject var garyportal: GaryPortal
    @State var selection = 1
        
    var body: some View {
        GeometryReader { geometry in
            GPNavigationController(view: AnyView(
                HostControllerRepresentable()
                    .edgesIgnoringSafeArea(.all)
            ))
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear {
                UIApplication.shared.addTapGestureRecognizer()
            }
        }
        .edgesIgnoringSafeArea(.all)
        
//        PlayerView(url: "https://cdn.tomk.online/GaryPortal/Chat/b2d3f505c61e46d6a66da9f062573773/Attachments/3aa7c7d6-a0cd-46b3-bd0d-51cfec4f921f.mp4", play: .constant(true))
//            .frame(maxWidth: 250, maxHeight: 400)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
