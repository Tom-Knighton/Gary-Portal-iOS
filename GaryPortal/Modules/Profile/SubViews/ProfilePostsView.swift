//
//  ProfilePostsView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 01/04/2021.
//

import SwiftUI

class ProfilePostsData: ObservableObject {
    @Published var postDTOs: [FeedPostDTO] = []
    
    func load(for uuid: String) {
        FeedService.getFeedDTOs(for: uuid) { (dtos) in
            DispatchQueue.main.async {
                self.postDTOs = dtos ?? []
            }
        }
    }
}

struct ProfilePostsView: View {
    
    @ObservedObject var datasource: ProfileViewDataSource
    @ObservedObject var data = ProfilePostsData()
    
    let gridItems = [
        GridItem(),
        GridItem(),
        GridItem(),
    ]
    
    init(datasource: ProfileViewDataSource) {
        self.datasource = datasource
        self.data = ProfilePostsData()
        self.data.load(for: self.datasource.user?.userUUID ?? "")
    }
    
    var body: some View {
        VStack {
            Spacer().frame(width: 8)
            HStack {
                Spacer()
                Text("Posts:")
                    .font(.custom("Montserrat-ExtraLight", size: 22))
                Spacer()
            }
            
            LazyVGrid(columns: gridItems, alignment: .center, spacing: 8) {
                ForEach(self.data.postDTOs, id: \.self) { post in
                    NavigationLink(destination: NavigationLazyView(SingleFeedPost(postID: post.postId ?? -1))) {
                        if post.postType == "media" {
                            SmallMediaCard(url: post.postUrl ?? "", isVideo: post.isVideo ?? false)
                        } else if post.postType == "poll" {
                            SmallPollCard()
                                .frame(width: 100, height: 100)
                                .shadow(radius: 3)
                        }
                    }
                }
            }
            
            
            Spacer().frame(width: 16)
        }
        .onAppear {
            self.data.load(for: datasource.user?.userUUID ?? "")
        }
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(radius: 15)
    }
}

fileprivate struct SmallMediaCard: View {
    
    @State var url: String
    @State var isVideo: Bool
    var body: some View {
        
        if isVideo {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color("Section"))
                .frame(width: 100, height: 100)
                .shadow(radius: 3)
                .overlay(
                    Image(systemName: "play.circle")
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color.primary)
                )
        } else {
            VStack {
                AsyncImage(url: url)
                    .scaledToFill()
                    .aspectRatio(1, contentMode: .fit)
            }
            .frame(width: 100, height: 100)
            .cornerRadius(15)
            .shadow(radius: 3)
        }
    }
}

fileprivate struct SmallPollCard: View {
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color("Section"))
                .overlay(
                    Image("poll")
                        .renderingMode(.template)
                        .foregroundColor(Color.primary)
                )
                .shadow(radius: 3)
        }
        .frame(width: 100, height: 100)
        .cornerRadius(15)
        .shadow(radius: 3)
       
    }
}
