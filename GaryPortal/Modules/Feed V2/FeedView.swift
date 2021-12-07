//
//  FeedView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 13/09/2021.
//

import SwiftUI

struct FeedView: View {
    
    @StateObject private var feedPostsDataSource = FeedPostListDataSource()
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").edgesIgnoringSafeArea(.all)
            List {
                ForEach(self.feedPostsDataSource.feedPosts, id: \.postId) { post in
                    FeedPostView(postData: FeedPostDataSource(with: post))
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .onAppear {
                            self.feedPostsDataSource.loadMorePostsIfNeeded(from: post.postId)
                        }
                }
                .listRowBackground(Color.clear)
            }
            .listStyle(PlainListStyle())
        }
        .onAppear {
            self.feedPostsDataSource.loadNextPosts()
        }
    }
}
