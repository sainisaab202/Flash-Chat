//
//  ReceivedMessageCell.swift
//  Flash Chat iOS13
//
//  Created by GurPreet SaiNi on 2024-03-22.
//  Copyright © 2024 Angela Yu. All rights reserved.
//

import UIKit

class ReceivedMessageCell: UITableViewCell {

    @IBOutlet weak var imgSender: UIImageView!
    @IBOutlet weak var viewMessageBubble: UIView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var viewSpacing: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        viewMessageBubble.layer.cornerRadius = viewMessageBubble.frame.size.height / 6
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
