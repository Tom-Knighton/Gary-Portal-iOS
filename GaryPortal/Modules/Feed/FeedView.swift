//
//  FeedView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 21/01/2021.
//

import SwiftUI
import AVKit
import VideoPlayer

struct FeedView: View {
    
    @EnvironmentObject var garyportal: GaryPortal
    @State var aditLogs: [AditLog] = []
    @State var aditLogGroups: [AditLogGroup] = []
    
    init(){
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        loadAditLogs()
    }

    
    var body: some View {
        GeometryReader { geometry in
            List {
                AditLogView(aditLogGroups: aditLogGroups)
                    .listRowBackground(Color.clear)
                FeedPostTable()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .edgesIgnoringSafeArea(.bottom)
        .edgesIgnoringSafeArea(.leading)
        .edgesIgnoringSafeArea(.trailing)
        .onAppear {
            loadAditLogs()
        }
    }
    
    func loadAditLogs() {
        FeedService.getAditLogs { (aditLogs, error) in
            if error == nil {
                self.aditLogs = []
                self.aditLogs = aditLogs ?? []
                self.mapAditLogs()
            }
        }
    }
    
    func mapAditLogs() {
        let keys = Array(Set(aditLogs.map { $0.posterDTO }))
        keys.forEach { (dto) in
            self.aditLogGroups = []
            self.aditLogGroups.append(AditLogGroup(aditLogGroupHash: UUID(), posterDTO: dto, aditLogs: aditLogs.filter { $0.posterDTO == dto }))
        }
    }
}

struct AditLogView: View {
    
    var aditLogGroups: [AditLogGroup] = []
    
    var body: some View {
        return ScrollView(.horizontal) {
            LazyHStack {
                ForEach(aditLogGroups, id: \.self) { group in
                    AditLogListItem(userAditLogs: group)
                }
            }
        }
        .frame(maxHeight: 110)
        .listRowBackground(Color.clear)
    }
}

struct AditLogListItem: View {
    
    @State var userAditLogs: AditLogGroup?
    @State var previewAditLog: AditLog?
    
    var body: some View {
        HStack {
            Spacer().frame(width: 8)
            VStack {
                Spacer().frame(height: 4)
                HStack {
                    Spacer()
                    if previewAditLog?.isVideo == false {
                        AsyncImage(url: previewAditLog?.aditLogUrl ?? "")
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 84, height: 84)
                            .cornerRadius(25)
                            .shadow(radius: 5)
                    } else {
                        AsyncImage(url: previewAditLog?.aditLogThumbnailUrl ?? "")
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 84, height: 84)
                            .cornerRadius(25)
                            .shadow(radius: 5)
                    }
                    Spacer()
                }
                Text(previewAditLog?.posterDTO?.userFullName ?? "")
                    .font(.custom("Montserrat-Regular", size: 13))
                    .foregroundColor(Color(UIColor.systemBackground))
                    .frame(maxWidth: 100)
                Spacer().frame(height: 8)
            }
            .cornerRadius(10)
            Spacer().frame(width: 8)
        }
        .onAppear {
            self.previewAditLog = userAditLogs?.aditLogs?.last
        }
    }
}

class FeedPostsDataSource: ObservableObject {
    @Published var posts = [FeedPost]()
    @Published var isLoadingPage = false
    @Published var canLoadMore = true
    private var lastDateFrom = Date()
    
    init() {
        loadMoreContent()
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
        FeedService.getFeedPosts(startingFrom: lastDateFrom, limit: 10) { (newPosts, error) in
            if error == nil {
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
                }
            }
        }
    }
}

struct FeedPostTable: View {
    
    @ObservedObject var dataSource = FeedPostsDataSource()
    
   
    var body: some View {
        ForEach(dataSource.posts, id: \.postId) { post in
            if post is FeedMediaPost {
                PostMediaView(post: post as! FeedMediaPost, dataSource: dataSource)
                    .onAppear {
                        self.dataSource.loadMoreContentIfNeeded(currentPost: post)
                    }
                    .padding(.all, 4)
                    .shadow(color: Color.black, radius: 15)
            }
        }
        .listRowBackground(Color.clear)
    }
}

struct PostMediaView: View {
    
    var post: FeedMediaPost
    @State var isPlaying = false
    @StateObject var dataSource: FeedPostsDataSource = FeedPostsDataSource()
    @AppStorage(GaryPortalConstants.UserDefaults.autoPlayVideos) var autoPlayVideos = false

    
    let disapperPub = NotificationCenter.default.publisher(for: .movedFromFeed)
    let appearPub = NotificationCenter.default.publisher(for: .goneToFeed)
    
    var body: some View {
        VStack {
            PostHeaderView(post: post, dataSource: dataSource)
            
            if post.isVideo == true {
                PlayerView(url: post.postUrl ?? "", play: $isPlaying)
                    .cornerRadius(15)
                    .frame(maxWidth: .infinity, minHeight: 350)
                    .padding(8)
                    .shadow(radius: 3)
                    .onTapGesture {
                        self.isPlaying = !self.isPlaying
                    }
                    .onAppear {
                        self.isPlaying = self.autoPlayVideos
                    }
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
            
            PostActionView(post: post, dataSource: dataSource)
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
            self.isPlaying = self.autoPlayVideos
        })
    }
    
    func getDescText() -> String {
        return "\(post.posterDTO?.userFullName ?? ""): \(post.postDescription ?? "")"
    }
}

struct PostHeaderView: View {
    
    @ObservedObject var post: FeedPost
    @StateObject var dataSource: FeedPostsDataSource
    
    var body: some View {
        HStack{
            AsyncImage(url: post.posterDTO?.userProfileImageUrl ?? "")
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            Text(post.posterDTO?.userFullName ?? "")
                .font(.custom("Montserrat-SemiBold", size: 17))
            Spacer()
            Text("...")
            Spacer().frame(width: 8)
        }
        .padding(.top, 8)
        .padding(.leading, 8)
        .padding(.trailing, 8)
    }
}

struct PostActionView: View {
    
    @ObservedObject var post: FeedPost
    @EnvironmentObject var garyportal: GaryPortal
    @StateObject var dataSource: FeedPostsDataSource
    
    @State var isLiked = false
    @State var likeCount = 0

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
            Image(systemName: "bubble.middle.bottom")

            Spacer()

            Image(systemName: "square.and.arrow.up")

            Spacer().frame(width: 8)
        }
        .padding(.all, 8)
        .onAppear(perform: setup)
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

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        PostMediaView(post: FeedMediaPost(posterUUID: "7b8288185c0c4cb5bc896d49aa159566", postType: "media", teamId: 2, postURL: "https://res.cloudinary.com/garyportal/image/upload/v1599778023/pj3srxw0yjsg1ezrc6ny.jpg", isVideo: false, postDescription: "Lorem")!, dataSource: FeedPostsDataSource())
            .environmentObject(GaryPortal.shared)
    }
}
