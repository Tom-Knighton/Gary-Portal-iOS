//
//  ContentView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 13/01/2021.
//

import SwiftUI

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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
