//
//  OutgoingUserMessageTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/7/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import TTTAttributedLabel
import ChameleonFramework

class OutgoingUserMessageTableViewCell: UITableViewCell {
    weak var delegate: MessageDelegate?
    
    @IBOutlet weak var dateSeperatorContainerView: UIView!
    @IBOutlet weak var dateSeperatorLabel: UILabel!
    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var messageLabel: TTTAttributedLabel!
    @IBOutlet weak var messageDateLabel: UILabel!
    @IBOutlet weak var resendMessageButton: UIButton!
    @IBOutlet weak var deleteMessageButton: UIButton!
    @IBOutlet weak var unreadCountLabel: UILabel!
    @IBOutlet weak var sendingStatusLabel: UILabel!

    @IBOutlet weak var dateContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var dateContainerTopMargin: NSLayoutConstraint!
    @IBOutlet weak var dateContainerBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var messageContainerTopPadding: NSLayoutConstraint!
    @IBOutlet weak var messageContainerBottomPadding: NSLayoutConstraint!
    
    @IBOutlet weak var messageContainerRightMargin: NSLayoutConstraint!
    @IBOutlet weak var messageContainerRightPadding: NSLayoutConstraint!
    @IBOutlet weak var messageContainerLeftPadding: NSLayoutConstraint!
    @IBOutlet weak var messageContainerLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var messageDateLabelLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var messageDateLabelWidth: NSLayoutConstraint!

