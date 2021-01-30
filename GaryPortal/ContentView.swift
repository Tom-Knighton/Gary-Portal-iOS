//
//  ContentView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 13/01/2021.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var garyportal: GaryPortal
    @State private var selection = 1
    
    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $selection) {
                FeedView().environmentObject(garyportal)
                    .tag(0)
                ProfileView().environmentObject(garyportal)
                    .tag(1)
                ProfileView().environmentObject(garyportal)
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
        }
        .edgesIgnoringSafeArea(.all)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
