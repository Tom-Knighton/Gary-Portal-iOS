//
//  IncomingUserMessageTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/6/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import AlamofireImage
import TTTAttributedLabel
import ChameleonFramework
import Firebase
import FirebaseDatabase

class IncomingUserMessageTableViewCell: UITableViewCell, TTTAttributedLabelDelegate {
    weak var delegate: MessageDelegate?
    var channel : SBDGroupChannel!
    @IBOutlet weak var dateSeperatorView: UIView!
    @IBOutlet weak var dateSeperatorLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageLabel: TTTAttributedLabel!
    @IBOutlet weak var messageDateLabel: UILabel!
    @IBOutlet weak var messageContainerView: UIView!
    
    @IBOutlet weak var dateSeperatorViewTopMargin: NSLayoutConstraint!
    @IBOutlet weak var dateSeperatorViewHeight: NSLayoutConstraint!
    @IBOutlet weak var dateSeperatorViewBottomMargin: NSLayoutConstraint!
    
    @IBOutlet weak var profileImageLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var messageContainerLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var profileImageWidth: NSLayoutConstraint!
    @IBOutlet weak var messageDateLabelWidth: NSLayoutConstraint!

    @IBOutlet weak var messageContainerLeftPadding: NSLayoutConstraint!
    @IBOutlet weak var messageContainerBottomPadding: NSLayoutConstraint!
    @IBOutlet weak var messageContainerRightPadding: NSLayoutConstraint!
    @IBOutlet weak var messageContainerTopPadding: NSLayoutConstraint!
    
    @IBOutlet weak var messageDateLabelLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var messageDateLabelRightMargin: NSLayoutConstraint!

