//
//  FeedCells.swift
//  AlMurray
//
//  Created by Tom Knighton on 12/09/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import UIKit
import Nuke
import AVKit

protocol FeedListControllerDelegate: class {
    
    func toggleLikeForPost(postId: Int, liked: Bool)
}

class FeedPostMediaCell: UITableViewCell {

    @IBOutlet private weak var postContainer: UIView?
    @IBOutlet private weak var postProfilePicture: UIImageView?
    @IBOutlet private weak var postMediaView: UIImageView?
    @IBOutlet private weak var posterPictureView: UIImageView?
    @IBOutlet private weak var posterNameLabel: UILabel?
    @IBOutlet private weak var postDescriptionLabel: UILabel?
    @IBOutlet private weak var postVideoView: UIView?
    
    @IBOutlet private weak var heartButton: UIButton?
    @IBOutlet private weak var likesCountButton: UIButton?
    @IBOutlet private weak var commentButton: UIButton?
    @IBOutlet private weak var shareButton: UIButton?
    
    var avPlayer: AVPlayer?
    var avPlayerLayer: AVPlayerLayer?
    
    private var post: FeedMediaPost?
    weak var delegate: FeedListControllerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.postContainer?.roundCorners(radius: 20, masksToBounds: false)
        self.postContainer?.addShadow(opacity: 1, radius: 5)
    }
        
    func setup(for post: FeedMediaPost) {
        self.post = post
        let hasLikedPost = post.hasBeenLikedByUser(userName: GaryPortal.shared.user?.userFullName ?? "")

        Nuke.loadImage(with: URL(string: post.poster?.userProfileImageUrl ?? "") ?? URL(string: "")!, into: self.posterPictureView ?? UIImageView())
        self.posterPictureView?.roundCorners(radius: 25)
        
        self.posterNameLabel?.text = post.poster?.userFullName ?? ""
        self.postDescriptionLabel?.text = "\(post.poster?.userFullName ?? ""): \(post.postDescription ?? "")"
        
        self.heartButton?.setImage(UIImage(systemName: hasLikedPost ? "heart.fill" : "heart"), for: .normal)
        self.likesCountButton?.setTitle(String(describing: post.likes?.count ?? 0), for: .normal)
        self.commentButton?.setImage(UIImage(systemName: "bubble.middle.bottom"), for: .normal)
        self.shareButton?.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        
        if post.postType == "Image" {
            self.postMediaView?.isHidden = false
            self.postVideoView?.isHidden = true
            if let url = URL(string: post.postURL ?? "") {
                Nuke.loadImage(with: url, into: self.postMediaView ?? UIImageView())
            }
        } else if post.postType == "Video" {
            self.postMediaView?.isHidden = true
            self.postVideoView?.isHidden = false
            self.setupVideoPlayer()
        }
    }
    
    func playVideo() {
        do {
           try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch let error {
            print(error.localizedDescription)
        }
        self.avPlayer?.isMuted = false
        self.avPlayer?.play()
    }
    
    func setupVideoPlayer() {
        if let videoURL = URL(string: self.post?.postURL ?? "") {
            self.avPlayer = AVPlayer(url: videoURL)
            let playerLayer = AVPlayerLayer(player: self.avPlayer)
            playerLayer.frame = self.postVideoView?.bounds ?? CGRect()
            playerLayer.backgroundColor = UIColor.clear.cgColor
            self.postVideoView?.layer.addSublayer(playerLayer)
            
            if GaryPortal.shared.localAppSettings.autoPlayVideos {
                self.playVideo()
                _ = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.avPlayer?.currentItem, queue: nil) { _ in
                    self.avPlayer?.seek(to: CMTime.zero)
                    self.avPlayer?.play()
                }
            }
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapPostVideo))
            self.postVideoView?.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc
    func tapPostVideo() {
        if self.avPlayer?.timeControlStatus == AVPlayer.TimeControlStatus.paused {
            self.playVideo()
            _ = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.avPlayer?.currentItem, queue: nil) { _ in
                self.avPlayer?.seek(to: CMTime.zero)
                self.avPlayer?.play()
            }
        } else {
            self.avPlayer?.pause()
        }
    }
    
    @IBAction func likeButtonTapped(_ sender: Any) {
        let isCurrentlyLiked = self.post?.hasBeenLikedByUser(userName: GaryPortal.shared.user?.userFullName ?? "") ?? false
        delegate?.toggleLikeForPost(postId: self.post?.postId ?? 0, liked: !isCurrentlyLiked)
    }
    
}

