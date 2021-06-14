//
//  GPOptionsSheet.swift
//  GaryPortal
//
//  Created by Tom Knighton on 14/06/2021.
//

import Foundation
import SwiftUI

struct GPSheetOptionsView<Content>: View where Content: View {
    
    private let content: () -> Content
    init(_ content: @escaping () -> Content) {
        self.content = content
    }
    var body: some View {
        Group {
            self.content()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .foregroundColor(.primary)
    }
}

struct GPSheetOption: View {
    
    @State var imageName: String?
    @State var title: String
    @State var isDestructive: Bool
    
    var action: () -> ()
    
    init(imageName: String? = nil, title: String, isDestructive: Bool, action: @escaping () -> ()) {
        self.imageName = imageName
        self.title = title
        self.isDestructive = isDestructive
        self.action = action
    }
    
    var body: some View {
        Button(action: self.action) {
            HStack {
                if let imageName = self.imageName {
                    Image(systemName: imageName)
                        .resizable()
                        .frame(width: 30, height: 30)
                    Spacer().frame(width: 8)
                } else {
                    Spacer().frame(width: 38)
                }
                
                Text(self.title)
                    .font(.system(size: 18))
                    .bold()
                Spacer()
            }
            .frame(height: 50)
            .foregroundColor(self.isDestructive ? .red : .primary)
        }
    }
}