    private var message: SBDUserMessage!
    private var prevMessage: SBDBaseMessage?
    private var displayNickname: Bool = true

    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }
    
    @objc private func clickProfileImage() {
        if self.delegate != nil {
            self.delegate?.clickProfileImage(viewCell: self, user: self.message!.sender!)
        }
    }
    
    @objc private func clickUserMessage() {
        if self.delegate != nil {
//            self.delegate?.clickMessage(view: self, message: self.message!)
        }
    }
    
    var isDown : Bool = false
    @objc func longPressed(sender: UILongPressGestureRecognizer)
    {
        if !isDown {
            isDown = true
            print("should display")
            let alert = UIAlertController(title: "Message Options", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Copy Text", style: .default, handler: { (action) in
                self.isDown = false
                UIPasteboard.general.string = self.messageLabel.text
            }))
            alert.addAction(UIAlertAction(title: "Report Message", style: .destructive, handler: { (action) in
                self.isDown = false
                let alert2 = UIAlertController(title: "Report", message: "Why are you reporting this message?", preferredStyle: .alert)
                alert2.addAction(UIAlertAction(title: "Breaks Gary Portal", style: .destructive, handler: { (action) in
                    var last:Int!
                    Database.database().reference().child("reported").observeSingleEvent(of: .value, with: { (snapshot) in
                        let dict = snapshot.value as? NSDictionary
                        last = dict!["lastReport"] as! Int
                        print(last)
                        let new = last + 1
                        Database.database().reference().child("reported").child("\(new)").setValue(["type":"post",
                                                                                                    "sender":self.message.sender?.nickname,
                                                                                                    "channel":self.channel.name,
                                                                                                    "by":zeroPage.userStats.sendbird,
                                                                                                    "reason":"Breaks App"])
                        print("report")
                        Database.database().reference().child("reported").child("lastReport").setValue(new)
                        let alert3 = UIAlertController(title: "Thank You", message: "This message has been reported, an admin will review it and possibly contact you for further information if necessary", preferredStyle: .alert)
                        alert3.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        if var topController = UIApplication.shared.keyWindow?.rootViewController {
                            while let presentedViewController = topController.presentedViewController {
                                topController = presentedViewController
                                
                            }
                            topController.present(alert3, animated: true, completion: nil)
                        }
                    })
                    
                    
                }))
                alert2.addAction(UIAlertAction(title: "Violates Policy", style: .destructive, handler: { (action) in
                    var last:Int!
                    Database.database().reference().child("reported").observeSingleEvent(of: .value, with: { (snapshot) in
                        let dict = snapshot.value as? NSDictionary
                        last = dict!["lastReport"] as! Int
                        print(last)
                        let new = last + 1
                        Database.database().reference().child("reported").child("\(new)").setValue(["type":"post",
                                                                                                    "sender":self.message.sender?.nickname,
                                                                                                    "channel":self.channel.name,
                                                                                                    "by":zeroPage.userStats.sendbird,
                                                                                                    "reason":"Policy"])
                        print("report")
                        Database.database().reference().child("reported").child("lastReport").setValue(new)
                        let alert3 = UIAlertController(title: "Thank You", message: "This message has been reported, an admin will review it and possibly contact you for further information if necessary", preferredStyle: .alert)
                        alert3.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        if var topController = UIApplication.shared.keyWindow?.rootViewController {
                            while let presentedViewController = topController.presentedViewController {
                                topController = presentedViewController
                                
                            }
                            topController.present(alert3, animated: true, completion: nil)
                        }
                    })
                    
                }))
                alert2.addAction(UIAlertAction(title: "Is offensive", style: .destructive, handler: { (action) in
                    var last:Int!
                    Database.database().reference().child("reported").observeSingleEvent(of: .value, with: { (snapshot) in
                        let dict = snapshot.value as? NSDictionary
                        last = dict!["lastReport"] as! Int
                        print(last)
                        let new = last + 1
                        Database.database().reference().child("reported").child("\(new)").setValue(["type":"post",
                                                                                                    "sender":self.message.sender?.nickname,
                                                                                                    "channel":self.channel.name,
                                                                                                    "by":zeroPage.userStats.sendbird,
                                                                                                    "reason":"Offensive"])
                        print("report")
                        Database.database().reference().child("reported").child("lastReport").setValue(new)
                        let alert3 = UIAlertController(title: "Thank You", message: "This message has been reported, an admin will review it and possibly contact you for further information if necessary", preferredStyle: .alert)
                        alert3.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        if var topController = UIApplication.shared.keyWindow?.rootViewController {
                            while let presentedViewController = topController.presentedViewController {
                                topController = presentedViewController
                                
                            }
                            topController.present(alert3, animated: true, completion: nil)
                        }
                    })
                    
                    
                }))
                alert2.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                if var topController = UIApplication.shared.keyWindow?.rootViewController {
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                        
                    }
                    topController.present(alert2, animated: true, completion: nil)
                }
                
            }))
            alert.addAction(UIAlertAction(title: "🐸 Dinosaur Game 🐸", style: .default, handler: { (action) in
                UIApplication.shared.open(URL(string: "https://garyportal.xyz/dino")!, options: [:], completionHandler: nil)
                self.isDown = false
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                    
                }
                topController.present(alert, animated: true, completion: nil)
            }
            
        }
    }
    
    func setModel(aMessage: SBDUserMessage) {
        self.message = aMessage
        
        self.profileImageView.af_setImage(withURL: URL(string: (self.message.sender?.profileUrl!)!)!, placeholderImage: UIImage(named: "img_profile"))
        
        let profileImageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickProfileImage))
        self.profileImageView.isUserInteractionEnabled = true
        self.profileImageView.addGestureRecognizer(profileImageTapRecognizer)

        //Message options
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressed(sender:)))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delaysTouchesBegan = true
        
        self.messageContainerView.addGestureRecognizer(longPressGesture)
        
        // Message Date
        let messageDateAttribute = [
            NSAttributedStringKey.font: Constants.messageDateFont(),
            NSAttributedStringKey.foregroundColor: Constants.messageDateColor()
        ]
        
        let messageTimestamp = Double(self.message.createdAt) / 1000.0
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        let messageCreatedDate = NSDate(timeIntervalSince1970: messageTimestamp)
        let messageDateString = dateFormatter.string(from: messageCreatedDate as Date)
        let messageDateAttributedString = NSMutableAttributedString(string: messageDateString, attributes: messageDateAttribute)
        self.messageDateLabel.attributedText = messageDateAttributedString
        
        // Seperator Date
        let seperatorDateFormatter = DateFormatter()
        seperatorDateFormatter.dateStyle = DateFormatter.Style.medium
        self.dateSeperatorLabel.text = seperatorDateFormatter.string(from: messageCreatedDate as Date)
        
        // Relationship between the current message and the previous message
        self.profileImageView.isHidden = false
        self.dateSeperatorView.isHidden = false
        self.dateSeperatorViewHeight.constant = 24.0
        self.dateSeperatorViewTopMargin.constant = 10.0
        self.dateSeperatorViewBottomMargin.constant = 10.0
        self.displayNickname = true
        if self.prevMessage != nil {
            // Day Changed
            let prevMessageDate = NSDate(timeIntervalSince1970: Double((self.prevMessage?.createdAt)!) / 1000.0)
            let currMessageDate = NSDate(timeIntervalSince1970: Double(self.message.createdAt) / 1000.0)
            let prevMessageDateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: prevMessageDate as Date)
            let currMessagedateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: currMessageDate as Date)
            
            if prevMessageDateComponents.year != currMessagedateComponents.year || prevMessageDateComponents.month != currMessagedateComponents.month || prevMessageDateComponents.day != currMessagedateComponents.day {
                // Show date seperator.
                self.dateSeperatorView.isHidden = false
                self.dateSeperatorViewHeight.constant = 24.0
                self.dateSeperatorViewTopMargin.constant = 10.0
                self.dateSeperatorViewBottomMargin.constant = 10.0
            }
            else {
                // Hide date seperator.
                self.dateSeperatorView.isHidden = true
                self.dateSeperatorViewHeight.constant = 0
                self.dateSeperatorViewBottomMargin.constant = 0
                
                // Continuous Message
                if self.prevMessage is SBDAdminMessage {
                    self.dateSeperatorViewTopMargin.constant = 10.0
                }
                else {
                    var prevMessageSender: SBDUser?
                    var currMessageSender: SBDUser?
                    
                    if self.prevMessage is SBDUserMessage {
                        prevMessageSender = (self.prevMessage as! SBDUserMessage).sender
                    }
                    else if self.prevMessage is SBDFileMessage {
                        prevMessageSender = (self.prevMessage as! SBDFileMessage).sender
                    }
                    
                    currMessageSender = self.message.sender
                    
                    if prevMessageSender != nil && currMessageSender != nil {
                        if prevMessageSender?.userId == currMessageSender?.userId {
                            // Reduce margin
                            self.dateSeperatorViewTopMargin.constant = 5.0
                            self.profileImageView.isHidden = true
                            self.displayNickname = false
                        }
                        else {
                            // Set default margin.
                            self.profileImageView.isHidden = false
                            self.dateSeperatorViewTopMargin.constant = 10.0
                        }
                    }
                    else {
                        self.dateSeperatorViewTopMargin.constant = 10.0
                    }
                }
            }
        }
        else {
            // Show date seperator.
            self.dateSeperatorView.isHidden = false
            self.dateSeperatorViewHeight.constant = 24.0
            self.dateSeperatorViewTopMargin.constant = 10.0
            self.dateSeperatorViewBottomMargin.constant = 10.0
        }
        
        let fullMessage = self.buildMessage()
        self.messageLabel.attributedText = fullMessage
        self.messageLabel.isUserInteractionEnabled = true
        self.messageLabel.linkAttributes = [
            NSAttributedStringKey.font: Constants.messageFont(),
            NSAttributedStringKey.foregroundColor: Constants.incomingMessageColor(),
            NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue
        ]
        self.messageLabel.textColor = UIColor.flatWhite
        let detector: NSDataDetector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: self.message.message!, options: [], range: NSMakeRange(0, (self.message.message?.count)!))
        if matches.count > 0 {
            self.messageLabel.delegate = self
            self.messageLabel.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
            for item in matches {
                let match = item
                let rangeOfOriginalMessage = match.range
                var range: NSRange
                if self.displayNickname {
                    range = NSMakeRange((self.message.sender?.nickname?.count)! + 1 + rangeOfOriginalMessage.location, rangeOfOriginalMessage.length)
                }
                else {
                    range = rangeOfOriginalMessage
                }
                
                self.messageLabel.addLink(to: match.url, with: range)
            }
        }
        
        self.layoutIfNeeded()
        self.messageContainerView.layer.cornerRadius = 10
        self.messageContainerView.layer.masksToBounds = true
        self.messageContainerView.backgroundColor = GradientColor(.diagonal, frame: self.messageContainerView.frame, colors: [UIColor(red:0.85, green:0.65, blue:0.78, alpha:1.0)
            , UIColor(red:1.00, green:0.99, blue:0.86, alpha:1.0)])

    }
    
    func setPreviousMessage(aPrevMessage: SBDBaseMessage?) {
        self.prevMessage = aPrevMessage
    }
    
    func buildMessage() -> NSAttributedString {
        var nicknameAttribute: [NSAttributedStringKey:AnyObject]?
        switch (self.message.sender?.nickname?.utf8.count)! % 5 {
        case 0:
            nicknameAttribute = [
                NSAttributedStringKey.font: Constants.nicknameFontInMessage(),
                NSAttributedStringKey.foregroundColor: Constants.nicknameColorInMessageNo0()
            ]
            break;
        case 1:
            nicknameAttribute = [
                NSAttributedStringKey.font: Constants.nicknameFontInMessage(),
                NSAttributedStringKey.foregroundColor: Constants.nicknameColorInMessageNo1()
            ]
            break;
        case 2:
            nicknameAttribute = [
                NSAttributedStringKey.font: Constants.nicknameFontInMessage(),
                NSAttributedStringKey.foregroundColor: Constants.nicknameColorInMessageNo2()
            ]
            break;
        case 3:
            nicknameAttribute = [
                NSAttributedStringKey.font: Constants.nicknameFontInMessage(),
                NSAttributedStringKey.foregroundColor: Constants.nicknameColorInMessageNo3()
            ]
            break;
        case 4:
            nicknameAttribute = [
                NSAttributedStringKey.font: Constants.nicknameFontInMessage(),
                NSAttributedStringKey.foregroundColor: Constants.nicknameColorInMessageNo4()
            ]
            break;
        default:
            nicknameAttribute = [
                NSAttributedStringKey.font: Constants.nicknameFontInMessage(),
                NSAttributedStringKey.foregroundColor: Constants.nicknameColorInMessageNo0()
            ]
            break;
        }
        
        let messageAttribute = [
            NSAttributedStringKey.font: Constants.messageFont()
        ]
        
        let nickname = self.message.sender?.nickname
        let message = self.message.message
        
        var fullMessage: NSMutableAttributedString? = nil
        if self.displayNickname == true {
            fullMessage = NSMutableAttributedString.init(string: NSString(format: "%@\n%@", nickname!, message!) as String)
            
            fullMessage?.addAttributes(nicknameAttribute!, range: NSMakeRange(0, (nickname?.utf16.count)!))
            fullMessage?.addAttributes(messageAttribute, range: NSMakeRange((nickname?.utf16.count)! + 1, (message?.utf16.count)!))
        }
        else {
            fullMessage = NSMutableAttributedString.init(string: message!)
            fullMessage?.addAttributes(messageAttribute, range: NSMakeRange(0, (message?.utf16.count)!))
        }
        
        return fullMessage!
    }
    
    func getHeightOfViewCell() -> CGFloat {
        let fullMessage = self.buildMessage()
        
        var fullMessageSize: CGSize

        let messageLabelMaxWidth = UIScreen.main.bounds.size.width - (self.profileImageLeftMargin.constant + self.profileImageWidth.constant + self.messageContainerLeftMargin.constant + self.messageContainerLeftPadding.constant + self.messageContainerRightPadding.constant + self.messageDateLabelLeftMargin.constant + self.messageDateLabelWidth.constant + self.messageDateLabelRightMargin.constant)
        let framesetter = CTFramesetterCreateWithAttributedString(fullMessage)
        fullMessageSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(location: 0,length: 0), nil, CGSize(width: messageLabelMaxWidth, height: CGFloat(LONG_LONG_MAX)), nil)

        let cellHeight = self.dateSeperatorViewTopMargin.constant + self.dateSeperatorViewHeight.constant + self.dateSeperatorViewBottomMargin.constant + self.messageContainerTopPadding.constant + fullMessageSize.height + self.messageContainerBottomPadding.constant
        
        
        return cellHeight
    }
    
    // MARK: TTTAttributedLabelDelegate
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
