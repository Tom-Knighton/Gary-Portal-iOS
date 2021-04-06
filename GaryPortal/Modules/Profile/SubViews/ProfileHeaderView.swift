//
//  ProfileHeaderView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 30/03/2021.
//

import SwiftUI

struct ProfileHeaderView: View {
    
    @ObservedObject var datasource: ProfileViewDataSource
    let websiteGradient = [Color(UIColor(hexString: "#FF416C")), Color(UIColor(hexString: "#FF4B2B"))]
    let privilegedGradient = [Color(UIColor(hexString: "#42275a")), Color(UIColor(hexString: "#734b6d"))]
    
    @State var isShowingStaff = false
    @State var edges = UIApplication.shared.windows.first?.safeAreaInsets
    @State var bioText: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Spacer().frame(width: 16)
                AsyncImage(url: self.datasource.user?.userProfileImageUrl ?? "")
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.white, lineWidth: 1)
                            .shadow(radius: 15)
                    )
                    .pinchToZoom()
                    .frame(width: 100, height: 100)
                    .shadow(radius: 5)
                Spacer().frame(width: 16)
                VStack {
                    Text(self.datasource.user?.userFullName ?? "Full Name")
                        .font(Font.custom("Montserrat-SemiBold", size: 25))
                        .frame(maxWidth: .infinity)
                    Spacer().frame(height: 16)
                    Text(self.datasource.user?.userSpanishName ?? "Spanish Name")
                        .font(Font.custom("Montserrat-Light", size: 20))
                        .frame(maxWidth: .infinity)
                    Spacer().frame(height: 8)
                    Text("@\(self.datasource.user?.userName ?? "Username")")
                        .font(Font.custom("Montserrat-Light", size: 15))
                        .frame(maxWidth: .infinity)
                    Spacer().frame(height: 8)
                }
                Spacer()
                Spacer().frame(width: 16)
            }
            Spacer().frame(height: 8)
            
            if self.datasource.user?.userUUID == GaryPortal.shared.currentUser?.userUUID {
                MultilineTextField("Your status here...", text: $bioText, limit: 120, onCommit: {
                        UserService.updateUserBio(to: self.bioText)
                    })
                .frame(maxHeight: 150)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
            } else {
                Text(bioText)
                    .font(.custom("Montserrat-Light", size: 16))
                    .frame(maxWidth: .infinity, maxHeight: 150)
                    .padding()
            }
           
                

            Spacer().frame(height: 8)
            if GaryPortal.shared.currentUser?.userUUID == datasource.user?.userUUID {
                if GaryPortal.shared.currentUser?.userIsAdmin == true || GaryPortal.shared.currentUser?.userIsStaff == true {
                    GPGradientButton(action: { self.datasource.activeSheet = .staff }, buttonText: "Staff Panel", gradientColours: privilegedGradient)
                } else {
                    GPGradientButton(action: { self.datasource.activeSheet = .website }, buttonText: "Visit Website", gradientColours: websiteGradient)
                }
            }
            Spacer().frame(height: 16)
        }
        .padding(.top, (edges?.top ?? 0) > 20 ? (edges?.top) : 0)
        .frame(maxWidth: .infinity)
        .background(Color("Section"))
        .cornerRadius(radius: 20, corners: [.bottomLeft, .bottomRight])
        .edgesIgnoringSafeArea(.top)
        .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 10)
        .onChange(of: self.datasource.user?.userBio, perform: { value in
            self.bioText = value ?? "fail"
        })
    }
}
