//
//  ChannelCell.swift
//  FirebaseAdsPublisher
//
//  Created by Prasad Pai on 15/08/16.
//  Copyright © 2016 YMedia Labs. All rights reserved.
//

import UIKit

class ChannelCell: UITableViewCell {
    
    @IBOutlet weak var channelLabel: UILabel!
    @IBOutlet weak var resultsBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
