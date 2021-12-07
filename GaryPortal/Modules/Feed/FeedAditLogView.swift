//
//  FeedAditLogView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 16/02/2021.
//

import Foundation
import SwiftUI

struct FeedAditLogView: View {
    
    var aditLogs: AditLogGroup
    @State var currentAditLog: Int = 0
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            let current = self.aditLogs.aditLogs?[currentAditLog]
            GeometryReader { geometry in
                
                if current?.isVideo == true {
//                    PlayerView(url: current?.aditLogUrl ?? "", play: .constant(true), gravity: .fill)
//                        .frame(width: geometry.size.width, height: geometry.size.height)
//                        .aspectRatio(contentMode: .fill)
                } else {
                    AsyncImage(url: current?.aditLogUrl ?? "")
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .aspectRatio(contentMode: .fill)
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            if (self.aditLogs.aditLogs?.count ?? 0) > 1 {
                overlay
            }
            
            gestures
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { self.closeView() }, label: {
                        HStack {
                            Text("Close")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(Color.primary.opacity(0.7))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color("Section").opacity(0.6))
                        .clipShape(Capsule())
                    })
                    .padding()
                    Spacer().frame(width: 16)
                }
            }
            
        }
        .onAppear {
            NotificationCenter.default.post(name: .movedFromFeed, object: nil)
            FeedService.watchAditLog(aditLogs.aditLogs?.first?.aditLogId ?? 0, uuid: GaryPortal.shared.currentUser?.userUUID ?? "")
        }
    }
        
    @ViewBuilder
    var overlay: some View {
        let current = self.aditLogs.aditLogs?[currentAditLog]
        VStack {
            HStack(alignment: .top) {
                if let aditLogs = aditLogs.aditLogs {
                    ForEach(aditLogs.indices) { i in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .foregroundColor(Color.white.opacity(i <= self.currentAditLog ? 0.9 : 0.3))
                                .cornerRadius(5)
                        }
                        .frame(height: 2)
                        .animation(.linear)
                    }
                }
            }
            
            Spacer().frame(height: 8)
            Text(current?.getName() ?? "")
                .font(.custom("Montserrat-SemiBold", size: 15))
                .shadow(radius: 3)
            Text(current?.getNiceTime() ?? "")
                .font(.custom("Montserrat-SemiBold", size: 13))
                .shadow(radius: 3)
            Spacer()
        }
        .padding()
        
    
    }
    
    @ViewBuilder
    var gestures: some View {
        HStack(alignment: .center, spacing: 0) {
            Rectangle()
                .foregroundColor(.clear)
                .contentShape(Rectangle())
                .onTapGesture {
                    self.changeAditLog(by: -1)
                }
            Rectangle()
                .foregroundColor(.clear)
                .contentShape(Rectangle())
                .onTapGesture {
                    self.changeAditLog(by: 1)
                }
        }
    }
    
    func changeAditLog(by: Int) {
        let newIndex = self.currentAditLog + by
        guard newIndex < self.aditLogs.aditLogs?.count ?? 0, newIndex >= 0 else {
            self.closeView()
            return
        }
        
        self.currentAditLog = newIndex
        FeedService.watchAditLog(aditLogs.aditLogs?[newIndex].aditLogId ?? 0, uuid: GaryPortal.shared.currentUser?.userUUID ?? "")
    }
    
    func closeView() {
        self.presentationMode.wrappedValue.dismiss()
    }
}
