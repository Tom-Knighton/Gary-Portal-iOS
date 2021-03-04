//
//  FeedView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 21/01/2021.
//

import SwiftUI
import AVKit
import Introspect

struct FeedView: View {
    
    @ObservedObject var garyportal = GaryPortal.shared
    @ObservedObject var datasource = FeedPostsDataSource()
    @State var isShowingCreator = false
    
    init(){
        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().separatorStyle = .none
        UITableViewCell.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        GeometryReader { geometry in
            if self.datasource.isFeedBanned {
                ZStack {
                    Color.black.cornerRadius(10).edgesIgnoringSafeArea(.all)
                    Text("You have been temporarily banned from GaryGram, please wait until your ban expires to access the feed again")
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                        .edgesIgnoringSafeArea(.all)
                }
            } else {
                ZStack {
                    List {
                        AditLogView(datasource: datasource)
                            .listRowBackground(Color.clear)
                        FeedPostTable(dataSource: datasource)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .listSeparatorStyle(.none)
                    .introspectTableView { (tableView) in
                        tableView.refreshControl = UIRefreshControl { refreshControl in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                self.datasource.reset()
                                self.datasource.loadAditLogs()
                                self.datasource.loadMoreContent()
                                refreshControl.endRefreshing()
                            }
                        }
                        
                    }
                    
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { self.isShowingCreator = true }) {
                            Image("upload-glyph")
                                .frame(width: 64, height: 64)
                                .cornerRadius(10)
                                .background(LinearGradient(gradient: Gradient(colors: [Color(UIColor(hexString: "#ad5389")), Color(UIColor(hexString: "#3c1053"))]), startPoint: .topLeading, endPoint: .bottomTrailing).cornerRadius(10))
                        }
                        .opacity(0.75)
                        .padding()
                        .shadow(radius: 5)
                        Spacer().frame(width: 16)
                    }
                    Spacer().frame(height: 16)
                }
            }
            
        }
        .edgesIgnoringSafeArea(.bottom)
        .edgesIgnoringSafeArea(.leading)
        .edgesIgnoringSafeArea(.trailing)
        .onAppear {
            datasource.loadAditLogs()
            datasource.loadMoreContent()
        }
        .sheet(isPresented: $isShowingCreator) {
            UploadPostView(datasource: datasource)
        }
    }
}

struct AditLogView: View {
    
    @ObservedObject var datasource: FeedPostsDataSource
    @State var showFullScreen = false
    @State var showCamera = false
    
    var body: some View {
        return ScrollView(.horizontal) {
            LazyHStack {
                AditLogListItem(isUploader: true)
                    .onTapGesture {
                        self.showCamera = true
                    }
                    .fullScreenCover(isPresented: $showCamera) {
                        CameraView(timeLimit: 25, allowsGallery: false) { (success, isVideo, url) in
                            self.showCamera = false
                            if success {
                                self.uploadAditLog(isVideo: isVideo, url: url)
                            }
                        }
                    }
                
                ForEach(datasource.aditLogGroups, id: \.self) { group in
                    AditLogListItem(userAditLogs: group)
                        .onTapGesture {
                            self.showFullScreen = true
                        }
                        .fullScreenCover(isPresented: $showFullScreen) {
                            NotificationCenter.default.post(name: .goneToFeed, object: nil)
                        } content: {
                            FeedAditLogView(aditLogs: group)
                        }

                }
            }
        }
        .frame(maxHeight: 110)
        .listRowBackground(Color.clear)
    }
    
    func uploadAditLog(isVideo: Bool, url: URL?) {
        if let url = url {
            FeedService.uploadAditLogMedia(isVideo ? nil : url.absoluteString, isVideo ? url.absoluteString : nil) { (urls, error) in
                if let urls = urls {
                    let aditLog = AditLog(aditLogId: 0, aditLogUrl: urls.aditLogUrl, aditLogThumbnailUrl: urls.aditLogThumbnailUrl, posterUUID: GaryPortal.shared.currentUser?.userUUID, aditLogTeamId: GaryPortal.shared.currentUser?.userTeam?.teamId, isVideo: isVideo, datePosted: Date(), aditLogViews: 0, caption: "", isDeleted: false, poster: nil, posterDTO: nil, aditLogTeam: nil)
                    FeedService.postAditLog(aditLog) { (finalAditLog, error) in
                        if let _ = finalAditLog {
                            self.datasource.loadAditLogs()
                        }
                    }
                }
            }
        }
    }
}

