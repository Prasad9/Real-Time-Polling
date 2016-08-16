//
//  TextfieldCell.swift
//  FirebaseAdsPublisher
//
//  Created by Prasad Pai on 15/08/16.
//  Copyright © 2016 YMedia Labs. All rights reserved.
//

import UIKit

class TextfieldCell: UITableViewCell {
    
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var removeBtnWidthConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setRemoveBtnHidden(isHidden: Bool) {
        self.removeBtnWidthConstraint.constant = isHidden ? 0.0 : 55.0
        self.layoutIfNeeded()
    }

}