class FeedPostPollCell: UITableViewCell {
    
    @IBOutlet private weak var postContainer: UIView?
    @IBOutlet private weak var posterProfileImageView: UIImageView?
    @IBOutlet private weak var posterNameLabel: UILabel?
    @IBOutlet private weak var heartButton: UIButton?
    @IBOutlet private weak var likesLabel: UIButton?
    @IBOutlet private weak var commentsButton: UIButton?
    @IBOutlet private weak var shareButton: UIButton?
    
    @IBOutlet private weak var pollQuestionLabel: UILabel?
    @IBOutlet private weak var pollOption1: PollPercentageView?
    @IBOutlet private weak var pollOption2: PollPercentageView?
    
    var post: FeedPollPost?
    weak var delegate: FeedListControllerDelegate?
    
    override func awakeFromNib() {
       super.awakeFromNib()
       
       self.postContainer?.roundCorners(radius: 20, masksToBounds: false)
       self.postContainer?.addShadow(opacity: 1, radius: 5)
   }
           
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.pollOption1?.viewWithTag(10)?.removeFromSuperview()
        self.pollOption2?.viewWithTag(10)?.removeFromSuperview()

    }
    
    func setup(for post: FeedPollPost) {
        self.post = post
        let hasLikedPost = post.hasBeenLikedByUser(userName: GaryPortal.shared.user?.userFullName ?? "")
        if let profileUrl = URL(string: post.poster?.userProfileImageUrl ?? "") {
            Nuke.loadImage(with: profileUrl, into: self.posterProfileImageView ?? UIImageView())
        }
        
        self.posterProfileImageView?.roundCorners(radius: 25)
        self.posterNameLabel?.text = post.poster?.userFullName ?? ""
        self.pollQuestionLabel?.text = post.pollQuestion ?? ""
       
        self.pollOption1?.layer.borderWidth = 1
        self.pollOption1?.layer.borderColor = UIColor.systemBlue.cgColor
        self.pollOption2?.layer.borderWidth = 1
        self.pollOption2?.layer.borderColor = UIColor.systemBlue.cgColor
        self.pollOption1?.roundCorners(radius: 15, masksToBounds: true)
        self.pollOption2?.roundCorners(radius: 15, masksToBounds: true)
        
        self.heartButton?.setImage(UIImage(systemName: hasLikedPost ? "heart.fill" : "heart"), for: .normal)
        self.likesLabel?.setTitle(String(describing: post.likes?.count ?? 0), for: .normal)
        self.commentsButton?.setImage(UIImage(systemName: "bubble.middle.bottom"), for: .normal)
        self.shareButton?.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)

        let hasVotedOn = self.post?.hasBeenVotedOn(by: GaryPortal.shared.user?.userId ?? "") ?? false
        if hasVotedOn {
            let totalVotes = (self.post?.pollAnswers?[0].responses?.count ?? 0) + (self.post?.pollAnswers?[1].responses?.count ?? 0)
            let votes1 = self.post?.pollAnswers?[0].responses?.count ?? 0
            let votes2 = self.post?.pollAnswers?[1].responses?.count ?? 0
            let vote1Percentage = CGFloat(votes1) / CGFloat(totalVotes)
            let vote2Percentage = CGFloat(votes2) / CGFloat(totalVotes)
    
            self.pollOption1?.setTitle("\(self.post?.pollAnswers?[0].answer ?? ""): \(Int(vote1Percentage * 100))%", for: .normal)
            self.pollOption1?.isUserInteractionEnabled = false
            self.pollOption2?.setTitle("\(self.post?.pollAnswers?[1].answer ?? ""): \(Int(vote2Percentage * 100))%", for: .normal)
            self.pollOption2?.isUserInteractionEnabled = false
            self.pollOption1?.setProgess(progress: vote1Percentage)
            self.pollOption2?.setProgess(progress: vote2Percentage)
            
        } else {
            self.pollOption1?.setProgess(progress: 0)
            self.pollOption2?.setProgess(progress: 0)
            self.pollOption1?.setTitle(post.pollAnswers?[0].answer ?? "", for: .normal)
            self.pollOption2?.setTitle(post.pollAnswers?[1].answer ?? "", for: .normal)
        }
    }
    
    @IBAction func likeButtonTapped(_ sender: Any) {
        let isCurrentlyLiked = self.post?.hasBeenLikedByUser(userName: GaryPortal.shared.user?.userFullName ?? "") ?? false
        delegate?.toggleLikeForPost(postId: self.post?.postId ?? 0, liked: !isCurrentlyLiked)
    }
    
}

