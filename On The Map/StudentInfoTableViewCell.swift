//
//  StudentInfoTableViewCell.swift
//  On The Map
//
//  Created by Paul Miller on 15/04/2015.
//  Copyright (c) 2015 PoneTeller. All rights reserved.
//

import UIKit

class StudentInfoTableViewCell: UITableViewCell {

    //MARK: - Properties
    
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var studentURLLabel: UILabel!
    @IBOutlet weak var pinImageView: UIImageView!
    
    //MARK: - Overrides
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }
}
