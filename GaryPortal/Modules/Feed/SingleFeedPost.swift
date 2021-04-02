//
//  SingleFeedPost.swift
//  GaryPortal
//
//  Created by Tom Knighton on 01/04/2021.
//

import SwiftUI

class SingleFeedPostDataSource: ObservableObject {
    @Published var post: FeedPost?
    @Published var pollModel: PollPostViewModel?
    
    func load(postId: Int) {
        FeedService.getPost(by: postId) { (post, error) in
            if let post = post {
                DispatchQueue.main.async {
                    self.post = post
                    if let post = post as? FeedPollPost {
                        self.pollModel = PollPostViewModel(post: post)
                    }
                }
            }
        }
    }
}

struct SingleFeedPost: View {
    
    @ObservedObject var datasource = SingleFeedPostDataSource()
    @State var postId: Int = -1
    @State var isPlaying = false
    
    init(postID: Int) {
        self.postId = postID
        self.datasource.load(postId: postID)
    }
    
    var body: some View {
        if let post = self.datasource.post {
            VStack {
                Spacer().frame(height: 8)
                PostHeaderView(post: post)
                
                if let post = post as? FeedMediaPost {
                    if post.isVideo == true {
                        PlayerView(url: post.postUrl ?? "", play: $isPlaying, gravity: .fit)
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, minHeight: 50, maxHeight: .infinity)
                            .cornerRadius(15)
                            .padding(8)
                            .shadow(radius: 3)
                            .onTapGesture {
                                self.isPlaying = !self.isPlaying
                            }
                            .onAppear {
                                self.isPlaying = false
                            }
                            .overlay(
                                VStack {
                                    if !self.isPlaying {
                                        HStack {
                                            Text(Image(systemName: "play.circle")) + Text("  Paused")
                                        }
                                        .foregroundColor(.white)
                                        .padding(.all, 8)
                                        .background(Color.black.opacity(0.4))
                                        .cornerRadius(10)
                                        .shadow(radius: 3)
                                    }
                                }
                            )
                            .onDisappear {
                                self.isPlaying = false
                            }
                    } else {
                        AsyncImage(url: post.postUrl ?? "")
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(15)
                            .pinchToZoom()
                            .frame(maxWidth: .infinity, maxHeight: 350)
                            .padding(8)
                            .shadow(radius: 3)
                    }
                } else if let _ = post as? FeedPollPost {
                    if let pollModel = self.datasource.pollModel, let post = self.datasource.pollModel?.post {
                        HStack {
                            Text(post.pollQuestion ?? "")
                                .font(.custom("Montserrat-SemiBold", size: 19))
                                .padding()
                            Spacer()
                        }
                        
                        LazyVStack {
                            ForEach(post.pollAnswers ?? [], id: \.pollAnswerId) { answer in
                                PollPostVoteButton(pollModel: pollModel, pollAnswer: answer)
                            }
                        }
                    }
                }
                PostActionView(post: post)
                Spacer()
            }
        }
    }
}
