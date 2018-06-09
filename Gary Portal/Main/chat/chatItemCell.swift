//
//  chatItemCell.swift
//  Gary Portal
//
//  Created by Tom Knighton on 05/04/2018.
//  Copyright © 2018 Tom Knighton. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class chatItemCell: MGSwipeTableCell {

    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var unreadView: UIView!
    @IBOutlet weak var unreadCount: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var lastMessageDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
