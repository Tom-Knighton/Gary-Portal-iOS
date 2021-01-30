//
//  ZeroPage.swift
//  GaryPortal
//
//  Created by Tom Knighton on 13/01/2021.
//

import SwiftUI
import Combine

struct ZeroPage: View {
        
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("BackgroundGradient")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5, anchor: .center)
                    
                
                

            }
            .edgesIgnoringSafeArea(.all)
            
        }
        .edgesIgnoringSafeArea(.all)
       
    }
}
