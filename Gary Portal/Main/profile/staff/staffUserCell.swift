//
//  staffUserCell.swift
//  Gary Portal
//
//  Created by Tom Knighton on 02/04/2018.
//  Copyright © 2018 Tom Knighton. All rights reserved.
//

import UIKit

class staffUserCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var editB: UIButton!
    
    
    public struct editingUser {
        static var editingUID = ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        editB.layer.cornerRadius = 10
        editB.layer.masksToBounds = true
        editB.layer.borderColor = UIColor.orange.cgColor
        editB.layer.borderWidth = 1
        
        userImage.layer.cornerRadius = 35
        userImage.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
