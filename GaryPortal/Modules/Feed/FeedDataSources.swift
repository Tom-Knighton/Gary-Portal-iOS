//
//  FeedDataSources.swift
//  GaryPortal
//
//  Created by Tom Knighton on 19/03/2021.
//

import Foundation

class FeedPostsDataSource: ObservableObject {
    @Published var posts = [FeedPost]()
    @Published var aditLogs = [AditLog]()
    @Published var aditLogGroups = [AditLogGroup]()
    @Published var isLoadingPage = false
    @Published var canLoadMore = true
    @Published var isFeedBanned = false
    private var isFirstLoad = true
    private var lastDateFrom = Date()
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(clearVotes(_:)), name: .postVotesCleared, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removePost(_:)), name: .postDeleted, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .postVotesCleared, object: nil)
        NotificationCenter.default.removeObserver(self, name: .postDeleted, object: nil)
    }
    
    func reset() {
        self.aditLogs = []
        self.posts = []
        self.lastDateFrom = Date()
        self.canLoadMore = true
        self.isLoadingPage = false
        self.isFirstLoad = true
    }
    
    func loadAditLogs() {
        FeedService.getAditLogs(teamId: GaryPortal.shared.currentUser?.userTeam?.teamId ?? 0) { (aditLogs, error) in
            DispatchQueue.main.async {
                if error == nil {
                    self.aditLogs = []
                    self.aditLogs = aditLogs ?? []
                    self.mapAditLogs()
                }
            }
        }
    }
    
    func mapAditLogs() {
        let keys = Array(Set(aditLogs.map { $0.posterDTO }))
        DispatchQueue.main.async { [weak self] in
            self?.aditLogGroups = []
            keys.forEach { (dto) in
                if GaryPortal.shared.currentUser?.hasBlockedUUID(uuid: dto?.userUUID ?? "") == false {
                    self?.aditLogGroups.append(AditLogGroup(aditLogGroupHash: UUID(), posterDTO: dto, aditLogs: self?.aditLogs.filter { $0.posterDTO == dto }))
                }
            }
        }
    }
    
    func loadMoreContentIfNeeded(currentPost post: FeedPost?) {
        guard let post = post else {
            loadMoreContent()
            return
        }
        
        let thresholdIndex = posts.index(posts.endIndex, offsetBy: -3)
        if posts.firstIndex(where: { $0.postId == post.postId }) == thresholdIndex {
            loadMoreContent()
        }
    }
    
    func loadMoreContent() {
        guard !isLoadingPage, canLoadMore else {
            return
        }
        isLoadingPage = true

        let cache = Shared.JSONCache
        
        if isFirstLoad {
            self.posts.removeAll()
            cache.fetch(key: "firstFeedPosts").onSuccess { json in
                if let cachedPosts = try? json.decode(to: [ClassWrapper<FeedFamily, FeedPost>].self) {
                    cachedPosts.compactMap({ $0.object }).forEach { post in
                        self.posts.append(post)
                    }
                }
            }
        }
        FeedService.getFeedPosts(startingFrom: lastDateFrom, limit: 10, teamId: GaryPortal.shared.currentUser?.userTeam?.teamId ?? 0) { (newPosts, error) in
            if error == nil && GaryPortal.shared.currentUser?.getFirstBanOfType(banTypeId: 3) == nil {
                DispatchQueue.main.async {
                    
                    if self.isFirstLoad {
                        self.posts.removeAll()
                    }
                    
                    newPosts?.forEach({ (newPost) in
                        if !self.posts.contains(where: { $0.postId == newPost.postId }) {
                            self.posts.append(newPost)
                        }
                    })
                    self.lastDateFrom = newPosts?.last?.postCreatedAt ?? Date()
                    if (newPosts?.count ?? 0) < 9 {
                        self.canLoadMore = false
                    }
                    
                    if self.isFirstLoad {
                        self.isFirstLoad = false
                        NotificationCenter.default.post(name: .movedFromFeed, object: nil)
                        if let postsJson = newPosts?.encodeToJSONObject() {
                            cache.set(value: postsJson, key: "firstFeedPosts")
                        }
                    }
                    self.isLoadingPage = false
                }
            } else {
                if error == APIError.feedBan || GaryPortal.shared.currentUser?.getFirstBanOfType(banTypeId: 3) != nil {
                    DispatchQueue.main.async {
                        self.isFeedBanned = true
                    }
                }
            }
        }
        
    }
    
    @objc
    func removePost(_ sender: NSNotification) {
        if let postId = sender.userInfo?["postId"] as? Int {
            let index = self.posts.firstIndex(where: { $0.postId == postId }) ?? -1
            guard index != -1 else { return }
            
            self.posts.remove(at: index)
        }
    }
    
    @objc
    func clearVotes(_ sender: NSNotification) {
        if let postId = sender.userInfo?["postId"] as? Int {
            let index = self.posts.firstIndex(where: { $0.postId == postId }) ?? -1
            guard index != -1, let post = self.posts[index] as? FeedPollPost else { return }
            
            post.clearVotes()
            self.posts[index] = post
        }
    }
}

class CommentsDataSource: ObservableObject {
    private var postId: Int = 0
    @Published var comments: [FeedComment] = []
    @Published var scrollToId = 0
    
    func setup(for postId: Int) {
        self.postId = postId
        self.loadComments()
    }
    
    func loadComments() {
        FeedService.getCommentsForPost(self.postId) { (comments, error) in
            DispatchQueue.main.async {
                self.comments = comments ?? []
            }
        }
    }
    
    func getFilteredComments() -> [FeedComment] {
        return self.comments.filter( { GaryPortal.shared.currentUser?.hasBlockedUUID(uuid: $0.userUUID ?? "" ) == false })
    }
    
    func postComment(_ text: String, _ completion: @escaping((FeedComment?) -> Void)) {
        let comment = FeedComment(feedCommentId: 0, userUUID: GaryPortal.shared.currentUser?.userUUID ?? "", postId: self.postId, comment: text, isAdminComment: false, isDeleted: false, datePosted: Date(), userDTO: nil)
        FeedService.postComment(comment) { (finalComment, error) in
            if let finalComment = finalComment {
                DispatchQueue.main.async {
                    self.comments.append(finalComment)
                    completion(finalComment)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    func deleteComment(_ commentId: Int) {
        FeedService.deleteComment(commentId)
        DispatchQueue.main.async {
            self.comments.removeAll(where: { $0.feedCommentId == commentId })
        }
    }
    
    func postNotification(_ content: String) {
        FeedService.postCommentNotification(for: self.postId, content: content)
    }
}