class FeedAditLogContainerCell: UITableViewCell {
    
    @IBOutlet private weak var aditLogCollectionView: FeedAditLogCollectionView?
    
    func setup(for posts: [AditLog]) {
        let aditlogs: [UserDTO: [AditLog]] = Dictionary(grouping: posts, by: {
            if let user = $0.poster {
                return user
            }
            return UserDTO(userId: "", userFullName: "", userProfileImageUrl: "", userIsStaff: false, userIsAdmin: false)
        })
        self.aditLogCollectionView?.setup(for: aditlogs)
    }
}

class FeedAditLogCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    private var aditLogs: [UserDTO: [AditLog]] = [:]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.aditLogs.keys.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: "FeedAditLogCell", for: indexPath) as? AditLogCell else { return UICollectionViewCell() }
        
        if indexPath.row == 0 {
            cell.setupAsCreateButton()
        } else {
            let aditLogArray = Array(self.aditLogs)[indexPath.row - 1]
            cell.setup(for: [aditLogArray.key: aditLogArray.value])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 150)
    }
    
    func setup(for aditLogs: [UserDTO: [AditLog]]) {
        self.delegate = self
        self.dataSource = self
        self.aditLogs = aditLogs
    }
}

class AditLogCell: UICollectionViewCell {
    
    @IBOutlet private weak var aditLogPreviewImage: UIImageView?
    @IBOutlet private weak var aditLogPosterLabel: UILabel!
    
    func setup(for userAditLogs: [UserDTO: [AditLog]]) {
        let previewAditLog = userAditLogs.values.first?.last
        self.aditLogPosterLabel.font = UIFont(name: "Montserrat-Regular", size: 13)
        self.aditLogPosterLabel.text = previewAditLog?.poster?.userFullName ?? ""

        self.aditLogPreviewImage?.contentMode = .scaleAspectFill
        if previewAditLog?.postType ?? "" == "Image" {
            if let postURL = URL(string: previewAditLog?.postURL ?? "") {
                Nuke.loadImage(with: postURL, into: self.aditLogPreviewImage ?? UIImageView())
            }
        } else if previewAditLog?.postType ?? "" == "Video" {
            if let thumbnailURL = URL(string: previewAditLog?.postThumbnailURL ?? "") {
                Nuke.loadImage(with: thumbnailURL, into: self.aditLogPreviewImage ?? UIImageView())
            }
        }
        
        self.aditLogPreviewImage?.layer.cornerRadius = 25
        self.aditLogPreviewImage?.layer.masksToBounds = true
        self.aditLogPreviewImage?.addGradientBorder(colours: [UIColor(hexString: "#3494E6"), UIColor(hexString: "#EC6EAD")])
    }
    
    func setupAsCreateButton() {
        self.aditLogPreviewImage?.contentMode = .center
        self.aditLogPosterLabel.text = "Upload ADit LoG"
        self.aditLogPosterLabel.font = UIFont(name: "Montserrat-SemiBold", size: 13)
        self.aditLogPreviewImage?.image = UIImage(named: "upload-glyph")
        self.aditLogPreviewImage?.layer.cornerRadius = 25
        self.aditLogPreviewImage?.layer.masksToBounds = true
        self.aditLogPreviewImage?.addGradientBorder(colours: [UIColor(hexString: "#3494E6"), UIColor(hexString: "#EC6EAD")])
    }
    
}
