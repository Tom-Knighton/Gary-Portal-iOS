//
//  GPAvatarView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 05/05/2021.
//

import SwiftUI

struct GPAvatarView: View {
    @State var imageUrls: [String]
    
    var body: some View {
        let totalImages = self.imageUrls.count
        let size: CGFloat = totalImages == 1 ? 50 : totalImages == 2 ? 40 : 30
        HStack(alignment: .center, spacing: -15) {
            ForEach(imageUrls.indices) { i in
                let url = self.imageUrls[i]
                if i <= 2 {
                    AsyncImage(url: url)
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(lineWidth: 2).foregroundColor(Color("Section")))
                        .shadow(radius: 1)
                } else if i == self.imageUrls.count - 1 {
                    Circle()
                        .fill(Color("Section"))
                        .frame(width: size, height: size)
                        .overlay(Text("+\(self.imageUrls.count - 3)"))
                        .shadow(radius: 1)
                }
            }
        }
    }
}

