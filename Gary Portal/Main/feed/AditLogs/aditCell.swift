//
//  aditCell.swift
//  Gary Portal
//
//  Created by Tom Knighton on 29/05/2018.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit

class aditCell: UITableViewCell {

    @IBOutlet weak var background: UIView!
    @IBOutlet weak var aditThumbnail: UIImageView!
    @IBOutlet weak var aditVideoThumbnail: UIView!
    @IBOutlet weak var posterName: UILabel!
    @IBOutlet weak var postedTime: UILabel!
    @IBOutlet weak var postOptions: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.aditThumbnail.layer.cornerRadius = 40
        self.aditVideoThumbnail.layer.cornerRadius = 40
        self.aditThumbnail.layer.masksToBounds = true
        self.aditVideoThumbnail.layer.masksToBounds = true
        
        self.background.layer.cornerRadius = 20
        self.background.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
