//
//  SingleFeedPost.swift
//  GaryPortal
//
//  Created by Tom Knighton on 01/04/2021.
//

import SwiftUI

class SingleFeedPostDataSource: ObservableObject {
    @Published var post: FeedPost?
    
    func load(postId: Int) {
        FeedService.getPost(by: postId) { (post, error) in
            if let post = post {
                print("got post")
                DispatchQueue.main.async {
                    self.post = post
                    print(self.post?.postDescription)
                }
            }
        }
    }
}

struct SingleFeedPost: View {
    
    @ObservedObject var datasource = SingleFeedPostDataSource()
    @State var postId: Int = -1
    
    init(postID: Int) {
        self.postId = postID
        self.datasource.load(postId: postID)
    }
    
    var body: some View {
        VStack {
            Spacer().frame(height: 16)
            if self.datasource.post is FeedMediaPost {
                PostMediaView(post: self.datasource.post as! FeedMediaPost)
                    .padding(.all, 4)
                    .shadow(color: Color.black, radius: 15)
            } else if self.datasource.post is FeedPollPost {
                PostPollView(pollModel: PollPostViewModel(post: self.datasource.post as! FeedPollPost))
                    .padding(.all, 4)
                    .shadow(color: Color.black, radius: 15)
            }
            Spacer()
        }
        .padding()
    }
}
