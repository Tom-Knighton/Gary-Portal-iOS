//
//  FeedDataSource.swift
//  GaryPortal
//
//  Created by Tom Knighton on 13/09/2021.
//

import SwiftUI

class FeedPostListDataSource: ObservableObject {
    
    //MARK: Published
    @Published var feedPosts: [FeedPost] = []
    @Published var errorMessage: String?
    
    //MARK: Variables
    private var lastDateFetched = Date()
    private var canLoadMorePosts = true
    private var isLoadingPosts = false
    private let fetchLimit = 10
    
    private var teamId = GaryPortal.shared.currentUser?.HasUserFlag(flagName: "Role.Admin") == true ? 0 : (GaryPortal.shared.currentUser?.userTeam?.teamId ?? -1)
    
    // MARK: Functions
    /// Determines if any new posts are needed and calls loadNextPosts()
    func loadMorePostsIfNeeded(from postId: Int?) {
        guard let postId = postId,
              let index = self.feedPosts.firstIndex(where: { $0.postId == postId }),
              canLoadMorePosts,
              !isLoadingPosts
        else { return }
        
        let lastIndex = self.feedPosts.endIndex

        if lastIndex - index <= 2 {
            loadNextPosts()
        }
    }
    
    /// If posts are not already being fetched, fetches new posts and appends any new ones to the feedPosts list.
    ///
    /// Will only run if posts are not already being fetched.
    ///
    /// The method will set the errorMessage variable if an error occurs fetching any new posts.
    ///
    /// The method will tell the data source that no new posts can be fetched if the returned post count is not equal to the post limit asked for (default 10)
    ///
    func loadNextPosts() {
        self.isLoadingPosts = true
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            FeedService.getFeedPosts(startingFrom: self?.lastDateFetched, limit: self?.fetchLimit ?? 10, teamId: self?.teamId ?? -1) { [weak self] posts, error in
                guard let posts = posts else {
                    self?.errorMessage = "An error occurred fetching new feed posts :("
                    return
                }
                
                let newPostsToAppend = posts.filter({ newPostToAdd in
                    return self?.feedPosts.contains(where: { $0.postId == newPostToAdd.postId }) == false
                })
                self?.lastDateFetched = posts.last?.postCreatedAt ?? Date()
                self?.isLoadingPosts = false
                self?.canLoadMorePosts = posts.count == self?.fetchLimit
                
                DispatchQueue.main.async { [weak self] in
                    self?.feedPosts.append(contentsOf: newPostsToAppend)
                }
            }
        }
        
        
    }
}

public class FeedPostDataSource: ObservableObject {
    @Published var feedPost: FeedPost?
    
    init(with post: FeedPost) {
        self.feedPost = post
    }
    
    func getHeaderData() -> PostHeaderData? {
        guard let feedPost = self.feedPost,
              let posterUrl = feedPost.posterDTO?.userProfileImageUrl,
              let posterName = feedPost.posterDTO?.userFullName
        else { return nil }
        
        if let mediaPost = feedPost as? FeedMediaPost {
            return PostHeaderData(userPhotoUrl: posterUrl, userName: posterName, isVideoPost: mediaPost.isVideo == true)
        } else {
            return PostHeaderData(userPhotoUrl: posterUrl, userName: posterName, isVideoPost: false)
        }
    }
    
    func getContentData() -> PostContentData? {
        guard let feedPost = self.feedPost,
              let postType = feedPost.postType
        else { return nil }
        
        switch feedPost {
        case let post as FeedMediaPost:
            return PostContentData(postUrl: post.postUrl, postType: postType, postQuestion: nil, postAnswers: nil, isVideo: post.isVideo == true)
        case let post as FeedPollPost:
            return PostContentData(postUrl: nil, postType: postType, postQuestion: post.pollQuestion, postAnswers: post.pollAnswers, isVideo: false)
        default:
            return nil
        }
    }
    
    func getBottomData() -> PostBottomData? {
        guard let feedPost = self.feedPost,
              let likes = feedPost.likes,
              let comments = feedPost.comments
        else { return nil }
        
        if let mediaPost = feedPost as? FeedMediaPost {
            return PostBottomData(postDescription: feedPost.postDescription, likes: likes.count, comments: comments.count, isVideo: mediaPost.isVideo == true)
        } else {
            return PostBottomData(postDescription: feedPost.postDescription, likes: likes.count, comments: comments.count, isVideo: false)
        }
        
    }
    
    struct PostHeaderData {
        let userPhotoUrl: String
        let userName: String
        var isVideoPost: Bool
    }
    
    struct PostBottomData {
        let postDescription: String?
        let likes: Int
        let comments: Int
        let isVideo: Bool
    }
    
    struct PostContentData {
        let postUrl: String?
        let postType: String
        let postQuestion: String?
        let postAnswers: [FeedPollAnswer]?
        let isVideo: Bool
    }
}
