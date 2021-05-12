//
//  ChatMessageBar.swift
//  GaryPortal
//
//  Created by Tom Knighton on 09/05/2021.
//

import SwiftUI

struct ChatMessageBar: View {
    
    @State var text: String = ""
    @State var edges = UIApplication.shared.windows.first?.safeAreaInsets

    var body: some View {
        HStack {
            Spacer().frame(width: 16)
            HStack {
                TextEditor(text: $text)
                    .frame(minHeight: 40, maxHeight: 100)
                    .fixedSize(horizontal: false, vertical: true)
                    .background(
                        ZStack {
                            if text.isEmpty {
                                Text("Type something...")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 4)
                                    .foregroundColor(.gray)
                                    .allowsHitTesting(false)
                            }
                        }
                    )
                    .cornerRadius(5)
                Image(systemName: "trash")
            }
            .padding(6)
            .background(Color.clear)
            .cornerRadius(15)
            Spacer()
            
            if !self.text.isEmptyOrWhitespace() {
                Image(systemName: "paperplane.fill")
                    .padding()
                    .transition(.move(edge: .trailing))
                    .animation(.easeInOut)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 55)
        .padding(.vertical, 8)
        .background(Color("Section"))
        .cornerRadius(radius: 10, corners: [.topLeft, .topRight])
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -6)
        .onAppear {
            UITextView.appearance().backgroundColor = .clear
        }
    }
}

struct ChatMessageBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            ChatMessageBar()
        }
        .preferredColorScheme(.dark)
    }
}