struct AditLogListItem: View {
    
    @State var userAditLogs: AditLogGroup?
    @State var previewAditLog: AditLog?
    @State var isUploader = false
    
    var body: some View {
        HStack {
            Spacer().frame(width: 8)
            VStack {
                Spacer().frame(height: 8)
                if isUploader {
                    uploader
                } else {
                    HStack {
                        Spacer()
                        if previewAditLog?.isVideo == false {
                            AsyncImage(url: previewAditLog?.aditLogUrl ?? "")
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 84, height: 84)
                                .cornerRadius(25)
                                .shadow(radius: 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                                )
                        } else {
                            AsyncImage(url: previewAditLog?.aditLogThumbnailUrl ?? "")
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 84, height: 84)
                                .cornerRadius(25)
                                .shadow(radius: 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                                )
                        }
                        Spacer()
                    }
                    Text(previewAditLog?.posterDTO?.userFullName ?? "")
                        .font(.custom("Montserrat-Regular", size: 13))
                        .foregroundColor(Color(UIColor.systemBackground))
                        .frame(maxWidth: 100)
                }
               
                Spacer().frame(height: 8)
            }
            .cornerRadius(10)
            Spacer().frame(width: 8)
        }
        .onAppear {
            self.previewAditLog = userAditLogs?.aditLogs?.last
        }
    }
    
    @ViewBuilder
    var uploader: some View {
        HStack {
            Spacer()
            Image("upload-glyph")
                .frame(width: 80, height: 80)
                .cornerRadius(25)
                .shadow(radius: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                )
            Spacer()
        }
        Text("Upload")
            .font(.custom("Montserrat-SemiBold", size: 14))
            .foregroundColor(Color(UIColor.systemBackground))
            .frame(maxWidth: 100)
    }
}

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
        FeedService.getAditLogs { (aditLogs, error) in
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
            keys.forEach { (dto) in
                self?.aditLogGroups = []
                self?.aditLogGroups.append(AditLogGroup(aditLogGroupHash: UUID(), posterDTO: dto, aditLogs: self?.aditLogs.filter { $0.posterDTO == dto }))
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
        FeedService.getFeedPosts(startingFrom: lastDateFrom, limit: 10, teamId: GaryPortal.shared.currentUser?.userTeam?.teamId ?? 0) { (newPosts, error) in
            if error == nil && GaryPortal.shared.currentUser?.getFirstBanOfType(banTypeId: 3) == nil {
                DispatchQueue.main.async {
                    newPosts?.forEach({ (newPost) in
                        if !self.posts.contains(where: { $0.postId == newPost.postId }) {
                            self.posts.append(newPost)
                        }
                    })
                    self.lastDateFrom = newPosts?.last?.postCreatedAt ?? Date()
                    self.isLoadingPage = false
                    if (newPosts?.count ?? 0) < 9 {
                        self.canLoadMore = false
                    }
                    
                    if self.isFirstLoad {
                        NotificationCenter.default.post(name: .movedFromFeed, object: nil)
                        self.isFirstLoad = false
                    }
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

struct FeedPostTable: View {
    
    @ObservedObject var dataSource = FeedPostsDataSource()
    
   
    var body: some View {
        ForEach(dataSource.posts, id: \.postId) { post in
            if GaryPortal.shared.currentUser?.hasBlockedUUID(uuid: post.posterUUID ?? "") == true {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(Color(UIColor.secondarySystemBackground).opacity(0.8))
                    .overlay(
                        Text("Post by blocked user")
                            .frame(maxWidth: .infinity)
                            .padding(.all)
                    )
                    .onAppear {
                        self.dataSource.loadMoreContentIfNeeded(currentPost: post)
                    }
                    .shadow(color: Color.black, radius: 15)
            } else {
                if post is FeedMediaPost {
                    PostMediaView(post: post as! FeedMediaPost)
                        .onAppear {
                            self.dataSource.loadMoreContentIfNeeded(currentPost: post)
                        }
                        .padding(.all, 4)
                        .shadow(color: Color.black, radius: 15)
                } else if post is FeedPollPost {
                    PostPollView(pollModel: PollPostViewModel(post: post as! FeedPollPost))
                        .onAppear {
                            self.dataSource.loadMoreContentIfNeeded(currentPost: post)
                        }
                        .padding(.all, 4)
                        .shadow(color: Color.black, radius: 15)
                }
            }
        }
        .listRowBackground(Color.clear)
    }
}

struct PostMediaView: View {
    
    var post: FeedMediaPost
    @State var isPlaying = false
    
    let disapperPub = NotificationCenter.default.publisher(for: .movedFromFeed)
    let appearPub = NotificationCenter.default.publisher(for: .goneToFeed)
    
    var body: some View {
        VStack {
            PostHeaderView(post: post)
            
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
                    .frame(maxWidth: .infinity, maxHeight: 350)

                    .padding(8)
                    .shadow(radius: 3)
            }
            
            PostActionView(post: post)
            Text(getDescText())
                .font(.custom("Montserrat-Light", size: 15))
                .frame(maxHeight: 100)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.all, 8)
        }
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(15)
        .onReceive(disapperPub, perform: { _ in
            self.isPlaying = false
        })
        .onReceive(appearPub, perform: { _ in
            self.isPlaying = false
        })
    }
    
    func getDescText() -> String {
        return "\(post.posterDTO?.userFullName ?? ""): \(post.postDescription ?? "")"
    }
}

class PollPostViewModel: ObservableObject {
    @Published var post: FeedPollPost
    @Published var totalVotes: Int
    @Published var hasVoted = false
    
    init(post: FeedPollPost) {
        self.post = post
        self.totalVotes = post.pollAnswers?.map({ $0.votes?.count ?? 0 }).reduce(0, +) ?? -1
        self.hasVoted = post.hasBeenVotedOn(by: GaryPortal.shared.currentUser?.userUUID ?? "")
    }
}

struct PostPollView: View {
    
    @ObservedObject var pollModel: PollPostViewModel
    
    var body: some View {
        VStack {
            PostHeaderView(post: pollModel.post)
            
            HStack {
                Text(pollModel.post.pollQuestion ?? "")
                    .font(.custom("Montserrat-SemiBold", size: 19))
                    .padding()
                Spacer()
            }
            
            LazyVStack {
                ForEach(pollModel.post.pollAnswers ?? [], id: \.pollAnswerId) { answer in
                    PollPostVoteButton(pollModel: self.pollModel, pollAnswer: answer)
                }
            }
            
            PostActionView(post: pollModel.post)
            
        }
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(15)
    }
}

struct PollPostVoteButton: View {
    
    @ObservedObject var pollModel: PollPostViewModel
    var pollAnswer: FeedPollAnswer?
    
    var body: some View {
        HStack {
            Spacer().frame(width: 16)
            Button(action: { vote() }, label: {
                Text(getTitleText())
                    .font(.custom("Montserrat-SemiBold", size: 19))
                    .foregroundColor(Color.blue)
                    .padding(.all, 8)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 45)
            })
            .background(
                GeometryReader { geometry in
                    if !getVotePercentage().isNaN {
                        RoundedRectangle(cornerRadius: 0).foregroundColor(Color(red: 0.67, green: 0.67, blue: 0.67, opacity: 0.3))
                            .frame(width: geometry.size.width * CGFloat(getVotePercentage()), alignment: .leading)
                            .animation(.linear)
                    }
                }
            )
            .overlay(
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(pollModel.hasVoted ? Color.black : Color.blue, lineWidth: 1)
                }
            )
            .cornerRadius(15)
            .clipped()
            
            .buttonStyle(PlainButtonStyle())
            
            .disabled(pollModel.hasVoted)
            Spacer().frame(width: 16)
        }
        
    }
    
    func vote() {
        DispatchQueue.main.async {
            let newVote = FeedAnswerVote(pollAnswerId: self.pollAnswer?.pollAnswerId ?? 0, userUUID: GaryPortal.shared.currentUser?.userUUID ?? "", isDeleted: false)
            FeedService.voteOnPoll(for: self.pollAnswer?.pollAnswerId ?? 0, userUUID: GaryPortal.shared.currentUser?.userUUID ?? "")
            let indexOf = self.pollModel.post.pollAnswers?.firstIndex(where: { $0.pollAnswerId == self.pollAnswer?.pollAnswerId ?? 0 }) ?? 0
            self.pollModel.post.pollAnswers?[indexOf].votes?.append(newVote)
            self.pollModel.hasVoted = true
            self.pollModel.totalVotes += 1
        }
    }
    
    func getTitleText() -> String {
        return pollModel.hasVoted ? "\(self.pollAnswer?.answer ?? ""): \(Int(getVotePercentage() * 100))%" : self.pollAnswer?.answer ?? ""
    }
    
    func getVotePercentage() -> CGFloat {
        let percentage = CGFloat((CGFloat(pollAnswer?.votes?.count ?? 0) / CGFloat(pollModel.totalVotes)))
        return (percentage.isNaN || percentage.isInfinite || !self.pollModel.hasVoted) ? 0 : percentage
    }
}

struct PostHeaderView: View {
    
    @ObservedObject var post: FeedPost
    @State var isShowingAlert = false
    @State var alertContent: [String] = []
    @State var isShowingProfile = false
    @State var viewingUUID: String = ""
    
    var body: some View {
        HStack{
            AsyncImage(url: post.posterDTO?.userProfileImageUrl ?? "")
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            Text(post.posterDTO?.userFullName ?? "")
                .font(.custom("Montserrat-SemiBold", size: 17))
            Spacer()
            Menu(content: {
                Menu("Report...") {
                    Text("Choose a report reason...")
                    Divider()
                    Button("NSFW", action: { self.reportPost(for: "NSFW") })
                    Button("Breaks Policy", action: { self.reportPost(for: "Breaks Policy") })
                    Button("Breaks GaryGram", action: { self.reportPost(for: "Breaks GaryGram") })
                    Button("I'm in this post and I don't like it", action: { self.reportPost(for: "I'm in this post and I don't like it") })
                    Button("Cancel", action: {})
                }
                if self.post is FeedPollPost && self.post.posterUUID == GaryPortal.shared.currentUser?.userUUID {
                    Button("Reset All Poll Votes", action: { self.resetPollVotes() })
                }
                if self.post.posterUUID == GaryPortal.shared.currentUser?.userUUID {
                    Button("Delete Post", action: { self.deletePost() })
                }
                Button("View Profile", action: { self.goToProfile() })
            }, label: {
                Text("...")
                    .fontWeight(.bold)
                    .padding()
                    .foregroundColor(.primary)
            })
            .buttonStyle(PlainButtonStyle())
            Spacer().frame(width: 8)
        }
        .padding(.top, 8)
        .padding(.leading, 8)
        .padding(.trailing, 8)
        .alert(isPresented: $isShowingAlert) {
            Alert(title: Text(self.alertContent[0]), message: Text(self.alertContent[1]), dismissButton: .default(Text("Ok")))
        }
        .sheet(isPresented: $isShowingProfile) {
            ProfileView(uuid: $viewingUUID)
        }
    }
    
    func resetPollVotes() {
        FeedService.resetPollVotes(for: self.post.postId ?? 0)
        self.alertContent = ["Succes", "The votes on this post have all been reset"]
        self.isShowingAlert = true
        let dataDict: [String: Int?] = ["postId": self.post.postId]
        NotificationCenter.default.post(Notification(name: .postVotesCleared, object: self, userInfo: dataDict as [AnyHashable : Any]))
    }
    
    func deletePost() {
        FeedService.deletePost(postId: self.post.postId ?? 0)
        let dataDict: [String: Int?] = ["postId": self.post.postId]
        NotificationCenter.default.post(Notification(name: .postDeleted, object: self, userInfo: dataDict as [AnyHashable : Any]))
    }
    
    func reportPost(for reason: String) {
        FeedService.reportPost(self.post.postId ?? 0, from: GaryPortal.shared.currentUser?.userUUID ?? "", for: reason)
        self.alertContent = [GaryPortalConstants.Messages.thankYou, GaryPortalConstants.Messages.postReported]
        self.isShowingAlert = true
    }
    
    func goToProfile() {
        self.viewingUUID = self.post.posterUUID ?? ""
        self.isShowingProfile = true
    }
}

struct PostActionView: View {
    
    @State var post: FeedPost
    @ObservedObject var garyportal = GaryPortal.shared

    @State var isLiked = false
    @State var likeCount = 0
    @State var isShowingComments = false

    var body: some View {
        HStack {
            Spacer().frame(width: 8)
            
            if isLiked {
                Image(systemName: "heart.fill")
                    .onTapGesture {
                        toggleLike()
                    }
            } else {
                Image(systemName: "heart")
                    .onTapGesture {
                        toggleLike()
                    }
            }

            Text(String(describing: likeCount))
                .font(.custom("Montserrat-SemiBold", size: 17))
            Spacer().frame(width: 16)
            
            Button(action: { self.isShowingComments = true }, label: {
                Text(Image(systemName: "bubble.middle.bottom")) + Text("  \(self.post.comments?.count ?? 0)")
            })
            .buttonStyle(PlainButtonStyle())

            Spacer()

            //Image(systemName: "square.and.arrow.up")

            Spacer().frame(width: 8)
        }
        .padding(.all, 8)
        .onAppear(perform: setup)
        .fullScreenCover(isPresented: $isShowingComments, content: {
            CommentsView(post: self.$post)
        })
    }
    
    func setup() {
        self.isLiked = self.post.hasBeenLikedByUser(userUUID: garyportal.currentUser?.userUUID ?? "")
        self.likeCount = self.post.postLikeCount ?? 0
    }
    
    func toggleLike() {
        let isLiked = self.post.hasBeenLikedByUser(userUUID: garyportal.currentUser?.userUUID ?? "")
        FeedService.toggleLikeForPost(postId: post.postId ?? 0, userUUID: garyportal.currentUser?.userUUID ?? "")
        
        if isLiked {
            self.post.likes?.removeAll(where: { $0.userUUID == garyportal.currentUser?.userUUID ?? "" })
            self.post.postLikeCount = (self.post.postLikeCount ?? 0) - 1
            self.setup()
        } else {
            self.post.likes?.append(FeedLike(userUUID: garyportal.currentUser?.userUUID ?? "", postId: post.postId, isLiked: true))
            self.post.postLikeCount = (self.post.postLikeCount ?? 0) + 1
            self.setup()
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

struct CommentsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var datasource: CommentsDataSource = CommentsDataSource()
    @State var commentText = ""
    @Binding var post: FeedPost
    @State var isShowingProfile = false
    @State var viewingUUID = ""
    
    var body: some View {
        NavigationView {
            let descComment = FeedComment(feedCommentId: 0, userUUID: post.posterUUID, postId: post.postId, comment: post.postDescription, isAdminComment: false, isDeleted: false, datePosted: post.postCreatedAt, userDTO: post.posterDTO)
            VStack {
                ScrollView {
                    ScrollViewReader { reader in
                        LazyVStack {
                            if self.post.postType == "media" && post.postDescription?.isEmptyOrWhitespace() == false {
                                CommentMessageView(comment: descComment)
                                    .contextMenu {
                                        Button(action: { UIPasteboard.general.string = descComment.comment ?? "" }) { Text("Copy Description") }
                                        Button(action: { self.viewingUUID = descComment.userUUID ?? ""; self.isShowingProfile = true }) { Text("View Profile") }
                                    }
                            }
                            ForEach(self.datasource.getFilteredComments(), id: \.feedCommentId) { comment in
                                CommentMessageView(comment: comment)
                                    .contextMenu {
                                        Button(action: { UIPasteboard.general.string = comment.comment ?? "" }) { Text("Copy Comment") }
                                        Button(action: { self.viewingUUID = comment.userUUID ?? ""; self.isShowingProfile = true }) { Text("View Profile") }
                                        if comment.userUUID == GaryPortal.shared.currentUser?.userUUID {
                                            Button(action: { self.datasource.deleteComment(comment.feedCommentId ?? 0) }) { Text("Delete Message") + Text(Image(systemName: "trash")) }
                                        }
                                    }
                            }
                        }
                        .onChange(of: self.datasource.scrollToId, perform: { value in
                            reader.scrollTo(Optional(value), anchor: .bottom)
                        })
                    }
                }
                Spacer().frame(height: 1)
                ChatMessageBarView(content: $commentText, isCameraAllowed: false, placeHolderText: "Your comment...") { text, _, _, _ in
                    self.datasource.postComment(text) { comment in
                        if let comment = comment {
                            self.commentText = ""
                            self.post.comments?.append(comment)
                            self.datasource.scrollToId = comment.feedCommentId ?? 0
                            self.datasource.postNotification((GaryPortal.shared.currentUser?.userName ?? "") + " commented on your post: \(comment.comment ?? "")")
                        }
                    }
                }
                .frame(minHeight: 60)
            }
            .navigationTitle("Comments")
            .navigationBarItems(leading:
                Button(action: { self.presentationMode.wrappedValue.dismiss() }, label: { Text(Image(systemName: "chevron.left")) + Text("  Close")  })
            )
            .onAppear {
                self.datasource.setup(for: self.post.postId ?? 0)
            }
            .sheet(isPresented: $isShowingProfile, content: {
                ProfileView(uuid: $viewingUUID)
            })
        }
        
    }
}

struct CommentMessageView: View {
    
    @State var comment: FeedComment
    var otherUserGradient = [Color(UIColor(hexString: "#4568DC")), Color(UIColor(hexString: "#B06AB3"))]
    var adminGradient = [Color(UIColor(hexString: "#ED213A")), Color(UIColor(hexString: "#93291E"))]
    var body: some View {
        VStack {
            if comment.isAdminComment == true {
                adminMessage
            } else {
                Spacer().frame(height: 8)
                HStack {
                    Spacer().frame(width: 8)
                    Text("\(self.comment.userDTO?.userFullName ?? ""), \(comment.datePosted?.niceDateAndTime() ?? "")")
                    Spacer()
                }
                HStack {
                    Spacer().frame(width: 8)
                    AsyncImage(url: self.comment.userDTO?.userProfileImageUrl ?? "")
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .frame(width: 45, height: 45)
                    Text(self.comment.comment ?? "")
                        .foregroundColor(.white)
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: otherUserGradient), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .cornerRadius(10)
                    Spacer()
                }
            }
            
        }
    }
    
    @ViewBuilder
    var adminMessage: some View {
        Spacer().frame(height: 8)
        Divider()
        HStack {
            Spacer()
            Text("-- ADMIN ANNOUNCEMENT --")
                .fontWeight(.bold)
            Spacer()
        }
        Spacer().frame(height: 8)
        HStack {
            Spacer().frame(width: 8)
            Text("\(self.comment.userDTO?.userFullName ?? ""), \(comment.datePosted?.niceDateAndTime() ?? "")")
            Spacer()
        }
        HStack {
            Spacer().frame(width: 8)
            AsyncImage(url: self.comment.userDTO?.userProfileImageUrl ?? "")
                .aspectRatio(contentMode: .fill)
                .clipShape(Circle())
                .frame(width: 45, height: 45)
            Text(self.comment.comment ?? "")
                .foregroundColor(.white)
                .padding()
                .background(LinearGradient(gradient: Gradient(colors: adminGradient), startPoint: .topLeading, endPoint: .bottomTrailing))
                .cornerRadius(10)
            Spacer()
        }
        Spacer().frame(height: 8)
        Divider()
        Spacer().frame(height: 8)
    }
}
