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
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct GPSwipeContainer<Content: View>: View {
    let titles: [String]?
    var images: [String]
    let content: Content
    
    @GestureState private var translation: CGFloat = 0
    @State var index: Int = 1
    
    init(titles: [String]?, images: [String], @ViewBuilder content: () -> Content) {
        self.titles = titles
        self.images = images
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack (spacing : 0) {
                self.content
                    .frame(width: geometry.size.width)
            }
            .frame(width: geometry.size.width, alignment: .leading)
            .offset(x: -CGFloat(self.index) * geometry.size.width)
            .animation(.interactiveSpring())
            .gesture(
                DragGesture()
                    .updating(self.$translation) { gestureValue, gestureState, _ in
                        gestureState = gestureValue.translation.width
                    }
                    .onEnded({ (value) in
                        var weakGesture : CGFloat = 0
                        if value.translation.width < 0 {
                            weakGesture = -100
                        } else {
                            weakGesture = 100
                        }
                        let offset = (value.translation.width + weakGesture) / geometry.size.width
                        let newIndex = (CGFloat(self.index) - offset).rounded()
                        self.index = min(max(Int(newIndex), 0), self.images.count - 1)
                    })
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
