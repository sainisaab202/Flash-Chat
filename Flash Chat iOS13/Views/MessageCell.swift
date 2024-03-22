//
//  MessageCell.swift
//  Flash Chat iOS13
//
//  Created by GurPreet SaiNi on 2024-03-20.
//  Copyright © 2024 Angela Yu. All rights reserved.
//

//is a cocoa touch file inheriting UITableViewCell created with XIB file

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var viewMessageBubble: UIView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var imgRight: UIImageView!
    @IBOutlet weak var imgLeft: UIImageView!
    @IBOutlet weak var viewSpacing: UIView!
    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        viewMessageBubble.layer.cornerRadius = viewMessageBubble.frame.size.height / 6
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func putRightSpacing(){
        
        stackView.removeArrangedSubview(viewSpacing)
        stackView.insertArrangedSubview(viewSpacing, at: stackView.subviews.count-1)
        
    }
    
}
