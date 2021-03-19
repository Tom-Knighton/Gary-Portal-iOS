//
//  ContentView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 13/01/2021.
//

import SwiftUI
import AVKit

struct ContentView: View {
    
    var body: some View {
        GPNavigationController {
            GPTabBar()
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.automatic)
                .navigationBarHidden(true)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct GPTabBar: View {
    
    @ObservedObject var garyPortal = GaryPortal.shared
    @State var selectedTab = 1
    @State var tabIcons = ["note", "person", "bubble.left"]
    @State var tabNames = [0, 1, 2]
    @State var edge = UIApplication.shared.windows.first?.safeAreaInsets
    
    var body: some View {
        
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            
            HostControllerRepresentable(selectedIndex: $selectedTab)
                .edgesIgnoringSafeArea(.all)
            
//            Spacer()
//
//            HStack {
//                ForEach(0..<3) { index in
//                    Button(action: { self.selectedTab = self.tabNames[index] }, label: {
//                        Spacer()
//                        Image(systemName: self.tabIcons[index])
//                            .font(.system(size: 24, weight: self.selectedTab == index ? .bold : .regular))
//                            .foregroundColor(Color(.label))
//                        Spacer()
//                    })
//                }
//            }
//            .frame(height: 25)
//            .padding(.horizontal, 25)
//            .padding(.vertical, 15)
//            .background(Color("Section"))
//            .clipShape(Capsule())
//            .shadow(color: Color.black.opacity(0.15), radius: 5, x: 5, y: 5)
//            .shadow(color: Color.black.opacity(0.15), radius: 5, x: -5, y: -5)
//            .padding(.horizontal)
//            .padding(.bottom, edge?.bottom == 0 ? 20 : 10)
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
