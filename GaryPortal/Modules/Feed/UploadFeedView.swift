//
//  UploadFeedView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 17/02/2021.
//

import SwiftUI
import Combine


class PollAnswersVM: ObservableObject {
    @Published var textArray = ["A","B","C"]
    
    func updateData() {
            textArray = ["A","B"]
        }
    
    func removeLast() {
        self.textArray.removeLast()
    }
}

struct UploadPostView: View {
    
    @ObservedObject var datasource: FeedPostsDataSource
    @Environment(\.presentationMode) var presentationMode
    
    @State var postType = "GaryGram Post"
    @State var postDesc = ""
    
    @State var isShowingCamera = false
    @State var mediaURL = ""
    @State var isVideo = false
    
    @State var alertContent: [String] = []
    @State var isShowingAlert = false
    
    @State var pollQuestion = ""
    @State var pollAnswer1 = ""
    @State var pollAnswer2 = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Picker("Select Post Type:", selection: $postType) {
                        ForEach(["GaryGram Post", "Gary Poll"], id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    if self.postType == "GaryGram Post" {
                        Spacer().frame(height: 16)
                        mediaView
                            .animation(.easeInOut)
                    } else {
                        pollView
                            .animation(.easeInOut)
                    }
                }
            }
            .navigationTitle("Upload Post")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert(isPresented: $isShowingAlert) {
            Alert(title: Text(alertContent[0]), message: Text(alertContent[1]), dismissButton: .default(Text("Ok")))
        }
        .fullScreenCover(isPresented: $isShowingCamera) {
            CameraView(timeLimit: 15, allowsGallery: true) { (success, isVideo, url) in
                self.isShowingCamera = false
                if success, let url = url {
                    self.isVideo = isVideo
                    self.mediaURL = url.absoluteString
                }
            }
        }
    }
    
    @ViewBuilder
    var mediaView: some View {
        ScrollView {
            mediaPreview
                .aspectRatio(contentMode: .fit)
                .cornerRadius(15)
                .frame(minHeight: 100, maxHeight: 350)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray, lineWidth: 1)
                        .shadow(radius: 3)
                )
                .padding(8)
                .onTapGesture {
                    self.isShowingCamera = true
                }
            
            TextEditor(text: $postDesc)
                .padding()
                .shadow(radius: 5)
                .frame(minHeight: 100)
                .overlay(
                    ZStack(alignment: .leading) {
                        if self.postDesc.isEmpty {
                            Text("Post description...")
                                .foregroundColor(.gray)
                                .disabled(true)
                                .padding()
                        }
                    }
                    .cornerRadius(10)
                )
                .cornerRadius(10)

            GPGradientButton(action: { self.postMediaPost() }, buttonText: "Post", gradientColours: [Color.red, Color.blue])
                .padding()
            Spacer()
        }
        
        Spacer()
    }
    
    @ViewBuilder
    var pollView: some View {
        ScrollView {
            GPTextField(text: self.$pollQuestion, placeHolder: "Poll Question", characterLimit: 64)
                .padding()
            
            GPTextField(text: self.$pollAnswer1, placeHolder: "First Answer", characterLimit: 64)
                .padding()
            GPTextField(text: self.$pollAnswer2, placeHolder: "Second Answer", characterLimit: 64)
                .padding()
            
            
            GPGradientButton(action: { self.postPollPost() }, buttonText: "Post", gradientColours: [Color.red, Color.blue])
                .padding()
        }
        Spacer()
    }
    
    @ViewBuilder
    var mediaPreview: some View {
        if mediaURL.isEmpty {
            Image(systemName: "plus.circle")
                .padding(.horizontal, 100)
        } else if isVideo {
            PlayerView(url: self.mediaURL, play: .constant(true), gravity: .fit)
        } else {
            AsyncImage(url: self.mediaURL)
        }
    }
    
    func postMediaPost() {
        guard !self.mediaURL.isEmptyOrWhitespace() else {
            self.alertContent = ["Error", "Please select a video or image"]
            self.isShowingAlert = true
            return
        }
        
        FeedService.uploadPostAttachment(self.isVideo ? nil : self.mediaURL, self.isVideo ? self.mediaURL : nil) { (url, error) in
            if let url = url {
                let post = FeedMediaPost(posterUUID: GaryPortal.shared.currentUser?.userUUID ?? "", postType: "media", teamId: GaryPortal.shared.currentUser?.userTeam?.teamId ?? 0, postURL: url, isVideo: self.isVideo, postDescription: self.postDesc)
                if let post = post {
                    FeedService.postMediaPost(post) { (finalPost, error) in
                        if let finalPost = finalPost {
                            self.datasource.posts.insert(finalPost, at: 0)
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                
            }
        }
    }
    
    func postPollPost() {
        guard !self.pollQuestion.isEmptyOrWhitespace(),
              !self.pollAnswer1.isEmptyOrWhitespace(),
              !self.pollAnswer2.isEmptyOrWhitespace() else {
            self.alertContent = ["Error", "Please enter a poll question and at least 2 answers"]
            self.isShowingAlert = true
            return
        }
        
        let poll = FeedPollPost(posterUUID: GaryPortal.shared.currentUser?.userUUID ?? "", postType: "poll", teamId: GaryPortal.shared.currentUser?.userTeam?.teamId ?? 0, postDescription: "", question: self.pollQuestion.trim(), answers: [
            FeedPollAnswer(pollAnswerId: 0, pollId: 0, answer: self.pollAnswer1, votes: nil),
            FeedPollAnswer(pollAnswerId: 0, pollId: 0, answer: self.pollAnswer2, votes: nil),
        ])
        if let poll = poll {
            FeedService.postPollPost(poll) { (finalPost, error) in
                if let finalPost = finalPost {
                    DispatchQueue.main.async {
                        self.datasource.posts.insert(finalPost, at: 0)
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct UploadFeedPreview: PreviewProvider {
    
    static var previews: some View {
        UploadPostView(datasource: FeedPostsDataSource())
    }
}
