//
//  FeedHostController.swift
//  AlMurray
//
//  Created by Tom Knighton on 12/09/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import UIKit

class FeedHostController: UITableViewController {
    
    var aditLogs: [AditLog] = []
    var postsToDisplay: [FeedPost] = []
    var isFetchInProgress = false
    
    lazy var createPostButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.roundCorners(radius: 25)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "upload-glyph"), for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        fetchPosts()
        
        self.refreshControl?.addTarget(self, action: #selector(self.refreshStats), for: .valueChanged)
        self.view.addSubview(self.createPostButton)
        self.view.bringSubviewToFront(self.createPostButton)
        self.createPostButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: 0).isActive = true
        self.createPostButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0).isActive = true
        self.createPostButton.heightAnchor.constraint(equalToConstant: 75).isActive = true
        self.createPostButton.widthAnchor.constraint(equalToConstant: 75).isActive = true

    }
    
    override func viewDidLayoutSubviews() {
        self.createPostButton.addGradient(colours: [UIColor(hexString: "#4e54c8"), UIColor(hexString: "#8f94fb")], locations: nil)
        self.createPostButton.bringSubviewToFront(self.createPostButton.imageView ?? UIImageView())
    }
    
    @objc
    func refreshStats() {
        fetchPosts()
    }
    
    func fetchPosts(startFrom: Date = Date()) {
        if isFetchInProgress { return }
        
        isFetchInProgress = true
        DispatchQueue.global().async {
            FeedService().getFeedPosts(startingFrom: startFrom) { (posts) in
                if let posts = posts {
                    posts.forEach { (post) in
                        if !self.postsToDisplay.contains(where: { $0.postId == post.postId }) {
                            self.postsToDisplay.append(post)
                        }
                    }
                    FeedService().getAditLogs { (aditlogs) in
                        if let aditlogs = aditlogs {
                            self.aditLogs = aditlogs
                        }
                        DispatchQueue.main.async {
                            self.refreshControl?.endRefreshing()
                            self.tableView.reloadData()
                            self.isFetchInProgress = false
                        }
                    }
                }
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postsToDisplay.count + 1
        // Posts + Adit logs row
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 1000.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            guard let aditLogCell = self.tableView.dequeueReusableCell(withIdentifier: "FeedAditLogContainerCell") as? FeedAditLogContainerCell else { print("err"); return UITableViewCell() }
            aditLogCell.setup(for: self.aditLogs)
            return aditLogCell
        }
        
        let post = self.postsToDisplay[indexPath.row - 1]
        if post is FeedMediaPost {
            guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "FeedPostCell", for: indexPath) as? FeedPostMediaCell else { return UITableViewCell() }
            guard let post = post as? FeedMediaPost else { return UITableViewCell() }
            
            cell.setup(for: post)
            cell.delegate = self
            return cell
            
        } else if post is FeedPollPost {
            guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "FeedPollCell", for: indexPath) as? FeedPostPollCell else { return UITableViewCell() }
            guard let post = post as? FeedPollPost else { return UITableViewCell() }
            
            cell.setup(for: post)
            cell.delegate = self
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 { return }
        let post = self.postsToDisplay[indexPath.row - 1]
        if post is FeedMediaPost && post.postType == "Video" {
            guard let videoCell = cell as? FeedPostMediaCell else { return }
            
            let visibleCells = self.tableView.visibleCells
            let minIndex = visibleCells.startIndex
            if visibleCells.firstIndex(of: cell) == minIndex {
                videoCell.avPlayer?.play()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 { return }
        let post = self.postsToDisplay[indexPath.row - 1]
        if post is FeedMediaPost && post.postType == "Video" {
            guard let videoCell = cell as? FeedPostMediaCell else { return }
            
            videoCell.avPlayer?.pause()
            videoCell.avPlayer = nil
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let visibleCells = self.tableView.visibleCells
        visibleCells.forEach { (cell) in
            if self.tableView.indexPath(for: cell)?.row == 0 { return }
            let post = self.postsToDisplay[(self.tableView.indexPath(for: cell)?.row ?? 1) - 1]
            if post is FeedMediaPost && post.postType == "Video" {
                guard let videoCell = cell as? FeedPostMediaCell else { return }
                
                videoCell.avPlayer?.pause()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let visibleCells = self.tableView.visibleCells
        visibleCells.forEach { (cell) in
            if self.tableView.indexPath(for: cell)?.row == 0 { return }
            let post = self.postsToDisplay[(self.tableView.indexPath(for: cell)?.row ?? 0) - 1]
            if post is FeedMediaPost && post.postType == "Video" {
                guard let videoCell = cell as? FeedPostMediaCell else { return }
                
                videoCell.playVideo()
            }
        }
    }

}

extension FeedHostController {
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == self.tableView {
            if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - 150 && !isFetchInProgress {
                print((self.postsToDisplay.last?.datePosted?.timeIntervalSince1970 ?? 0) * 1000)
                self.fetchPosts(startFrom: self.postsToDisplay.last?.datePosted ?? Date())
            }
        }
    }
}

extension FeedHostController: FeedListControllerDelegate {
    
    func toggleLikeForPost(postId: Int, liked: Bool) {
        let index = self.postsToDisplay.firstIndex(where: { $0.postId == postId }) ?? -1
        if index == -1 { return }
        
        if liked {
            if var dict = self.postsToDisplay[index].likes {
                dict.updateValue(GaryPortal.shared.user?.userFullName ?? "", forKey: GaryPortal.shared.user?.userFullName ?? "")
                self.postsToDisplay[index].likes = dict
            } else {
                self.postsToDisplay[index].likes = [GaryPortal.shared.user?.userFullName ?? "": GaryPortal.shared.user?.userFullName ?? ""]
            }
        } else {
            self.postsToDisplay[index].likes?.removeValue(forKey: GaryPortal.shared.user?.userFullName ?? "")
        }
        FeedService().toggleLike(for: self.postsToDisplay[index], GaryPortal.shared.user?.userId ?? "")
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