    private var message: SBDUserMessage!
    private var prevMessage: SBDBaseMessage!
    var channel : SBDGroupChannel!

    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }

    @objc private func clickUserMessage() {
        if self.delegate != nil {
            self.delegate?.clickMessage(view: self, message: self.message!)
        }
    }
    
    @objc private func clickResendUserMessage() {
        if self.delegate != nil {
            self.delegate?.clickResend(view: self, message: self.message!)
        }
    }
    
    @objc private func clickDeleteUserMessage() {
        if self.delegate != nil {
            self.delegate?.clickDelete(view: self, message: self.message!)
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
            alert.addAction(UIAlertAction(title: "👻!! Delete Message !!👻", style: .destructive, handler: { (action) in
                self.channel.delete(self.message, completionHandler: nil)
                self.isDown = false
                
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
        
        let fullMessage = self.buildMessage()
        
        self.messageLabel.attributedText = fullMessage
        
        self.resendMessageButton.isHidden = true
        self.deleteMessageButton.isHidden = true
        
//        let messageContainerTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickUserMessage))
//        self.messageContainerView.isUserInteractionEnabled = true
//        self.messageContainerView.addGestureRecognizer(messageContainerTapRecognizer)

        self.resendMessageButton.addTarget(self, action: #selector(clickResendUserMessage), for: UIControlEvents.touchUpInside)
        self.deleteMessageButton.addTarget(self, action: #selector(clickDeleteUserMessage), for: UIControlEvents.touchUpInside)
        
        
        //Message options
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressed(sender:)))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delaysTouchesBegan = true
        
        self.messageContainerView.addGestureRecognizer(longPressGesture)

        
        // Unread message count
        self.hideUnreadCount()
        
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
        self.dateSeperatorContainerView.isHidden = false
        self.dateContainerHeight.constant = 24.0
        self.dateContainerTopMargin.constant = 10.0
        self.dateContainerBottomMargin.constant = 10.0
        if self.prevMessage != nil {
            // Day Changed
            let prevMessageDate = NSDate(timeIntervalSince1970: Double(self.prevMessage.createdAt) / 1000.0)
            let currMessageDate = NSDate(timeIntervalSince1970: Double(self.message.createdAt) / 1000.0)
            let prevMessageDateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: prevMessageDate as Date)
            let currMessagedateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: currMessageDate as Date)
            
            if prevMessageDateComponents.year != currMessagedateComponents.year || prevMessageDateComponents.month != currMessagedateComponents.month || prevMessageDateComponents.day != currMessagedateComponents.day {
                // Show date seperator.
                self.dateSeperatorContainerView.isHidden = false
                self.dateContainerHeight.constant = 24.0
                self.dateContainerTopMargin.constant = 10.0
                self.dateContainerBottomMargin.constant = 10.0
            }
            else {
                // Hide date seperator.
                self.dateSeperatorContainerView.isHidden = true
                self.dateContainerHeight.constant = 0
                self.dateContainerBottomMargin.constant = 0
                
                // Continuous Message
                if self.prevMessage is SBDAdminMessage {
                    self.dateContainerTopMargin.constant = 10.0
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
                            self.dateContainerTopMargin.constant = 5.0
                        }
                        else {
                            // Set default margin.
                            self.dateContainerTopMargin.constant = 10.0
                        }
                    }
                    else {
                        self.dateContainerTopMargin.constant = 10.0
                    }
                }
            }
        }
        else {
            // Show date seperator.
            self.dateSeperatorContainerView.isHidden = false
            self.dateContainerHeight.constant = 24.0
            self.dateContainerTopMargin.constant = 10.0
            self.dateContainerBottomMargin.constant = 10.0
        }

        self.layoutIfNeeded()
        
        self.messageLabel.textColor = UIColor.flatBlack
        self.messageContainerView.layer.cornerRadius = 10
        self.messageContainerView.layer.masksToBounds = true
        self.messageContainerView.backgroundColor = GradientColor(.diagonal, frame: self.messageContainerView.frame, colors: [UIColor(red:0.90, green:0.36, blue:0.00, alpha:1.0)
            , UIColor(red:0.98, green:0.83, blue:0.14, alpha:1.0)])
        
    }

    func setPreviousMessage(aPrevMessage: SBDBaseMessage?) {
        self.prevMessage = aPrevMessage
    }
    
    func buildMessage() -> NSAttributedString {
        let messageAttribute = [
            NSAttributedStringKey.font: Constants.messageFont(),
            NSAttributedStringKey.foregroundColor: Constants.outgoingMessageColor(),
        ]
        
        let message = self.message.message
        
        let fullMessage = NSMutableAttributedString.init(string: message!)
        fullMessage.addAttributes(messageAttribute, range: NSMakeRange(0, (message?.utf16.count)!))
        
        return fullMessage
    }
    
    func getHeightOfViewCell() -> CGFloat {
        let fullMessage = self.buildMessage()
        var fullMessageSize: CGSize
        
        let messageLabelMaxWidth = UIScreen.main.bounds.size.width - (self.messageContainerRightMargin.constant + self.messageContainerRightPadding.constant + self.messageContainerLeftPadding.constant + self.messageContainerLeftMargin.constant + self.messageDateLabelLeftMargin.constant + self.messageDateLabelWidth.constant)

//        fullMessageRect = fullMessage.boundingRect(with: CGSize.init(width: messageLabelMaxWidth, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        
        let framesetter = CTFramesetterCreateWithAttributedString(fullMessage)
        fullMessageSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(location: 0,length: 0), nil, CGSize(width: messageLabelMaxWidth, height: CGFloat(LONG_LONG_MAX)), nil)
        
        let cellHeight = self.dateContainerTopMargin.constant + self.dateContainerHeight.constant + self.dateContainerBottomMargin.constant + self.messageContainerTopPadding.constant + fullMessageSize.height + self.messageContainerBottomPadding.constant
        
        return cellHeight
    }
    
    func hideUnreadCount() {
        self.unreadCountLabel.isHidden = true
    }
    
    func showUnreadCount() {
        if self.message.channelType == CHANNEL_TYPE_GROUP {
            self.unreadCountLabel.isHidden = false
            self.resendMessageButton.isHidden = true
            self.deleteMessageButton.isHidden = true
        }
    }
    
    func hideMessageControlButton() {
        self.resendMessageButton.isHidden = true
        self.deleteMessageButton.isHidden = true
    }
    
    func showMessageControlButton() {
        self.sendingStatusLabel.isHidden = true
        self.messageDateLabel.isHidden = true
        self.unreadCountLabel.isHidden = true
        
        self.resendMessageButton.isHidden = false
        self.deleteMessageButton.isHidden = false
    }
    
    func showSendingStatus() {
        self.messageDateLabel.isHidden = true
        self.unreadCountLabel.isHidden = true
        self.resendMessageButton.isHidden = true
        self.deleteMessageButton.isHidden = true
        
        self.sendingStatusLabel.isHidden = false
        self.sendingStatusLabel.text = "Sending"
    }
    
    func showFailedStatus() {
        self.messageDateLabel.isHidden = true
        self.unreadCountLabel.isHidden = true
        self.resendMessageButton.isHidden = true
        self.deleteMessageButton.isHidden = true
        
        self.sendingStatusLabel.isHidden = false
        self.sendingStatusLabel.text = "Failed"
    }
    
    func showMessageDate() {
        self.unreadCountLabel.isHidden = true
        self.resendMessageButton.isHidden = true
        self.sendingStatusLabel.isHidden = true
        
        self.messageDateLabel.isHidden = false
    }
}
