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
        FeedService.getFeedDTOs(for: uuid, limit: 9) { (dtos) in
            DispatchQueue.main.async {
                self.postDTOs = dtos ?? []
            }
        }
    }
}

struct ProfilePostsView: View {
    
    @ObservedObject var datasource: ProfileViewDataSource
    
    var body: some View {
        VStack {
            Spacer().frame(width: 8)
            HStack {
                Spacer()
                Text("Recent Posts:")
                    .font(.custom("Montserrat-ExtraLight", size: 22))
                Spacer()
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(self.datasource.posts?.prefix(12) ?? [], id: \.self) { post in
                    NavigationLink(destination: NavigationLazyView(SingleFeedPost(postID: post.postId ?? -1))) {
                        if post.postType == "media" {
                            SmallMediaCard(url: post.postUrl ?? "", isVideo: post.isVideo ?? false)
                        } else if post.postType == "poll" {
                            SmallPollCard()
                        }
                    }
                }
            }
            if (self.datasource.posts?.count == 0) {
                Text("This user has no posts yet! :(")
                    .frame(maxWidth: .infinity)
                    .padding(8)
            }
            
            Spacer()
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
    @State var image: UIImage?
    
    var body: some View {
        
        if isVideo {
            Image(uiImage: image ?? UIImage(named: "BackgroundGradient")!)
                .opacity(image == nil ? 0 : 1)
                .frame(width: 100, height: 100)
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(15)
                .background(Color("Section").cornerRadius(15))
                .shadow(radius: 3)
                .overlay(
                    Image(systemName: "play.circle")
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color.primary)
                )
                .onAppear {
                    url.getThumbnailFromStringAsUrl { thumbnail in
                        self.image = thumbnail
                    }
                }
        } else {
            VStack {
                AsyncImage(url: url)
                    .scaledToFill()
                    .aspectRatio(1, contentMode: .fit)
                    .cornerRadius(15)
            }
            .frame(width: 100, height: 100)
            .cornerRadius(15)
            .shadow(radius: 3)
        }
    }
}

fileprivate struct SmallPollCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color("Section"))
            .overlay(
                Image("poll")
                    .renderingMode(.template)
                    .foregroundColor(Color.primary)
            )
            .frame(width: 100, height: 100)
            .cornerRadius(15)
            .shadow(radius: 3)
    }
}
